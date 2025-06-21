const express = require('express');
const cors = require('cors');
require('./db/connection');

const facturaRoutes = require('./routes/factura.routes');
const detalleRoutes = require('./routes/detalle.routes');
const exportRoutes = require('./routes/export.routes');
const boletosRoutes = require('./routes/boletos.routes');
const clientesRoutes = require('./routes/clientes.routes');
const empleadosRoutes = require('./routes/empleados.routes');
const productosRoutes = require('./routes/productos.routes');
const eventosRoutes = require('./routes/eventos.routes');
const caiRoutes = require('./routes/cai.routes');
const estadisticasRoutes = require('./routes/estadisticas.routes');

const app = express();
const port = process.env.PORT || 3001;

app.use(express.json());
app.use(cors());

app.get('/', (req, res) => {
  res.send('🎉 API de Facturas Node.js funcionando');
});

app.use('/api/facturas', facturaRoutes);
app.use('/api/detalles', detalleRoutes);
app.use('/api/export', exportRoutes);
app.use('/api/boletos-taquilla', boletosRoutes);
app.use('/api/clientes', clientesRoutes);
app.use('/api/empleados', empleadosRoutes);
app.use('/api/productos', productosRoutes);
app.use('/api/eventos', eventosRoutes);
app.use('/api/cai', caiRoutes);
app.use('/api', estadisticasRoutes);

app.listen(port, () => {
  console.log(`Servidor corriendo en http://localhost:${port}`);
});
