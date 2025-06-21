const db = require('../db/connection');

const listarBoletosTaquilla = (req, res) => {
  db.query('SELECT * FROM boletos_taquilla WHERE activo = 1', (err, rows) => {
    if (err) return res.status(500).json({ error: 'Error al obtener boletos' });
    res.json(rows);
  });
};

module.exports = {
  listarBoletosTaquilla
};
