const express = require('express');
const app = express();
const port = process.env.PORT || 8080;  // Changed from 3000 to 8080

app.get('/', (req, res) => {
  res.send('Hello World! Policy Test App is working!');
});

app.get('/health', (req, res) => {
  res.send('OK');
});

// IMPORTANT: Bind to 0.0.0.0, not localhost
app.listen(port, '0.0.0.0', () => {
  console.log(`App running on port ${port}`);
});
