<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Sistema de Facturas</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <!-- CSS Principal -->
    <link rel="stylesheet" href="/css/styles.css">
    <link rel="stylesheet" href="/css/modales.css">
</head>
<body>
    <div class="dashboard-container">
        <!-- Sidebar -->
        <aside class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <div class="logo">
                    <i class="fas fa-cube"></i>
                    <span class="logo-text">Mi App</span>
                </div>
                <button class="sidebar-toggle" id="sidebarToggle">
                    <i class="fas fa-bars"></i>
                </button>
            </div>
            
            <nav class="sidebar-nav">
                <ul class="nav-menu">
                    <!-- Dropdown de Facturas -->
                    <li class="nav-item dropdown">
                        <a href="#" class="nav-link dropdown-toggle" id="facturasDropdown">
                            <i class="fas fa-file-invoice-dollar"></i>
                            <span class="nav-text">Facturas</span>
                            <i class="fas fa-chevron-down dropdown-arrow"></i>
                        </a>
                        <ul class="dropdown-menu" id="facturasSubmenu">
                            <li>
                                <a href="/generador-facturas" class="dropdown-link" data-page="generador-facturas">
                                    <i class="fas fa-plus-circle"></i>
                                    <span>Generador de Facturas</span>
                                </a>
                            </li>
                            <li>
                                <a href="/registro-facturas" class="dropdown-link" data-page="registro-facturas">
                                    <i class="fas fa-list"></i>
                                    <span>Registro de Facturas</span>
                                </a>
                            </li>
                            <li>
                                <a href="/correlativo-facturacion" class="dropdown-link" data-page="correlativo-facturacion">
                                    <i class="fas fa-sort-numeric-up"></i>
                                    <span>Correlativo de Facturación</span>
                                </a>
                            </li>
                            <li>
                                <a href="/cai" class="dropdown-link" data-page="cai">
                                    <i class="fas fa-certificate"></i>
                                    <span>CAI</span>
                                </a>
                            </li>
                            
                        </ul>
                    </li>
                </ul>
            </nav>
            
            <div class="sidebar-footer">
                <div class="user-info">
                    <div class="user-avatar">
                        <i class="fas fa-user"></i>
                    </div>
                    <div class="user-details">
                        <span class="user-name">Juan Pérez</span>
                        <span class="user-role">Administrador</span>
                    </div>
                </div>
            </div>
        </aside>

        <!-- Main Content -->
        <div class="main-content">
            <!-- Header -->
            <header class="header">
                <div class="header-left">
                    <button class="mobile-menu-toggle" id="mobileMenuToggle">
                        <i class="fas fa-bars"></i>
                    </button>
                    <h1 class="page-title" id="pageTitle">Generador de Facturas</h1>
                </div>
                
                <div class="header-right">
                    <div class="header-actions">
                        <button class="header-btn">
                            <i class="fas fa-bell"></i>
                            <span class="notification-badge">3</span>
                        </button>
                        <button class="header-btn">
                            <i class="fas fa-envelope"></i>
                        </button>
                        <div class="user-menu">
                            <button class="user-menu-toggle">
                                <img src="https://via.placeholder.com/32" alt="Usuario" class="user-avatar-small">
                                <i class="fas fa-chevron-down"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </header>

            <!-- Content Area -->
            <main class="content" id="mainContent">
                <!-- El contenido se carga dinámicamente aquí -->
            </main>
        </div>
    </div>

    <!-- Scripts Principales -->
    <script src="/js/main.js"></script>
    <script src="/js/modales.js"></script>
    <script src="/js/facturas-modales.js"></script>
    <script src="/js/correlativo-modal.js"></script>
    <script src="/js/cai-modal.js"></script>
    
    <!-- Script para el dropdown -->
    <script>
    // Script para el funcionamiento del dropdown (debe estar en main.js)
    document.addEventListener('DOMContentLoaded', function() {
        const dropdownToggle = document.getElementById('facturasDropdown');
        const dropdownMenu = document.getElementById('facturasSubmenu');
        
        dropdownToggle.addEventListener('click', function(e) {
            e.preventDefault();
            dropdownMenu.classList.toggle('show');
        });
        
        // Cerrar dropdown al hacer click fuera
        document.addEventListener('click', function(e) {
            if (!dropdownToggle.contains(e.target)) {
                dropdownMenu.classList.remove('show');
            }
        });
    });
    </script>
</body>
</html>