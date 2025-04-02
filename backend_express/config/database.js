const mysql = require('mysql2/promise');

const db = mysql.createPool({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'book_management',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

module.exports = db; // No need to call .promise() here
