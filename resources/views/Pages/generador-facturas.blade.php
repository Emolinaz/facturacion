<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Generador de Facturas</title>
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="/css/generador-facturas.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
</head>
<body>
<div class="container-factura">
    <h2>Generador de Facturas</h2>
    <div class="factura-cards">
        <div class="factura-card" data-modal="modalRecorrido">
            <i class="fas fa-bus fa-2x"></i>
            <h3>Factura Recorrido Escolar</h3>
            <button class="btn-invoice">Crear Factura</button>
        </div>
        <div class="factura-card" data-modal="modalTaquilla">
            <i class="fas fa-ticket-alt fa-2x"></i>
            <h3>Factura Taquilla General</h3>
            <button class="btn-invoice">Crear Factura</button>
        </div>
        <div class="factura-card" data-modal="modalEventos">
            <i class="fas fa-calendar-alt fa-2x"></i>
            <h3>Factura Eventos</h3>
            <button class="btn-invoice">Crear Factura</button>
        </div>
        <div class="factura-card" data-modal="modalLibros">
            <i class="fas fa-book fa-2x"></i>
            <h3>Factura Libros</h3>
            <button class="btn-invoice">Crear Factura</button>
        </div>
    </div>

    <!-- ======= MODAL RECORRIDO ESCOLAR ======= -->
    <div id="modalRecorrido" class="modal-factura">
        <div class="modal-content-factura">
            <span class="close">&times;</span>
            <h3>Factura Recorrido Escolar</h3>
            <form id="formRecorrido">
                <div class="grid-form">
                    <div>
                        <label>Cliente:</label>
                        <select id="cliente-recorrido" name="cliente" required></select>
                    </div>
                    <div>
                        <label>Empleado:</label>
                        <select id="empleado-recorrido" name="empleado" required></select>
                    </div>
                    <div>
                        <label>CAI:</label>
                        <select id="cai-recorrido" name="cai" required></select>
                    </div>
                    <div>
                        <label>Fecha Emisión:</label>
                        <input type="date" id="fecha-recorrido" name="fecha_emision" value="{{ date('Y-m-d') }}">
                    </div>
                </div>
                <div class="seccion-titulo">Boletos</div>
                <table class="tabla-detalle">
                    <thead>
                        <tr>
                            <th>Boleto</th>
                            <th>Cantidad</th>
                            <th>Precio Unitario</th>
                            <th>Total</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody id="boletos-container-recorrido"></tbody>
                </table>
                <button type="button" class="btn-add" id="agregar-boleto-recorrido">+ Añadir Boleto</button>
                <div class="totales-grid">
                    <div>Subtotal:</div><div id="subtotal-recorrido">L. 0.00</div>
                    <div>ISV 18%:</div><div id="isv-recorrido">L. 0.00</div>
                    <div>Total:</div><div id="total-recorrido">L. 0.00</div>
                </div>
                <div>
                    <label>Notas:</label>
                    <textarea id="nota-recorrido" name="nota"></textarea>
                </div>
                <button type="submit" class="btn-guardar">Generar Factura</button>
            </form>
        </div>
    </div>

    <!-- ======= MODAL TAQUILLA GENERAL ======= -->
    <div id="modalTaquilla" class="modal-factura">
        <div class="modal-content-factura">
            <span class="close">&times;</span>
            <h3>Factura Taquilla General</h3>
            <form id="formTaquilla">
                <div class="grid-form">
                    <div>
                        <label>Cliente:</label>
                        <select id="cliente-taquilla" name="cliente" required></select>
                    </div>
                    <div>
                        <label>Empleado:</label>
                        <select id="empleado-taquilla" name="empleado" required></select>
                    </div>
                    <div>
                        <label>CAI:</label>
                        <select id="cai-taquilla" name="cai" required></select>
                    </div>
                    <div>
                        <label>Fecha Emisión:</label>
                        <input type="date" id="fecha-taquilla" name="fecha_emision" value="{{ date('Y-m-d') }}">
                    </div>
                </div>
                <div class="seccion-titulo">Boletos</div>
                <table class="tabla-detalle">
                    <thead>
                        <tr>
                            <th>Boleto</th>
                            <th>Cantidad</th>
                            <th>Precio Unitario</th>
                            <th>Total</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody id="boletos-container-taquilla"></tbody>
                </table>
                <button type="button" class="btn-add" id="agregar-boleto-taquilla">+ Añadir Boleto</button>
                <div class="totales-grid">
                    <div>Subtotal:</div><div id="subtotal-taquilla">L. 0.00</div>
                    <div>ISV 18%:</div><div id="isv-taquilla">L. 0.00</div>
                    <div>Total:</div><div id="total-taquilla">L. 0.00</div>
                </div>
                <div>
                    <label>Notas:</label>
                    <textarea id="nota-taquilla" name="nota"></textarea>
                </div>
                <button type="submit" class="btn-guardar">Generar Factura</button>
            </form>
        </div>
    </div>

    <!-- ======= MODAL EVENTOS ======= -->
    <div id="modalEventos" class="modal-factura">
        <div class="modal-content-factura">
            <span class="close">&times;</span>
            <h3>Factura Eventos</h3>
            <form id="formEventos">
                <div class="grid-form">
                    <div>
                        <label>Evento:</label>
                        <select id="evento-eventos" name="evento" required></select>
                    </div>
                    <div>
                        <label>Cliente:</label>
                        <select id="cliente-eventos" name="cliente" required></select>
                    </div>
                    <div>
                        <label>Empleado:</label>
                        <select id="empleado-eventos" name="empleado" required></select>
                    </div>
                    <div>
                        <label>CAI:</label>
                        <select id="cai-eventos" name="cai" required></select>
                    </div>
                    <div>
                        <label>Fecha Emisión:</label>
                        <input type="date" id="fecha-eventos" name="fecha_emision" value="{{ date('Y-m-d') }}">
                    </div>
                </div>
                <div class="seccion-titulo">Productos/Servicios</div>
                <table class="tabla-detalle">
                    <thead>
                        <tr>
                            <th>Producto</th>
                            <th>Cantidad</th>
                            <th>Precio Unitario</th>
                            <th>Total</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody id="productos-container-eventos"></tbody>
                </table>
                <button type="button" class="btn-add" id="agregar-producto-eventos">+ Añadir Producto</button>
                <div class="totales-grid">
                    <div>Subtotal:</div><div id="subtotal-eventos">L. 0.00</div>
                    <div>ISV 18%:</div><div id="isv-eventos">L. 0.00</div>
                    <div>Total:</div><div id="total-eventos">L. 0.00</div>
                </div>
                <div>
                    <label>Notas:</label>
                    <textarea id="nota-eventos" name="nota"></textarea>
                </div>
                <button type="submit" class="btn-guardar">Generar Factura</button>
            </form>
        </div>
    </div>

    <!-- ======= MODAL LIBROS ======= -->
    <div id="modalLibros" class="modal-factura">
        <div class="modal-content-factura">
            <span class="close">&times;</span>
            <h3>Factura Libros</h3>
            <form id="formLibros">
                <div class="grid-form">
                    <div>
                        <label>Cliente:</label>
                        <select id="cliente-libros" name="cliente" required></select>
                    </div>
                    <div>
                        <label>Empleado:</label>
                        <select id="empleado-libros" name="empleado" required></select>
                    </div>
                    <div>
                        <label>CAI:</label>
                        <select id="cai-libros" name="cai" required></select>
                    </div>
                    <div>
                        <label>Fecha Emisión:</label>
                        <input type="date" id="fecha-libros" name="fecha_emision" value="{{ date('Y-m-d') }}">
                    </div>
                </div>
                <div class="seccion-titulo">Productos/Libros</div>
                <table class="tabla-detalle">
                    <thead>
                        <tr>
                            <th>Producto</th>
                            <th>Cantidad</th>
                            <th>Precio Unitario</th>
                            <th>Total</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody id="productos-container-libros"></tbody>
                </table>
                <button type="button" class="btn-add" id="agregar-producto-libros">+ Añadir Producto</button>
                <div class="totales-grid">
                    <div>Subtotal:</div><div id="subtotal-libros">L. 0.00</div>
                    <div>ISV 18%:</div><div id="isv-libros">L. 0.00</div>
                    <div>Total:</div><div id="total-libros">L. 0.00</div>
                </div>
                <div>
                    <label>Notas:</label>
                    <textarea id="nota-libros" name="nota"></textarea>
                </div>
                <button type="submit" class="btn-guardar">Generar Factura</button>
            </form>
        </div>
    </div>
</div>
<script src="/js/generador-facturas.js"></script>

</body>
</html>
