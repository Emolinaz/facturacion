const { body } = require('express-validator');

const validarFactura = [
  body('cod_evento').notEmpty().withMessage('El código de evento es obligatorio'),
  body('cod_cliente').notEmpty().withMessage('El código de cliente es obligatorio'),
  body('cod_empleado').notEmpty().withMessage('El código de empleado es obligatorio'),
  body('cod_cai').notEmpty().withMessage('El código de CAI es obligatorio'),
  body('numero_factura').notEmpty().isLength({ max: 25 }).withMessage('Número de factura requerido (máx. 25 caracteres)'),
  body('fecha_emision').notEmpty().isDate().withMessage('Fecha de emisión inválida'),
  body('subtotal').notEmpty().isFloat({ min: 0 }).withMessage('Subtotal debe ser un número positivo'),
  body('importe_gravado_15').isFloat({ min: 0 }).optional(),
  body('impuesto_15').isFloat({ min: 0 }).optional(),
  body('importe_gravado_18').isFloat({ min: 0 }).optional(),
  body('impuesto_18').isFloat({ min: 0 }).optional(),
  body('importe_exento').isFloat({ min: 0 }).optional(),
  body('rebaja_otorgada').isFloat({ min: 0 }).optional(),
  body('descuento_otorgado').isFloat({ min: 0 }).optional(),
  body('total').notEmpty().isFloat({ min: 0 }).withMessage('Total debe ser un número positivo'),
  body('nota').optional().isString().withMessage('Nota debe ser texto')
];

module.exports = { validarFactura };
