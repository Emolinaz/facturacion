const express = require('express');
const router = express.Router();
const { validarDetalle } = require('../validators/detalle.validator');
const { validationResult } = require('express-validator');
const detalleController = require('../controllers/detalle.controller');

const manejarErrores = (req, res, next) => {
  const errores = validationResult(req);
  if (!errores.isEmpty()) {
    return res.status(400).json({ errores: errores.array() });
  }
  next();
};

router.post('/insertar', validarDetalle, manejarErrores, detalleController.insertarDetalle);
router.get('/mostrar/:cod_factura', detalleController.mostrarDetalles);
router.delete('/eliminar/:id', detalleController.eliminarDetalle);

module.exports = router;
