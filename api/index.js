// facturacion_api.js
// ------------------------------
// API REST para módulo de facturación
// ------------------------------
const express = require('express');
const mysql   = require('mysql2');
const app     = express();
const port    = 3001;

app.use(express.json());

// Pool de conexiones
const pool = mysql.createPool({
  host            : 'localhost',
  user            : 'root',
  password        : '1234',           // ajusta si usas otra contraseña
  database        : 'facturas_chiminike',
  waitForConnections : true,
  connectionLimit    : 10,
  queueLimit         : 0
});

// ---------- CRUD Facturas ----------

// Listar todas las facturas
app.get('/facturas', (req, res) => {
  pool.query('CALL sp_listar_facturas()', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

// Obtener una factura por ID
app.get('/facturas/:id', (req, res) => {
  const { id } = req.params;
  pool.query('CALL sp_obtener_factura(?)', [id], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    if (results[0].length === 0) return res.status(404).json({ message: 'No encontrada' });
    res.json(results[0][0]);
  });
});

// Crear nueva factura
app.post('/facturas', (req, res) => {
  const params = [
    req.body.numero_factura,
    req.body.fecha_emision,
    req.body.cod_cliente,
    req.body.direccion,
    req.body.rtn,
    req.body.cod_cai,
    req.body.rango_desde,
    req.body.rango_hasta,
    req.body.fecha_limite,
    req.body.tipo_factura,
    req.body.descuento_otorgado,
    req.body.rebajas_otorgadas,
    req.body.importe_exento,
    req.body.importe_gravado_18,
    req.body.importe_gravado_15,
    req.body.impuesto_15,
    req.body.impuesto_18,
    req.body.importe_exonerado,
    req.body.subtotal,
    req.body.total_pago,
    req.body.observaciones
  ];
  pool.query('CALL sp_insertar_factura(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', params, (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ message: 'Factura creada' });
  });
});

// Actualizar factura existente
app.put('/facturas/:id', (req, res) => {
  const { id } = req.params;
  const params = [
    id,
    req.body.numero_factura,
    req.body.fecha_emision,
    req.body.cod_cliente,
    req.body.direccion,
    req.body.rtn,
    req.body.cod_cai,
    req.body.rango_desde,
    req.body.rango_hasta,
    req.body.fecha_limite,
    req.body.tipo_factura,
    req.body.descuento_otorgado,
    req.body.rebajas_otorgadas,
    req.body.importe_exento,
    req.body.importe_gravado_18,
    req.body.importe_gravado_15,
    req.body.impuesto_15,
    req.body.impuesto_18,
    req.body.importe_exonerado,
    req.body.subtotal,
    req.body.total_pago,
    req.body.observaciones
  ];
  pool.query('CALL sp_actualizar_factura(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', params, (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Factura actualizada' });
  });
});

// Eliminar factura
app.delete('/facturas/:id', (req, res) => {
  const { id } = req.params;
  pool.query('CALL sp_eliminar_factura(?)', [id], (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Factura eliminada' });
  });
});

// ---------- CRUD Detalle de Factura ----------

// Listar detalle de una factura
app.get('/facturas/:id/detalle', (req, res) => {
  const { id } = req.params;
  pool.query('CALL sp_listar_detalle_factura(?)', [id], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

// Obtener un ítem de detalle
app.get('/detalle/:cod', (req, res) => {
  const { cod } = req.params;
  pool.query('CALL sp_obtener_detalle_factura(?)', [cod], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    if (results[0].length === 0) return res.status(404).json({ message: 'No encontrado' });
    res.json(results[0][0]);
  });
});

// Insertar un ítem de detalle
app.post('/detalle', (req, res) => {
  const params = [
    req.body.cod_factura,
    req.body.cantidad,
    req.body.descripcion,
    req.body.precio_unitario,
    req.body.total,
    req.body.tipo,
    req.body.referencia
  ];
  pool.query('CALL sp_insertar_detalle_factura(?,?,?,?,?,?,?)', params, (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ message: 'Detalle agregado' });
  });
});

// Actualizar un ítem de detalle
app.put('/detalle/:cod', (req, res) => {
  const { cod } = req.params;
  const params = [
    cod,
    req.body.cantidad,
    req.body.descripcion,
    req.body.precio_unitario,
    req.body.total,
    req.body.tipo,
    req.body.referencia
  ];
  pool.query('CALL sp_actualizar_detalle_factura(?,?,?,?,?,?,?)', params, (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Detalle actualizado' });
  });
});

// Eliminar un ítem de detalle
app.delete('/detalle/:cod', (req, res) => {
  const { cod } = req.params;
  pool.query('CALL sp_eliminar_detalle_factura(?)', [cod], (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Detalle eliminado' });
  });
});

app.listen(port, () => {
  console.log(`API de Facturación corriendo en http://localhost:${port}`);
});
