const express = require('express');
const router = express.Router();
const { listarEmpleados } = require('../controllers/empleados.controller');

router.get('/', listarEmpleados);

module.exports = router;
