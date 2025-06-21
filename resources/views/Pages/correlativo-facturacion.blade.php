<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Correlativo de Facturación - Sistema Chiminike</title>
    
    <!-- CSS -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="/css/styles.css" rel="stylesheet">
    <link href="/css/modales.css" rel="stylesheet">
    <link href="/css/correlativo-facturacion.css" rel="stylesheet">
</head>
<body>

    <!-- Contenido original SIN MODIFICAR -->
    <div class="page-header">
        <h2>Correlativo de Facturación</h2>
        <button class="btn-primary" onclick="openCorrelativoModal()">
            <i class="fas fa-plus"></i> Nuevo Correlativo
        </button>
    </div>

    <div class="info-section">
        <div class="info-card">
            <i class="fas fa-info-circle"></i>
            <div>
                <h4>Información Importante</h4>
                <p>Los correlativos de facturación son secuencias numéricas autorizadas por la SAR para la emisión de facturas. Cada correlativo tiene un rango específico y fechas de vigencia.</p>
            </div>
        </div>
    </div>

    <div class="table-container">
        <table class="data-table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Número Correlativo Factura</th>
                    <th>Fecha Inicio</th>
                    <th>Fecha Final</th>
                    <th>Rango Autorizado</th>
                    <th>Facturas Emitidas</th>
                    <th>Estado</th>
                    <th>Acciones</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>1</td>
                    <td>001-001-01-000001</td>
                    <td>01/01/2024</td>
                    <td>31/12/2024</td>
                    <td>1 - 10000</td>
                    <td>156</td>
                    <td><span class="status active">Activo</span></td>
                    <td>
                        <button class="btn-sm btn-edit" onclick="editCorrelativo(1)">Editar</button>
                        <button class="btn-sm btn-view">Ver Detalles</button>
                    </td>
                </tr>
                <tr>
                    <td>2</td>
                    <td>001-001-01-010001</td>
                    <td>01/01/2025</td>
                    <td>31/12/2025</td>
                    <td>10001 - 20000</td>
                    <td>0</td>
                    <td><span class="status pending">Pendiente</span></td>
                    <td>
                        <button class="btn-sm btn-edit" onclick="editCorrelativo(2)">Editar</button>
                        <button class="btn-sm btn-view">Ver Detalles</button>
                    </td>
                </tr>
                <tr>
                    <td>3</td>
                    <td>001-001-01-020001</td>
                    <td>15/06/2023</td>
                    <td>14/06/2024</td>
                    <td>20001 - 25000</td>
                    <td>5000</td>
                    <td><span class="status cancelled">Vencido</span></td>
                    <td>
                        <button class="btn-sm btn-view">Ver Detalles</button>
                        <button class="btn-sm btn-delete">Eliminar</button>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>

    <!-- Scripts -->
    <script src="/js/main.js"></script>
    <script src="/js/modales.js"></script>
    <script src="/js/correlativo-facturacion.js"></script>
    <script src="/js/correlativo-modal.js"></script>
    
    <!-- Script para funciones de Correlativos -->
    <script>
    // Función para abrir modal de Correlativo
    function openCorrelativoModal() {
        // Implementación para abrir el modal
        console.log('Modal Correlativo abierto');
        document.getElementById('modalCorrelativo').style.display = 'block';
    }
    
    // Función para editar Correlativo
    function editCorrelativo(id) {
        // Implementación para editar Correlativo
        console.log('Editando Correlativo con ID:', id);
        document.getElementById('modalEditarCorrelativo').style.display = 'block';
    }
    
    // Cerrar modales al hacer clic fuera
    window.addEventListener('click', function(event) {
        if (event.target.classList.contains('modal')) {
            event.target.style.display = 'none';
        }
    });
    </script>
</body>
</html>