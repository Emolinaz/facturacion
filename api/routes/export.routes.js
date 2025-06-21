const express = require('express');
const router = express.Router();
const exportController = require('../controllers/export.controller');

router.get('/factura/pdf/:id', exportController.exportarFacturaPDF);

module.exports = router;
