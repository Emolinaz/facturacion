const express = require('express');
const router = express.Router();
const { listarCai } = require('../controllers/cai.controller');

router.get('/', listarCai);

module.exports = router;
