const express = require('express');
const path = require('path');
const fs = require('fs');
const app = express();

// Log startup information
console.log('Starting Express server...');
console.log(`Current directory: ${__dirname}`);
console.log(`Port: ${process.env.PORT || 8080}`);

// Check if index.html exists
const indexPath = path.join(__dirname, 'index.html');
if (!fs.existsSync(indexPath)) {
  console.error(`ERROR: index.html not found at ${indexPath}`);
  console.log('Files in directory:', fs.readdirSync(__dirname));
}

// Serve static files from the current directory (server.js is in the build directory)
app.use(express.static(__dirname));

// Handle React routing, return all requests to React app
app.get('*', (req, res) => {
  const filePath = path.join(__dirname, 'index.html');
  if (fs.existsSync(filePath)) {
    res.sendFile(filePath);
  } else {
    res.status(404).send('index.html not found');
  }
});

// Error handling
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).send('Internal Server Error');
});

const port = process.env.PORT || 8080;
app.listen(port, '0.0.0.0', () => {
  console.log(`✅ Server is running on port ${port}`);
  console.log(`📁 Serving files from: ${__dirname}`);
  console.log(`🌐 Application is ready!`);
});

