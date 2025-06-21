const express = require('express');
const router = express.Router();
const { estadisticasFacturas } = require('../controllers/estadisticas.controller');

router.get('/facturas/estadisticas', estadisticasFacturas);

module.exports = router;
