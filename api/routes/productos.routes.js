const express = require('express');
const router = express.Router();
const { listarProductos } = require('../controllers/productos.controller');

router.get('/', listarProductos);

module.exports = router;
