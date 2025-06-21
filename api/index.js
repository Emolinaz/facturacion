const express = require('express');
const cors = require('cors');
const mysql = require('mysql2');
const app = express();
const port = 3001;

app.use(express.json());
app.use(cors());

const connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',  // Cambia a tu clave real si usas contraseña
    database: 'base_funcional'
});

connection.connect((err) => {
    if (err) {
        console.error('Error al conectar a la base de datos:', err);
    } else {
        console.log('Conectado a la base de datos MySQL!');
    }
});

// ----------- RUTAS -----------

// Ruta de prueba
app.get('/', (req, res) => {
    res.send('🎉 API de Facturas Node.js funcionando');
});

// 🔹 Boletos de taquilla (para select)
app.get('/api/boletos-taquilla', (req, res) => {
    connection.query('SELECT * FROM boletos_taquilla WHERE activo = 1', (err, rows) => {
        if (err) return res.status(500).json({error: 'Error al obtener boletos'});
        res.json(rows);
    });
});

// 🔹 Clientes (para select)
app.get('/api/clientes', (req, res) => {
    connection.query(`
        SELECT cl.cod_cliente, p.nombre_persona AS nombre, cl.rtn 
        FROM clientes cl 
        INNER JOIN personas p ON cl.cod_persona = p.dni
    `, (err, rows) => {
        if (err) return res.status(500).json({error: 'Error al obtener clientes'});
        res.json(rows);
    });
});

// 🔹 Empleados (para select)
app.get('/api/empleados', (req, res) => {
    connection.query(`
        SELECT emp.cod_empleado, p.nombre_persona AS nombre, emp.cargo 
        FROM empleados emp 
        INNER JOIN personas p ON emp.cod_empleado = p.dni
    `, (err, rows) => {
        if (err) return res.status(500).json({error: 'Error al obtener empleados'});
        res.json(rows);
    });
});

// 🔹 Productos (con precio real de precios_productos)
app.get('/api/productos', (req, res) => {
    const query = `
        SELECT cod_producto, nombre, descripcion, tipo, activo, precio
        FROM productos
        WHERE activo = 1
    `;
    connection.query(query, (err, rows) => {
        if (err) return res.status(500).json({ error: 'Error al obtener productos' });
        res.json(rows);
    });
});


// 🔹 Eventos (para select)
app.get('/api/eventos', (req, res) => {
    connection.query('SELECT * FROM eventos', (err, rows) => {
        if (err) return res.status(500).json({error: 'Error al obtener eventos'});
        res.json(rows);
    });
});

// 🔹 CAI activos (para select)
app.get('/api/cai', (req, res) => {
    connection.query('SELECT * FROM cai WHERE activo = 1', (err, rows) => {
        if (err) return res.status(500).json({error: 'Error al obtener CAI'});
        res.json(rows);
    });
});

// 🔹 Estadísticas de facturas
app.get('/api/facturas/estadisticas', (req, res) => {
    connection.query(`
        SELECT 
            COUNT(*) AS total_facturas, 
            IFNULL(SUM(total), 0) AS total_facturado
        FROM facturas 
        WHERE MONTH(fecha_emision) = MONTH(CURRENT_DATE())
    `, (err, rows) => {
        if (err) return res.status(500).json({error: 'Error al obtener estadísticas'});
        res.json(rows[0]);
    });
});

// 🔵 Obtener todas las facturas (con productos y boletos si aplica)
app.get('/api/facturas', (req, res) => {
    const queryFacturas = `
      SELECT f.*, 
        c.nombre_persona AS cliente,
        e.nombre_persona AS empleado,
        ev.nombre AS evento
      FROM facturas f
      LEFT JOIN clientes cl ON f.cod_cliente = cl.cod_cliente
      LEFT JOIN personas c ON cl.cod_persona = c.dni
      LEFT JOIN empleados emp ON f.cod_empleado = emp.cod_empleado
      LEFT JOIN personas e ON emp.cod_empleado = e.dni
      LEFT JOIN eventos ev ON f.cod_evento = ev.cod_evento
      ORDER BY f.cod_factura DESC
    `;

    connection.query(queryFacturas, async (err, facturas) => {
        if (err) return res.status(500).json({ error: 'Error al obtener facturas', details: err });

        // Para cada factura, buscar sus detalles de productos y boletos
        const promises = facturas.map(factura => {
            return new Promise((resolve, reject) => {
                // Productos
                connection.query(
                    `SELECT fp.*, p.nombre 
                    FROM factura_productos fp 
                    INNER JOIN productos p ON fp.cod_producto = p.cod_producto
                    WHERE fp.cod_factura = ?`,
                    [factura.cod_factura], (err, productos) => {
                    if (err) return reject(err);
                    factura.productos = productos;

                    // Boletos (solo si es de taquilla)
                    if (factura.tipo_factura === 'taquilla') {
                        connection.query(
                            `SELECT fbt.*, bt.tipo, bt.descripcion 
                             FROM factura_boletos_taquilla fbt
                             INNER JOIN boletos_taquilla bt ON fbt.cod_boleto = bt.cod_boleto
                             WHERE fbt.cod_factura = ?`,
                            [factura.cod_factura], (err, boletos) => {
                                if (err) return reject(err);
                                factura.boletos = boletos;
                                resolve();
                        });
                    } else {
                        factura.boletos = [];
                        resolve();
                    }
                });
            });
        });

        try {
            await Promise.all(promises);
            res.json(facturas);
        } catch (err) {
            res.status(500).json({ error: 'Error al obtener detalles de las facturas', details: err });
        }
    });
});

// 🔵 Obtener UNA factura por ID (con productos y boletos)
app.get('/api/facturas/:id', (req, res) => {
    const cod_factura = req.params.id;
    const queryFactura = `
      SELECT f.*, 
        c.nombre_persona AS cliente,
        e.nombre_persona AS empleado,
        ev.nombre AS evento
      FROM facturas f
      LEFT JOIN clientes cl ON f.cod_cliente = cl.cod_cliente
      LEFT JOIN personas c ON cl.cod_persona = c.dni
      LEFT JOIN empleados emp ON f.cod_empleado = emp.cod_empleado
      LEFT JOIN personas e ON emp.cod_empleado = e.dni
      LEFT JOIN eventos ev ON f.cod_evento = ev.cod_evento
      WHERE f.cod_factura = ?
    `;
    connection.query(queryFactura, [cod_factura], (err, results) => {
        if (err) return res.status(500).json({ error: 'Error al buscar factura', details: err });
        if (results.length === 0) return res.status(404).json({ error: 'Factura no encontrada' });
        const factura = results[0];

        // Productos
        connection.query(
            `SELECT fp.*, p.nombre 
            FROM factura_productos fp 
            INNER JOIN productos p ON fp.cod_producto = p.cod_producto
            WHERE fp.cod_factura = ?`, [cod_factura], (err, productos) => {
            if (err) return res.status(500).json({ error: 'Error al buscar productos', details: err });
            factura.productos = productos;

            // Boletos (si aplica)
            if (factura.tipo_factura === 'taquilla') {
                connection.query(
                    `SELECT fbt.*, bt.tipo, bt.descripcion 
                     FROM factura_boletos_taquilla fbt
                     INNER JOIN boletos_taquilla bt ON fbt.cod_boleto = bt.cod_boleto
                     WHERE fbt.cod_factura = ?`,
                    [cod_factura], (err, boletos) => {
                        if (err) return res.status(500).json({ error: 'Error al buscar boletos', details: err });
                        factura.boletos = boletos;
                        res.json(factura);
                });
            } else {
                factura.boletos = [];
                res.json(factura);
            }
        });
    });
});

// 🟢 CREAR factura (con correlativo Y precio real de productos)
app.post('/api/facturas', (req, res) => {
    const {
        cod_evento, cod_cliente, cod_empleado, cod_cai, tipo_factura,
        fecha_emision, subtotal,
        importe_gravado_15, impuesto_15, importe_gravado_18 = 0, impuesto_18 = 0,
        importe_exento = 0, rebaja_otorgada = 0, descuento_otorgado = 0, total, nota,
        productos = [], boletos = []
    } = req.body;

    // 1. Buscar correlativo actual para este CAI y tipo_factura
    const tipoFact = tipo_factura || null;
    connection.query(
        'SELECT * FROM correlativos_factura WHERE cod_cai = ? AND (tipo_factura = ? OR tipo_factura IS NULL) LIMIT 1',
        [cod_cai, tipoFact],
        (err, corrRows) => {
        if (err || corrRows.length === 0) return res.status(500).json({ error: 'Correlativo no encontrado para este CAI' });

        let numero_actual = parseInt(corrRows[0].numero_actual);
        let numero_factura = numero_actual.toString().padStart(5, '0');

        // 2. Insertar la factura
        const queryInsert = `
            INSERT INTO facturas (
                cod_evento, cod_cliente, cod_empleado, cod_cai, tipo_factura, 
                numero_factura, fecha_emision, subtotal, importe_gravado_15, impuesto_15,
                importe_gravado_18, impuesto_18, importe_exento,
                rebaja_otorgada, descuento_otorgado, total, nota
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `;
        const eventoVal = tipo_factura === 'evento' ? cod_evento : null;

        connection.query(queryInsert, [
            eventoVal, cod_cliente, cod_empleado, cod_cai, tipo_factura, numero_factura,
            fecha_emision, subtotal, importe_gravado_15, impuesto_15,
            importe_gravado_18, impuesto_18, importe_exento,
            rebaja_otorgada, descuento_otorgado, total, nota
        ], (err, result) => {
            if (err) return res.status(500).json({ error: 'Error al insertar factura', details: err });
            const cod_factura = result.insertId;

            // 3. Actualizar correlativo
            connection.query(
                'UPDATE correlativos_factura SET numero_actual = numero_actual + 1 WHERE id = ?',
                [corrRows[0].id]
            );

            // 4. Insertar productos y boletos
            const insertaProductos = () => new Promise((resolve, reject) => {
                if (Array.isArray(productos) && productos.length > 0) {
                    // Aquí aseguramos el precio desde precios_productos
                    const consultaPrecios = productos.map(
                        p => new Promise((resPrecio, rejPrecio) => {
                            connection.query(
                                `SELECT IFNULL(pp.precio, 0) AS precio
                                 FROM precios_productos pp
                                 WHERE pp.cod_producto = ? LIMIT 1`, [p.cod_producto], (err, rows) => {
                                    if (err) return rejPrecio(err);
                                    resPrecio({
                                        ...p,
                                        precio_unitario: rows[0] ? rows[0].precio : 0
                                    });
                                }
                            );
                        })
                    );
                    Promise.all(consultaPrecios).then(productosConPrecio => {
                        const data = productosConPrecio.map(p => [
                            cod_factura,
                            p.cod_producto,
                            p.cantidad,
                            p.precio_unitario,
                            p.total
                        ]);
                        connection.query(
                            `INSERT INTO factura_productos (cod_factura, cod_producto, cantidad, precio_unitario, total)
                             VALUES ?`, [data], err => {
                                if (err) return reject({ error: 'Factura creada, pero error al guardar productos', cod_factura, details: err });
                                resolve();
                            });
                    }).catch(reject);
                } else { resolve(); }
            });
            const insertaBoletos = () => new Promise((resolve, reject) => {
                if (Array.isArray(boletos) && boletos.length > 0) {
                    const data = boletos.map(b => [
                        cod_factura,
                        b.cod_boleto,
                        b.cantidad,
                        b.precio_unitario,
                        b.total
                    ]);
                    connection.query(
                        `INSERT INTO factura_boletos_taquilla (cod_factura, cod_boleto, cantidad, precio_unitario, total)
                         VALUES ?`, [data], err => {
                            if (err) return reject({ error: 'Factura creada, pero error al guardar boletos', cod_factura, details: err });
                            resolve();
                        });
                } else { resolve(); }
            });

            Promise.all([insertaProductos(), insertaBoletos()])
                .then(() => {
                    res.status(201).json({ message: 'Factura y detalles guardados', cod_factura, numero_factura });
                })
                .catch(error => res.status(500).json(error));
        });
    });
});

// 🟡 EDITAR factura y sus detalles (productos y boletos)
app.put('/api/facturas/:id', (req, res) => {
    const cod_factura = req.params.id;
    const {
        cod_evento, cod_cliente, cod_empleado, cod_cai, tipo_factura,
        numero_factura, fecha_emision, subtotal,
        importe_gravado_15, impuesto_15, importe_gravado_18 = 0, impuesto_18 = 0,
        importe_exento = 0, rebaja_otorgada = 0, descuento_otorgado = 0, total, nota,
        productos = [], boletos = []
    } = req.body;

    const eventoVal = tipo_factura === 'evento' ? cod_evento : null;
    const queryUpdate = `
        UPDATE facturas SET 
            cod_evento = ?, cod_cliente = ?, cod_empleado = ?, cod_cai = ?, tipo_factura = ?, 
            numero_factura = ?, fecha_emision = ?, subtotal = ?, importe_gravado_15 = ?, impuesto_15 = ?,
            importe_gravado_18 = ?, impuesto_18 = ?, importe_exento = ?,
            rebaja_otorgada = ?, descuento_otorgado = ?, total = ?, nota = ?
        WHERE cod_factura = ?
    `;
    connection.query(queryUpdate, [
        eventoVal, cod_cliente, cod_empleado, cod_cai, tipo_factura, numero_factura,
        fecha_emision, subtotal, importe_gravado_15, impuesto_15,
        importe_gravado_18, impuesto_18, importe_exento,
        rebaja_otorgada, descuento_otorgado, total, nota,
        cod_factura
    ], (err, result) => {
        if (err) return res.status(500).json({ error: 'Error al actualizar factura', details: err });

        // Borrar y volver a insertar detalles
        const borraProductos = () => new Promise((resolve, reject) => {
            connection.query(`DELETE FROM factura_productos WHERE cod_factura = ?`, [cod_factura], err => {
                if (err) return reject({ error: 'Factura actualizada, error al limpiar productos', cod_factura, details: err });
                resolve();
            });
        });
        const borraBoletos = () => new Promise((resolve, reject) => {
            connection.query(`DELETE FROM factura_boletos_taquilla WHERE cod_factura = ?`, [cod_factura], err => {
                if (err) return reject({ error: 'Factura actualizada, error al limpiar boletos', cod_factura, details: err });
                resolve();
            });
        });

        const insertaProductos = () => new Promise((resolve, reject) => {
            if (Array.isArray(productos) && productos.length > 0) {
                // Igual aseguramos el precio desde precios_productos
                const consultaPrecios = productos.map(
                    p => new Promise((resPrecio, rejPrecio) => {
                        connection.query(
                            `SELECT IFNULL(pp.precio, 0) AS precio
                             FROM precios_productos pp
                             WHERE pp.cod_producto = ? LIMIT 1`, [p.cod_producto], (err, rows) => {
                                if (err) return rejPrecio(err);
                                resPrecio({
                                    ...p,
                                    precio_unitario: rows[0] ? rows[0].precio : 0
                                });
                            }
                        );
                    })
                );
                Promise.all(consultaPrecios).then(productosConPrecio => {
                    const data = productosConPrecio.map(p => [
                        cod_factura,
                        p.cod_producto,
                        p.cantidad,
                        p.precio_unitario,
                        p.total
                    ]);
                    connection.query(
                        `INSERT INTO factura_productos (cod_factura, cod_producto, cantidad, precio_unitario, total)
                         VALUES ?`, [data], err => {
                            if (err) return reject({ error: 'Factura editada, pero error al actualizar productos', cod_factura, details: err });
                            resolve();
                        });
                }).catch(reject);
            } else { resolve(); }
        });
        const insertaBoletos = () => new Promise((resolve, reject) => {
            if (Array.isArray(boletos) && boletos.length > 0) {
                const data = boletos.map(b => [
                    cod_factura,
                    b.cod_boleto,
                    b.cantidad,
                    b.precio_unitario,
                    b.total
                ]);
                connection.query(
                    `INSERT INTO factura_boletos_taquilla (cod_factura, cod_boleto, cantidad, precio_unitario, total)
                     VALUES ?`, [data], err => {
                        if (err) return reject({ error: 'Factura editada, pero error al actualizar boletos', cod_factura, details: err });
                        resolve();
                    });
            } else { resolve(); }
        });

        Promise.all([borraProductos(), borraBoletos()])
            .then(() => Promise.all([insertaProductos(), insertaBoletos()]))
            .then(() => res.json({ message: 'Factura y detalles actualizados', cod_factura }))
            .catch(error => res.status(500).json(error));
    });
});

// 🟥 ELIMINAR factura
app.delete('/api/facturas/:id', (req, res) => {
    const cod_factura = req.params.id;
    connection.query(`DELETE FROM facturas WHERE cod_factura = ?`, [cod_factura], (err, result) => {
        if (err) return res.status(500).json({ error: 'Error al eliminar factura', details: err });
        if (result.affectedRows === 0) return res.status(404).json({ error: 'Factura no encontrada' });
        res.json({ message: 'Factura eliminada', cod_factura });
    });
});

// ------ FIN RUTAS -------

app.listen(port, () => {
    console.log(`Servidor corriendo en http://localhost:${port}`);
});

// Ruta de prueba adicional
app.get('/api/prueba', (req, res) => {
    res.json({ok: true, msg: 'El server SÍ responde'});
});
