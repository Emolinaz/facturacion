const db = require('../db/connection');

// INSERTAR factura
const insertarFactura = (req, res) => {
  const data = req.body;

  const sql = 'CALL sp_gestion_factura(?, NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';
  const params = [
    'insertar',
    data.cod_evento,
    data.cod_cliente,
    data.cod_empleado,
    data.cod_cai,
    data.numero_factura,
    data.fecha_emision,
    data.subtotal,
    data.importe_gravado_15,
    data.impuesto_15,
    data.importe_gravado_18,
    data.impuesto_18,
    data.importe_exento,
    data.rebaja_otorgada,
    data.descuento_otorgado,
    data.total,
    data.nota
  ];

  db.query(sql, params, (err, results) => {
    if (err) {
      console.error('Error al insertar factura:', err);
      return res.status(500).json({ error: 'Error al insertar la factura' });
    }
    res.json(results[0]);
  });
};

// MOSTRAR UNA factura
const mostrarFactura = (req, res) => {
  const cod_factura = req.params.id;

  const sql = 'CALL sp_gestion_factura(?, ?, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)';
  const params = ['mostrar', cod_factura];

  db.query(sql, params, (err, results) => {
    if (err) {
      console.error('Error al mostrar factura:', err);
      return res.status(500).json({ error: 'Error al mostrar factura' });
    }
    res.json(results[0]);
  });
};

// MOSTRAR TODAS las facturas
const mostrarTodasFacturas = (req, res) => {
  const sql = 'CALL sp_gestion_factura(?, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)';
  const params = ['mostrar'];

  db.query(sql, params, (err, results) => {
    if (err) {
      console.error('Error al mostrar todas las facturas:', err);
      return res.status(500).json({ error: 'Error al mostrar todas las facturas' });
    }
    res.json(results[0]);
  });
};

// ELIMINAR factura
const eliminarFactura = (req, res) => {
  const cod_factura = req.params.id;

  const sql = 'CALL sp_gestion_factura(?, ?, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)';
  const params = ['eliminar', cod_factura];

  db.query(sql, params, (err, results) => {
    if (err) {
      console.error('Error al eliminar factura:', err);
      return res.status(500).json({ error: 'Error al eliminar factura' });
    }
    res.json(results[0]);
  });
};

// Exportar todos
module.exports = {
  insertarFactura,
  mostrarFactura,
  mostrarTodasFacturas,
  eliminarFactura
};
