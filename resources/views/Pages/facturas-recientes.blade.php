<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Facturas Recientes - Sistema Chiminike</title>
    
    <!-- CSS -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="/css/styles.css" rel="stylesheet">
    <link href="/css/modales.css" rel="stylesheet">
    <link href="/css/facturas-recientes.css" rel="stylesheet">
</head>
<body>

    <!-- Contenido original SIN MODIFICAR -->
    <div class="page-header">
        <h2>Facturas Recientes</h2>
        <div class="quick-stats">
            <div class="quick-stat">
                <span class="stat-value">12</span>
                <span class="stat-label">Hoy</span>
            </div>
            <div class="quick-stat">
                <span class="stat-value">45</span>
                <span class="stat-label">Esta semana</span>
            </div>
            <div class="quick-stat">
                <span class="stat-value">156</span>
                <span class="stat-label">Este mes</span>
            </div>
        </div>
    </div>

    <div class="recent-grid">
        <!-- Tarjeta 1 -->
        <div class="recent-card">
            <div class="card-header">
                <span class="invoice-number">FAC-001-2024</span>
                <span class="invoice-date">15/12/2024</span>
            </div>
            <div class="card-body">
                <h4>Producciones XYZ</h4>
                <p class="invoice-type">Factura de Eventos</p>
                <p class="invoice-amount">L. 15,500.00</p>
            </div>
            <div class="card-footer">
                <span class="status paid">Pagada</span>
                <div class="card-actions">
                    <button class="btn-sm btn-view">Ver</button>
                    <button class="btn-sm btn-print">PDF</button>
                </div>
            </div>
        </div>
        
        <!-- Tarjeta 2 -->
        <div class="recent-card">
            <div class="card-header">
                <span class="invoice-number">FAC-002-2024</span>
                <span class="invoice-date">14/12/2024</span>
            </div>
            <div class="card-body">
                <h4>Teatro Nacional</h4>
                <p class="invoice-type">Factura de Taquilla</p>
                <p class="invoice-amount">L. 8,750.00</p>
            </div>
            <div class="card-footer">
                <span class="status pending">Pendiente</span>
                <div class="card-actions">
                    <button class="btn-sm btn-view">Ver</button>
                    <button class="btn-sm btn-print">PDF</button>
                </div>
            </div>
        </div>
        
        <!-- Tarjeta 3 -->
        <div class="recent-card">
            <div class="card-header">
                <span class="invoice-number">FAC-003-2024</span>
                <span class="invoice-date">13/12/2024</span>
            </div>
            <div class="card-body">
                <h4>Colegio San José</h4>
                <p class="invoice-type">Recorridos Escolares</p>
                <p class="invoice-amount">L. 5,000.00</p>
            </div>
            <div class="card-footer">
                <span class="status paid">Pagada</span>
                <div class="card-actions">
                    <button class="btn-sm btn-view">Ver</button>
                    <button class="btn-sm btn-print">PDF</button>
                </div>
            </div>
        </div>
        
        <!-- Tarjeta 4 -->
        <div class="recent-card">
            <div class="card-header">
                <span class="invoice-number">FAC-004-2024</span>
                <span class="invoice-date">12/12/2024</span>
            </div>
            <div class="card-body">
                <h4>SpaceX Honduras</h4>
                <p class="invoice-type">Rocket Lab</p>
                <p class="invoice-amount">L. 1,000,000.00</p>
            </div>
            <div class="card-footer">
                <span class="status cancelled">Cancelada</span>
                <div class="card-actions">
                    <button class="btn-sm btn-view">Ver</button>
                    <button class="btn-sm btn-delete">Eliminar</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="/js/main.js"></script>
    <script src="/js/modales.js"></script>
    <script src="/js/facturas-recientes.js"></script>
    
    <!-- Script para funcionalidad específica -->
    <script>
    // Asignar eventos a los botones de acción
    document.addEventListener('DOMContentLoaded', function() {
        // Botones Ver
        document.querySelectorAll('.btn-view').forEach(button => {
            button.addEventListener('click', function() {
                const invoiceNumber = this.closest('.recent-card').querySelector('.invoice-number').textContent;
                window.location.href = `/factura/${encodeURIComponent(invoiceNumber)}`;
            });
        });
        
        // Botones PDF
        document.querySelectorAll('.btn-print').forEach(button => {
            button.addEventListener('click', function() {
                const invoiceNumber = this.closest('.recent-card').querySelector('.invoice-number').textContent;
                window.open(`/factura/${encodeURIComponent(invoiceNumber)}/pdf`, '_blank');
            });
        });
        
        // Botones Eliminar
        document.querySelectorAll('.btn-delete').forEach(button => {
            button.addEventListener('click', function() {
                const invoiceNumber = this.closest('.recent-card').querySelector('.invoice-number').textContent;
                if(confirm(`¿Está seguro de eliminar la factura ${invoiceNumber}?`)) {
                    // Lógica para eliminar
                    console.log(`Eliminando factura: ${invoiceNumber}`);
                }
            });
        });
    });
    </script>
</body>
</html>