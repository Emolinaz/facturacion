<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sistema de Facturación Chiminike</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="{{ asset('css/role-styles.css') }}">
    <link rel="stylesheet" href="{{ asset('css/admin.css') }}">
 
    <!-- Agregar jsPDF para generar PDFs -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.28/jspdf.plugin.autotable.min.js"></script>
</head>
<body>
    <!-- Sidebar -->
    <div class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <img src="../img/LogoChiminike.png" alt="Chiminike Logo" class="sidebar-logo">
            <span class="sidebar-title">Chiminike</span>
        </div>
        
        <div class="sidebar-menu">
            <div class="menu-item active" data-page="dashboard">
                <i class="fas fa-tachometer-alt"></i>
                <span>Panel Principal</span>
            </div>
            <div class="menu-item" data-page="reportes-sistema">
                <i class="fas fa-clipboard-list"></i>
                <span>Reportes del Sistema</span>
            </div>
           <div class="menu-item" data-page="botonesfacturas">
                <i class="fas fa-file-invoice"></i>
                <span>Generador de Facturas</span>
            </div>
            <div class="menu-item" data-page="facturas">
                <i class="fas fa-file-invoice"></i>
                <span>Facturas</span>
            </div>
            <div class="menu-item" data-page="CAI">
                <i class="fas fa-file-invoice"></i>
                <span>CAI</span>
            </div>
            <div class="menu-item" data-page="Correlativo">
                <i class="fas fa-file-invoice"></i>
                <span>Correlativo de Facturacion</span>
            </div>

            <div class="menu-item" data-page="eventos">
                <i class="fas fa-calendar-alt"></i>
                <span>Espacio de Alquiler</span>
            </div>
            <div class="menu-item" data-page="reservaciones">
                <i class="fas fa-ticket-alt"></i>
                <span>Reservaciones</span>
            </div>
            <div class="menu-item" data-page="clientes">
                <i class="fas fa-users"></i>
                <span>Clientes</span>
            </div>
            <div class="menu-item" data-page="reportes">
                <i class="fas fa-chart-bar"></i>
                <span>Reportes</span>
            </div>
            <div class="menu-item" data-page="empleados">
                <i class="fas fa-user-tie"></i>
                <span>Gestión de Empleados</span>
            </div>
            <div class="menu-item" data-page="inventario">
                <i class="fas fa-boxes"></i>
                <span>Inventario</span>
            </div>
            <div class="menu-item" data-page="cotizaciones">
                <i class="fas fa-file-invoice-dollar"></i>
                <span>Cotizaciones</span>
            </div>
            
            
        </div>
    </div>
    
    <!-- Main Content -->
    <div class="main-content" id="main-content">
        <!-- Header -->
        <div class="header">
            <button class="toggle-sidebar" id="toggle-sidebar">
                <i class="fas fa-bars"></i>
            </button>
            
            <div class="user-menu">
                <button class="notification-btn">
                    <i class="fas fa-bell"></i>
                </button>
                <div class="user-dropdown">
                    <button class="user-btn">
                        <span class="user-name">Carlos Mendoza</span>
                        <i class="fas fa-user"></i>
                    </button>
                    <div class="user-dropdown-content">
                        <a href="#" id="perfil-link"><i class="fas fa-id-card"></i> Mi Perfil</a>
                     
                        <div class="role-indicator-menu">
                            <i class="fas fa-user-tag"></i> <span id="current-role">Rol: Direccion</span>
                        </div>
                        <div class="dropdown-divider"></div>
                     
                        <a href="login.html"><i class="fas fa-sign-out-alt"></i> Cerrar Sesión</a>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Content Container -->
        <div id="content-container">
            <!-- El contenido se cargará dinámicamente aquí -->
        </div>
    </div>
    
    <script>
        // Toggle Sidebar
        document.getElementById("toggle-sidebar").addEventListener("click", () => {
            document.getElementById("sidebar").classList.toggle("active");
        });

        // Función para cargar una página
      // Reemplaza la función loadPage con esta versión corregida
async function loadPage(pageId) {
    try {
        // Actualizar menú activo
        document.querySelectorAll(".menu-item").forEach((item) => {
            item.classList.remove("active");
            if (item.getAttribute("data-page") === pageId) {
                item.classList.add("active");
            }
        });

        // Cargar el contenido de la página usando rutas Laravel
        const response = await fetch(`/admin/${pageId}`);
        if (!response.ok) throw new Error(`Error al cargar la página: ${response.status}`);
        
        const html = await response.text();
        document.getElementById("content-container").innerHTML = html;
    } catch (error) {
        console.error("Error al cargar la página:", error);
        document.getElementById("content-container").innerHTML = `
            <div class="content">
                <h1 class="content-title">Error</h1>
                <p>No se pudo cargar la página. Por favor, intente de nuevo.</p>
            </div>
        `;
    }
}

        // Configurar navegación del menú
        document.querySelectorAll(".menu-item").forEach(item => {
            item.addEventListener("click", function() {
                loadPage(this.getAttribute("data-page"));
            });
        });

        // Configurar menú de usuario
        const userBtn = document.querySelector(".user-btn");
        const userDropdown = document.querySelector(".user-dropdown-content");
        const perfilLink = document.getElementById("perfil-link");

        if (userBtn && userDropdown) {
            userBtn.addEventListener("click", (e) => {
                e.stopPropagation();
                userDropdown.classList.toggle("show");
            });

            window.addEventListener("click", () => {
                userDropdown.classList.remove("show");
            });
        }

        if (perfilLink) {
            perfilLink.addEventListener("click", (e) => {
                e.preventDefault();
                loadPage("perfil");
                if (userDropdown) userDropdown.classList.remove("show");
            });
        }

        // Cargar dashboard al iniciar
        document.addEventListener("DOMContentLoaded", () => {
            loadPage("dashboard");
        });
    </script>
</body>
</html>