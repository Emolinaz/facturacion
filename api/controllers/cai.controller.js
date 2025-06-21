const db = require('../db/connection');

const listarCai = (req, res) => {
  db.query('SELECT * FROM cai WHERE activo = 1', (err, rows) => {
    if (err) return res.status(500).json({ error: 'Error al obtener CAI' });
    res.json(rows);
  });
};

module.exports = { listarCai };
