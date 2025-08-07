const http = require('http');

const options = {
  host: 'localhost',
  port: 3000,
  path: '/health'
};

const req = http.request(options, (res) => {
  if (res.statusCode === 200) {
    process.exit(0);
  } else {
    process.exit(1);
  }
});

req.on('error', () => {
  process.exit(1);
});

req.end();
