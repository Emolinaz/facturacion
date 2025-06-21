const db = require('../db/connection');
const PDFDocument = require('pdfkit');

// Exportar factura a PDF
const exportarFacturaPDF = (req, res) => {
  const cod_factura = req.params.id;

  const sqlFactura = 'CALL sp_gestion_factura(?, ?, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)';
  const sqlDetalles = 'CALL sp_gestion_detalle_factura(?, NULL, ?, NULL, NULL, NULL, NULL)';

  db.query(sqlFactura, ['mostrar', cod_factura], (err1, facturaResult) => {
    if (err1 || facturaResult[0].length === 0) {
      return res.status(404).json({ error: 'Factura no encontrada' });
    }

    const factura = facturaResult[0][0];

    db.query(sqlDetalles, ['mostrar', cod_factura], (err2, detalleResult) => {
      if (err2) {
        return res.status(500).json({ error: 'Error al obtener los detalles' });
      }

      const detalles = detalleResult[0];

      // Crear PDF
      const doc = new PDFDocument();
      let buffers = [];

      doc.on('data', buffers.push.bind(buffers));
      doc.on('end', () => {
        const pdfData = Buffer.concat(buffers);
        res
          .writeHead(200, {
            'Content-Type': 'application/pdf',
            'Content-Disposition': `inline; filename=factura_${cod_factura}.pdf`,
            'Content-Length': pdfData.length
          })
          .end(pdfData);
      });

      // Encabezado
      doc.fontSize(20).text('Factura', { align: 'center' });
      doc.moveDown();
      doc.fontSize(12).text(`Factura No: ${factura.cod_factura}`);
      doc.text(`Fecha: ${new Date(factura.fecha_emision).toLocaleDateString()}`);
      doc.text(`Cliente: ${factura.cod_cliente}`);
      doc.text(`Empleado: ${factura.cod_empleado}`);
      doc.text(`CAI: ${factura.cod_cai}`);
      doc.moveDown();

      // Tabla de detalles
      doc.fontSize(14).text('Detalle', { underline: true });
      doc.moveDown();

      detalles.forEach((item, index) => {
        doc
          .fontSize(12)
          .text(
            `${index + 1}. ${item.descripcion} — Cantidad: ${item.cantidad} — Precio: L.${item.precio_unitario} — Total: L.${item.total}`
          );
      });

      doc.moveDown();
      doc.text(`Subtotal: L.${factura.subtotal}`);
      doc.text(`Total: L.${factura.total}`);
      doc.text(`Nota: ${factura.nota}`);

      doc.end();
    });
  });
};

module.exports = {
  exportarFacturaPDF
};
