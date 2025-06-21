const express = require('express');
const router = express.Router();
const { listarEventos } = require('../controllers/eventos.controller');

router.get('/', listarEventos);

module.exports = router;
