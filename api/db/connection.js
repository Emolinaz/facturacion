const mysql = require('mysql2');

const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'base_funcional'
});

connection.connect(error => {
  if (error) {
    console.error('❌ Error de conexión a la base de datos:', error);
  } else {
    console.log('✅ Conexión establecida con MySQL');
  }
});

module.exports = connection;
