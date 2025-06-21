const express = require('express');
const { validarFactura } = require('../validators/factura.validator');
const { validationResult } = require('express-validator');
const router = express.Router();
const facturaController = require('../controllers/factura.controller');

// Middleware para manejar errores de validación
const manejarErrores = (req, res, next) => {
  const errores = validationResult(req);
  if (!errores.isEmpty()) {
    return res.status(400).json({ errores: errores.array() });
  }
  next();
};

router.post('/insertar', validarFactura, manejarErrores, facturaController.insertarFactura);
router.get('/mostrar', facturaController.mostrarTodasFacturas);
router.get('/mostrar/:id', facturaController.mostrarFactura);
router.delete('/eliminar/:id', facturaController.eliminarFactura);

module.exports = router;
