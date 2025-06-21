const db = require('../db/connection');

// INSERTAR detalle de factura
const insertarDetalle = (req, res) => {
  const data = req.body;

  const sql = 'CALL sp_gestion_detalle_factura(?, NULL, ?, ?, ?, ?, ?)';
  const params = [
    'insertar',
    data.cod_factura,
    data.cantidad,
    data.descripcion,
    data.precio_unitario,
    data.total
  ];

  db.query(sql, params, (err, results) => {
    if (err) {
      console.error('Error al insertar detalle:', err);
      return res.status(500).json({ error: 'Error al insertar detalle de factura' });
    }
    res.json(results[0]);
  });
};

// MOSTRAR detalles de una factura
const mostrarDetalles = (req, res) => {
  const cod_factura = req.params.cod_factura;

  const sql = 'CALL sp_gestion_detalle_factura(?, NULL, ?, NULL, NULL, NULL, NULL)';
  const params = ['mostrar', cod_factura];

  db.query(sql, params, (err, results) => {
    if (err) {
      console.error('Error al mostrar detalles:', err);
      return res.status(500).json({ error: 'Error al mostrar detalles de factura' });
    }
    res.json(results[0]);
  });
};

// ELIMINAR un detalle
const eliminarDetalle = (req, res) => {
  const cod_detalle = req.params.id;

  const sql = 'CALL sp_gestion_detalle_factura(?, ?, NULL, NULL, NULL, NULL, NULL)';
  const params = ['eliminar', cod_detalle];

  db.query(sql, params, (err, results) => {
    if (err) {
      console.error('Error al eliminar detalle:', err);
      return res.status(500).json({ error: 'Error al eliminar detalle de factura' });
    }
    res.json(results[0]);
  });
};

module.exports = {
  insertarDetalle,
  mostrarDetalles,
  eliminarDetalle
};
