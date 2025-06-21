const db = require('../db/connection');

const listarProductos = (req, res) => {
  const query = `
    SELECT cod_producto, nombre, descripcion, tipo, activo, precio
    FROM productos
    WHERE activo = 1
  `;
  db.query(query, (err, rows) => {
    if (err) return res.status(500).json({ error: 'Error al obtener productos' });
    res.json(rows);
  });
};

module.exports = { listarProductos };
