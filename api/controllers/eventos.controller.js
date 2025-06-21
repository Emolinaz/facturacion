const db = require('../db/connection');

const listarEventos = (req, res) => {
  db.query('SELECT * FROM eventos', (err, rows) => {
    if (err) return res.status(500).json({ error: 'Error al obtener eventos' });
    res.json(rows);
  });
};

module.exports = { listarEventos };
