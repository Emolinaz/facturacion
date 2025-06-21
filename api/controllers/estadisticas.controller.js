const db = require('../db/connection');

const estadisticasFacturas = (req, res) => {
  const sql = `
    SELECT
      COUNT(*) AS total_facturas,
      IFNULL(SUM(total), 0) AS total_facturado
    FROM facturas
    WHERE MONTH(fecha_emision) = MONTH(CURRENT_DATE())
  `;
  db.query(sql, (err, rows) => {
    if (err) return res.status(500).json({ error: 'Error al obtener estadísticas' });
    res.json(rows[0]);
  });
};

module.exports = { estadisticasFacturas };
