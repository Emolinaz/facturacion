const express = require('express');
const router = express.Router();
const { listarBoletosTaquilla } = require('../controllers/boletos.controller');

router.get('/', listarBoletosTaquilla);

module.exports = router;
