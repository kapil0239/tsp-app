// backend/index.js
const express = require('express');
const sql = require('mssql');
const cors = require('cors');
require('dotenv').config();

const app = express();

// CORS configuration - allow all origins for now
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: false
}));

// OTLP proxy must get raw body (protobuf or JSON); mount before express.json()
const OTEL_COLLECTOR_URL = process.env.OTEL_COLLECTOR_URL || 'http://otel-collector.monitoring.svc.cluster.local:4318';
app.use('/api/otel', express.raw({ type: () => true, limit: '5mb' }), (req, res) => {
  const path = req.path === '/' ? '' : req.path;
  const target = `${OTEL_COLLECTOR_URL}${path}`;
  const url = new URL(target);
  const options = {
    hostname: url.hostname,
    port: url.port || 80,
    path: url.pathname + (url.search || ''),
    method: req.method,
    headers: { ...req.headers, host: url.host },
  };
  delete options.headers['content-length'];
  const proxyReq = require('http').request(options, (proxyRes) => {
    res.writeHead(proxyRes.statusCode, proxyRes.headers);
    proxyRes.pipe(res);
  });
  proxyReq.on('error', (err) => {
    console.error('OTLP proxy error:', err.message);
    res.status(502).json({ error: 'Collector unavailable' });
  });
  const body = req.body;
  if (Buffer.isBuffer(body) && body.length) proxyReq.setHeader('Content-Length', body.length);
  if (body && body.length) proxyReq.write(body);
  proxyReq.end();
});

app.use(express.json());

// Log all requests for debugging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// SQL Configuration
const sqlConfig = {
  user: process.env.SQL_USER,
  password: process.env.SQL_PASSWORD,
  database: process.env.SQL_DATABASE,
  server: process.env.SQL_SERVER,
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000
  },
  options: {
    encrypt: true,
    trustServerCertificate: false
  }
};

// Initialize database
async function initDatabase() {
  try {
    const pool = await sql.connect(sqlConfig);
    await pool.request().query(`
      IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='tasks' AND xtype='U')
      CREATE TABLE tasks (
        id INT PRIMARY KEY IDENTITY(1,1),
        title NVARCHAR(200) NOT NULL,
        description NVARCHAR(MAX),
        status NVARCHAR(50) DEFAULT 'pending',
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME DEFAULT GETDATE()
      )
    `);
    console.log('Database initialized successfully');
  } catch (err) {
    console.error('Database initialization error:', err);
  }
}

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// Get all tasks
app.get('/api/tasks', async (req, res) => {
  try {
    const pool = await sql.connect(sqlConfig);
    const result = await pool.request().query('SELECT * FROM tasks ORDER BY created_at DESC');
    res.json(result.recordset);
  } catch (err) {
    console.error('Error fetching tasks:', err);
    res.status(500).json({ error: 'Failed to fetch tasks' });
  }
});

// Get single task
app.get('/api/tasks/:id', async (req, res) => {
  try {
    const pool = await sql.connect(sqlConfig);
    const result = await pool.request()
      .input('id', sql.Int, req.params.id)
      .query('SELECT * FROM tasks WHERE id = @id');
    
    if (result.recordset.length === 0) {
      return res.status(404).json({ error: 'Task not found' });
    }
    res.json(result.recordset[0]);
  } catch (err) {
    console.error('Error fetching task:', err);
    res.status(500).json({ error: 'Failed to fetch task' });
  }
});

// Create task
app.post('/api/tasks', async (req, res) => {
  const { title, description, status } = req.body;
  
  if (!title) {
    return res.status(400).json({ error: 'Title is required' });
  }

  try {
    const pool = await sql.connect(sqlConfig);
    const result = await pool.request()
      .input('title', sql.NVarChar, title)
      .input('description', sql.NVarChar, description || '')
      .input('status', sql.NVarChar, status || 'pending')
      .query(`
        INSERT INTO tasks (title, description, status)
        VALUES (@title, @description, @status);
        SELECT * FROM tasks WHERE id = SCOPE_IDENTITY();
      `);
    
    res.status(201).json(result.recordset[0]);
  } catch (err) {
    console.error('Error creating task:', err);
    res.status(500).json({ error: 'Failed to create task' });
  }
});

// Update task
app.put('/api/tasks/:id', async (req, res) => {
  const { title, description, status } = req.body;
  
  try {
    const pool = await sql.connect(sqlConfig);
    const result = await pool.request()
      .input('id', sql.Int, req.params.id)
      .input('title', sql.NVarChar, title)
      .input('description', sql.NVarChar, description)
      .input('status', sql.NVarChar, status)
      .query(`
        UPDATE tasks 
        SET title = @title, 
            description = @description, 
            status = @status,
            updated_at = GETDATE()
        WHERE id = @id;
        SELECT * FROM tasks WHERE id = @id;
      `);
    
    if (result.recordset.length === 0) {
      return res.status(404).json({ error: 'Task not found' });
    }
    res.json(result.recordset[0]);
  } catch (err) {
    console.error('Error updating task:', err);
    res.status(500).json({ error: 'Failed to update task' });
  }
});

// Delete task
app.delete('/api/tasks/:id', async (req, res) => {
  try {
    const pool = await sql.connect(sqlConfig);
    const result = await pool.request()
      .input('id', sql.Int, req.params.id)
      .query('DELETE FROM tasks WHERE id = @id');
    
    if (result.rowsAffected[0] === 0) {
      return res.status(404).json({ error: 'Task not found' });
    }
    res.json({ message: 'Task deleted successfully' });
  } catch (err) {
    console.error('Error deleting task:', err);
    res.status(500).json({ error: 'Failed to delete task' });
  }
});

const PORT = process.env.PORT || 3001;

// Start server
initDatabase().then(() => {
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`Backend API running on port ${PORT}`);
  });
});
