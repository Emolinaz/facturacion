const db = require('../db/connection');

const listarClientes = (req, res) => {
  const sql = `
    SELECT cl.cod_cliente, p.nombre_persona AS nombre, cl.rtn
    FROM clientes cl
    INNER JOIN personas p ON cl.cod_persona = p.dni
  `;
  db.query(sql, (err, rows) => {
    if (err) return res.status(500).json({ error: 'Error al obtener clientes' });
    res.json(rows);
  });
};

module.exports = { listarClientes };
