const { body } = require('express-validator');

const validarDetalle = [
  body('cod_factura').notEmpty().withMessage('El código de factura es obligatorio'),
  body('cantidad').notEmpty().isInt({ min: 1 }).withMessage('Cantidad debe ser un entero mayor que cero'),
  body('descripcion').notEmpty().isLength({ max: 255 }).withMessage('Descripción es obligatoria y debe tener máximo 255 caracteres'),
  body('precio_unitario').notEmpty().isFloat({ min: 0 }).withMessage('Precio unitario debe ser un número positivo'),
  body('total').notEmpty().isFloat({ min: 0 }).withMessage('Total debe ser un número positivo')
];

module.exports = { validarDetalle };
