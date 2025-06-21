<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de CAI - Sistema Chiminike</title>
    
    <!-- CSS -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="/css/styles.css" rel="stylesheet">
    <link href="/css/modales.css" rel="stylesheet">
    <link href="/css/cai.css" rel="stylesheet">
</head>
<body>

    <!-- Contenido original SIN MODIFICAR -->
    <div class="page-header">
        <h2>Gestión de CAI</h2>
        <button class="btn-primary" onclick="openCAIModal()">
            <i class="fas fa-plus"></i> Nuevo CAI
        </button>
    </div>

    <div class="info-section">
        <div class="info-card">
            <i class="fas fa-info-circle"></i>
            <div>
                <h4>Código de Autorización de Impresión (CAI)</h4>
                <p>El CAI es un código único autorizado por la SAR que permite la impresión de documentos fiscales. Cada CAI tiene un período de vigencia específico y debe renovarse antes de su vencimiento.</p>
            </div>
        </div>
    </div>

    <div class="table-container">
        <table class="data-table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>CAI</th>
                    <th>Fecha Inicio</th>
                    <th>Fecha Final</th>
                    <th>Estado</th>
                    <th>Días Restantes</th>
                    <th>Acciones</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>1</td>
                    <td>A1B2C3D4-E5F6-7890-ABCD-123456789012</td>
                    <td>01/01/2024</td>
                    <td>31/12/2024</td>
                    <td><span class="status active">Activo</span></td>
                    <td>15 días</td>
                    <td>
                        <button class="btn-sm btn-edit" onclick="editCAI(1)">Editar</button>
                        <button class="btn-sm btn-view">Ver Detalles</button>
                    </td>
                </tr>
                <tr>
                    <td>2</td>
                    <td>B2C3D4E5-F6G7-8901-BCDE-234567890123</td>
                    <td>01/01/2025</td>
                    <td>31/12/2025</td>
                    <td><span class="status pending">Pendiente</span></td>
                    <td>380 días</td>
                    <td>
                        <button class="btn-sm btn-edit" onclick="editCAI(2)">Editar</button>
                        <button class="btn-sm btn-view">Ver Detalles</button>
                    </td>
                </tr>
                <tr>
                    <td>3</td>
                    <td>C3D4E5F6-G7H8-9012-CDEF-345678901234</td>
                    <td>15/06/2023</td>
                    <td>14/06/2024</td>
                    <td><span class="status cancelled">Vencido</span></td>
                    <td>Vencido</td>
                    <td>
                        <button class="btn-sm btn-view">Ver Detalles</button>
                        <button class="btn-sm btn-delete">Eliminar</button>
                    </td>
                </tr>
                <tr>
                    <td>4</td>
                    <td>D4E5F6G7-H8I9-0123-DEFG-456789012345</td>
                    <td>01/11/2024</td>
                    <td>31/01/2025</td>
                    <td><span class="status active">Activo</span></td>
                    <td>45 días</td>
                    <td>
                        <button class="btn-sm btn-edit" onclick="editCAI(4)">Editar</button>
                        <button class="btn-sm btn-view">Ver Detalles</button>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>

    <!-- Scripts -->
    <script src="/js/main.js"></script>
    <script src="/js/modales.js"></script>
    <script src="/js/cai.js"></script>
    <script src="/js/cai-modal.js"></script>
    
    <!-- Script para funciones CAI -->
    <script>
    // Función para abrir modal de CAI
    function openCAIModal() {
        // Implementación para abrir el modal
        console.log('Modal CAI abierto');
        document.getElementById('modalCAI').style.display = 'block';
    }
    
    // Función para editar CAI
    function editCAI(id) {
        // Implementación para editar CAI
        console.log('Editando CAI con ID:', id);
        document.getElementById('modalEditarCAI').style.display = 'block';
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