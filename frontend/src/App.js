import React, { useState, useEffect } from 'react';
import './App.css';

// Always use relative URLs - the frontend server will proxy to the backend
// This avoids CORS, mixed content, and network issues
const API_URL = '';

function App() {
  const [tasks, setTasks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [newTask, setNewTask] = useState({ title: '', description: '' });

  // Fetch tasks from backend API
  useEffect(() => {
    fetchTasks();
  }, []);

  const fetchTasks = async () => {
    try {
      setLoading(true);
      const response = await fetch('/api/tasks');
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      const data = await response.json();
      setTasks(data);  // CHAOS: Deliberate typo - should be setTasks
      setError(null);
    } catch (err) {
      console.error('Error fetching tasks:', err);
      setError(`Failed to connect to backend API. Error: ${err.message}. The request is being proxied through the frontend server.`);
    } finally {
      setLoading(false);
    }
  };

  const createTask = async (e) => {
    e.preventDefault();
    try {
      console.log('Creating task with URL:', `${API_URL}/api/tasks`);
      console.log('Request body:', newTask);
      
      const response = await fetch('/api/tasks', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(newTask),
      });
      
      console.log('Response status:', response.status);
      console.log('Response headers:', response.headers);
      
      if (!response.ok) {
        const errorText = await response.text();
        console.error('Error response:', errorText);
        throw new Error(`HTTP ${response.status}: ${errorText || 'Failed to create task'}`);
      }
      
      const task = await response.json();
      setTasks([task, ...tasks]);
      setNewTask({ title: '', description: '' });
      setError(null);
    } catch (err) {
      console.error('Error creating task:', err);
      const errorMsg = err.message || 'Failed to create task';
      setError(`Failed to create task: ${errorMsg}. API URL: ${API_URL}`);
    }
  };

  const deleteTask = async (id) => {
    try {
      const response = await fetch(`/api/tasks/${id}`, {
        method: 'DELETE',
      });
      if (!response.ok) {
        throw new Error('Failed to delete task');
      }
      setTasks(tasks.filter(task => task.id !== id));
      setError(null);
    } catch (err) {
      console.error('Error deleting task:', err);
      setError(`Failed to delete task: ${err.message}`);
    }
  };

  const testConnection = async () => {
    try {
      setLoading(true);
      setError(null);
      console.log('Testing connection to: /health (proxied to backend)');
      
      // Try with different options to diagnose the issue
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 10000); // 10 second timeout
      
      const response = await fetch('/health', {
        method: 'GET',
        mode: 'cors',
        signal: controller.signal,
        headers: {
          'Accept': 'application/json',
        }
      });
      
      clearTimeout(timeoutId);
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      const data = await response.json();
      console.log('Health check response:', data);
      setError(`✅ Connection successful! Backend is healthy. Status: ${data.status}`);
      setTimeout(() => setError(null), 5000);
    } catch (err) {
      console.error('Connection test failed:', err);
      let errorMsg = `❌ Connection failed: ${err.message}`;
      
      if (err.name === 'AbortError') {
        errorMsg += ' (Timeout - backend may be unreachable or firewall blocking)';
      } else if (err.message.includes('Failed to fetch')) {
        errorMsg += ' (Network error - check CORS, firewall, or backend availability)';
      }
      
      errorMsg += `\n\nTroubleshooting:\n1. Check frontend server logs for proxy errors\n2. Verify backend is accessible from frontend server\n3. Check if backend pods are running: kubectl get pods -n tsp-app\n4. Test backend directly: curl http://52.160.32.57:80/health`;
      
      setError(errorMsg);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>TSP Task Manager - All Tasks</h1>
        
        {error && (
          <div className="error-message">
            <p>⚠️ {error}</p>
            <div style={{ display: 'flex', gap: '10px', justifyContent: 'center', marginTop: '10px' }}>
              <button onClick={testConnection}>Test Connection</button>
              <button onClick={fetchTasks}>Retry Fetch</button>
            </div>
          </div>
        )}
        
        <button onClick={testConnection} style={{ marginBottom: '20px', padding: '10px 20px' }}>
          Test Backend Connection
        </button>

        <div className="task-form">
          <h2>Create New Task</h2>
          <form onSubmit={createTask}>
            <input
              type="text"
              placeholder="Task title"
              value={newTask.title}
              onChange={(e) => setNewTask({ ...newTask, title: e.target.value })}
              required
            />
            <textarea
              placeholder="Task description"
              value={newTask.description}
              onChange={(e) => setNewTask({ ...newTask, description: e.target.value })}
            />
            <button type="submit">Create Task</button>
          </form>
        </div>

        <div className="tasks-list">
          <h2>Tasks ({tasks.length})</h2>
          {loading ? (
            <p>Loading tasks...</p>
          ) : tasks.length === 0 ? (
            <p>No tasks yet. Create one above!</p>
          ) : (
            <ul>
              {tasks.map(task => (
                <li key={task.id}>
                  <div className="task-item">
                    <h3>{task.title}</h3>
                    <p>{task.description || 'No description'}</p>
                    <div className="task-meta">
                      <span>Status: {task.status}</span>
                      <span>Created: {new Date(task.created_at).toLocaleString()}</span>
                      <button onClick={() => deleteTask(task.id)}>Delete</button>
                    </div>
                  </div>
                </li>
              ))}
            </ul>
          )}
        </div>
      </header>
    </div>
  );
}

export default App;
