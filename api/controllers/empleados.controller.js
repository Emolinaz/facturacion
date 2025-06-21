const db = require('../db/connection');

const listarEmpleados = (req, res) => {
  const sql = `
    SELECT emp.cod_empleado, p.nombre_persona AS nombre, emp.cargo
    FROM empleados emp
    INNER JOIN personas p ON emp.cod_empleado = p.dni
  `;
  db.query(sql, (err, rows) => {
    if (err) return res.status(500).json({ error: 'Error al obtener empleados' });
    res.json(rows);
  });
};

module.exports = { listarEmpleados };
