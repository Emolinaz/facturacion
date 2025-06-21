const mysql = require('mysql2');

const connection = mysql.createConnection({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_DATABASE || 'base_funcional'
});

connection.connect(error => {
  if (error) {
    console.error('❌ Error de conexión a la base de datos:', error);
  } else {
    console.log('✅ Conexión establecida con MySQL');
  }
});

module.exports = connection;
