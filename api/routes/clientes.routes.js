const express = require('express');
const router = express.Router();
const { listarClientes } = require('../controllers/clientes.controller');

router.get('/', listarClientes);

module.exports = router;
