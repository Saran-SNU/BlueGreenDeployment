const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send(`Hello from Blue-Green Deployment! Running on port ${PORT}`);
});

// Important: Bind to 0.0.0.0 for container access
app.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ Server running on port ${PORT}`);
});
