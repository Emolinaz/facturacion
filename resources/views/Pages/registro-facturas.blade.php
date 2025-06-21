<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Registro de Facturas</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- FontAwesome para los íconos -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
    <!-- Tu CSS personalizado -->
    <link href="/css/registro-facturas.css" rel="stylesheet">
    <!-- jsPDF para PDF -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
</head>
<body>
<div class="page-header">
    <h2>Registro de Facturas</h2>
    <button class="btn-primary" id="nuevaFacturaBtn">
        <i class="fas fa-plus"></i> Nueva Factura
    </button>
</div>
<div class="filters-section">
    <div class="filter-group">
        <label>Fecha Desde:</label>
        <input type="date" id="fechaDesde">
    </div>
    <div class="filter-group">
        <label>Fecha Hasta:</label>
        <input type="date" id="fechaHasta">
    </div>
    <div class="filter-group">
        <label>Tipo:</label>
        <select id="tipoFactura">
            <option value="">Todos</option>
            <option value="evento">Eventos</option>
            <option value="rocket_lab">Rocket Lab</option>
            <option value="taquilla">Taquilla</option>
            <option value="escolares">Escolares</option>
        </select>
    </div>
    <button class="btn-primary" id="filtrarBtn">Filtrar</button>
</div>
<div class="table-container">
    <table id="facturasTable">
        <thead>
            <tr>
                <th>N° Factura</th>
                <th>Fecha</th>
                <th>Tipo</th>
                <th>Cliente</th>
                <th>RTN Empresa</th>
                <th>Subtotal (L.)</th>
                <th>Total (L.)</th>
                <th>Acciones</th>
            </tr>
        </thead>
        <tbody>
            <!-- Dinámico -->
        </tbody>
    </table>
</div>
<!-- =========== MODAL DE VISTA =========== -->
<div class="modal" id="verFacturaModal">
  <div class="modal-content modal-factura">
    <span class="close" onclick="cerrarModal('verFacturaModal')">&times;</span>
    <div id="facturaVistaContent">
      <!-- Aquí se pone el contenido tipo plantilla Excel -->
    </div>
    <button class="btn-secondary" onclick="generarPDFVista()">Descargar PDF</button>
  </div>
</div>
<!-- =========== MODAL DE EDITAR =========== -->
<div class="modal" id="editarFacturaModal">
  <div class="modal-content modal-factura">
    <span class="close" onclick="cerrarModal('editarFacturaModal')">&times;</span>
    <h3>Editar Factura</h3>
    <form id="formEditarFactura">
      <!-- Aquí va el form generado por JS -->
    </form>
    <div style="text-align:right;margin-top:10px;">
      <button class="btn-primary" type="submit" form="formEditarFactura">Guardar Cambios</button>
    </div>
  </div>
</div>
<!-- =========== MODAL NUEVA FACTURA =========== -->
<div class="modal" id="nuevaFacturaModal">
  <div class="modal-content modal-factura">
    <span class="close" onclick="cerrarModal('nuevaFacturaModal')">&times;</span>
    <h3>Nueva Factura</h3>
    <form id="formNuevaFactura">
      <!-- Aquí va el form generado por JS -->
    </form>
    <div style="text-align:right;margin-top:10px;">
      <button class="btn-primary" type="submit" form="formNuevaFactura">Guardar Factura</button>
    </div>
  </div>
</div>
<script>
const API_BASE = 'http://localhost:3001/api';
let facturas = []; // Se guarda toda la data
// Cargar facturas
async function cargarFacturas() {
    try {
        const res = await fetch(`${API_BASE}/facturas`);
        facturas = await res.json();
        pintarTabla(facturas);
    } catch(e) {
        alert('Error al cargar facturas');
    }
}
function pintarTabla(data) {
    const tbody = document.querySelector('#facturasTable tbody');
    tbody.innerHTML = '';
    data.forEach(factura => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
          <td>${factura.numero_factura}</td>
          <td>${factura.fecha_emision ? new Date(factura.fecha_emision).toLocaleDateString() : ''}</td>
          <td>${formatoTipo(factura.tipo_factura)}</td>
          <td>${factura.cliente || ''}</td>
          <td>${factura.rtn_empresa || factura.rtn || ''}</td>
          <td>L. ${parseFloat(factura.subtotal).toFixed(2)}</td>
          <td>L. ${parseFloat(factura.total).toFixed(2)}</td>
          <td>
            <button class="btn-sm btn-view" onclick="verFactura(${factura.cod_factura})"><i class="fas fa-eye"></i></button>
            <button class="btn-sm btn-edit" onclick="editarFactura(${factura.cod_factura})"><i class="fas fa-pen"></i></button>
            <button class="btn-sm btn-print" onclick="generarPDFVista(${factura.cod_factura})"><i class="fas fa-file-pdf"></i></button>
          </td>
        `;
        tbody.appendChild(tr);
    });
}
function formatoTipo(tipo) {
    switch (tipo) {
        case 'evento': return 'Evento';
        case 'taquilla': return 'Taquilla';
        case 'rocket_lab': return 'Rocket Lab';
        case 'escolares': return 'Escolares';
        default: return tipo || '';
    }
}
// ========= MODAL DE VISTA =========
async function verFactura(id) {
    const factura = facturas.find(f => f.cod_factura == id);
    if (!factura) return;
    document.getElementById('facturaVistaContent').innerHTML = plantillaVistaFactura(factura);
    document.getElementById('verFacturaModal').style.display = 'block';
}
function cerrarModal(id) {
    document.getElementById(id).style.display = 'none';
}
// ========= MODAL DE EDITAR =========
async function editarFactura(id) {
    const factura = facturas.find(f => f.cod_factura == id);
    if (!factura) return;
    document.getElementById('formEditarFactura').innerHTML = plantillaFormEditar(factura);
    document.getElementById('editarFacturaModal').style.display = 'block';
    document.getElementById('formEditarFactura').onsubmit = async (e) => {
        e.preventDefault();
        // Procesar el update
        const form = e.target;
        let payload = Object.fromEntries(new FormData(form).entries());
        payload.cod_factura = id;
        // Si hay productos y boletos, parsearlos
        payload.productos = factura.productos;
        payload.boletos = factura.boletos;
        const res = await fetch(`${API_BASE}/facturas/${id}`, {
            method: 'PUT',
            headers: {'Content-Type':'application/json'},
            body: JSON.stringify(payload)
        });
        if (res.ok) {
            cerrarModal('editarFacturaModal');
            cargarFacturas();
        } else {
            alert('Error actualizando factura');
        }
    }
}
// ========== PLANTILLA DE VISTA ==========
function plantillaVistaFactura(f) {
    // Mostrando TODO como en Excel, adaptado a modal bonito
    let productos = '';
    if (Array.isArray(f.productos) && f.productos.length > 0) {
        productos = `<tr><th colspan="4">Productos</th></tr>
        <tr>
          <th>Producto</th><th>Cant.</th><th>Precio Unitario</th><th>Total</th>
        </tr>`;
        f.productos.forEach(p => {
            productos += `<tr>
              <td>${p.nombre}</td>
              <td>${p.cantidad}</td>
              <td>L. ${parseFloat(p.precio_unitario).toFixed(2)}</td>
              <td>L. ${parseFloat(p.total).toFixed(2)}</td>
            </tr>`;
        });
    }
    let boletos = '';
    if (Array.isArray(f.boletos) && f.boletos.length > 0) {
        boletos = `<tr><th colspan="4">Boletos</th></tr>
        <tr>
          <th>Tipo</th><th>Cant.</th><th>Precio Unitario</th><th>Total</th>
        </tr>`;
        f.boletos.forEach(b => {
            boletos += `<tr>
              <td>${b.tipo}</td>
              <td>${b.cantidad}</td>
              <td>L. ${parseFloat(b.precio_unitario).toFixed(2)}</td>
              <td>L. ${parseFloat(b.total).toFixed(2)}</td>
            </tr>`;
        });
    }
    return `
      <div class="factura-header">
        <h2>Factura N° ${f.numero_factura || ''}</h2>
        <p><strong>Fecha:</strong> ${f.fecha_emision ? new Date(f.fecha_emision).toLocaleDateString() : ''}</p>
      </div>
      <table class="tabla-factura">
        <tr>
          <td><strong>Cliente:</strong> ${f.cliente || ''}</td>
          <td><strong>RTN:</strong> ${f.rtn_empresa || f.rtn || ''}</td>
        </tr>
        <tr>
          <td><strong>Tipo:</strong> ${formatoTipo(f.tipo_factura)}</td>
          <td><strong>Evento:</strong> ${f.evento || '-'}</td>
        </tr>
        <tr>
          <td><strong>Empleado:</strong> ${f.empleado || ''}</td>
          <td><strong>CAI:</strong> ${f.cod_cai || ''}</td>
        </tr>
      </table>
      <table class="tabla-factura" style="margin-top:15px;">
        ${productos}
        ${boletos}
        <tr><td colspan="4"></td></tr>
        <tr><td colspan="3" style="text-align:right;"><strong>Subtotal</strong></td><td>L. ${parseFloat(f.subtotal).toFixed(2)}</td></tr>
        <tr><td colspan="3" style="text-align:right;">Impuesto 15%</td><td>L. ${parseFloat(f.impuesto_15).toFixed(2)}</td></tr>
        <tr><td colspan="3" style="text-align:right;">Impuesto 18%</td><td>L. ${parseFloat(f.impuesto_18).toFixed(2)}</td></tr>
        <tr><td colspan="3" style="text-align:right;">Exento</td><td>L. ${parseFloat(f.importe_exento).toFixed(2)}</td></tr>
        <tr><td colspan="3" style="text-align:right;"><strong>Total</strong></td><td><strong>L. ${parseFloat(f.total).toFixed(2)}</strong></td></tr>
      </table>
      <div style="margin-top:10px;"><strong>Nota:</strong> ${f.nota || ''}</div>
    `;
}
// ======= PLANTILLA DE EDITAR ===========
function plantillaFormEditar(f) {
    // Solo dejo campos básicos editables (los detalles normalmente en otro modal/tab)
    return `
      <label>Cliente:
        <input name="cliente" value="${f.cliente || ''}" required>
      </label>
      <label>RTN Empresa:
        <input name="rtn_empresa" value="${f.rtn_empresa || f.rtn || ''}">
      </label>
      <label>Tipo:
        <select name="tipo_factura">
          <option value="evento" ${f.tipo_factura=='evento'?'selected':''}>Evento</option>
          <option value="taquilla" ${f.tipo_factura=='taquilla'?'selected':''}>Taquilla</option>
          <option value="rocket_lab" ${f.tipo_factura=='rocket_lab'?'selected':''}>Rocket Lab</option>
          <option value="escolares" ${f.tipo_factura=='escolares'?'selected':''}>Escolares</option>
        </select>
      </label>
      <label>Empleado:
        <input name="empleado" value="${f.empleado || ''}">
      </label>
      <label>Fecha:
        <input type="date" name="fecha_emision" value="${f.fecha_emision ? f.fecha_emision.substr(0,10):''}">
      </label>
      <label>Subtotal:
        <input name="subtotal" type="number" step="0.01" value="${f.subtotal}">
      </label>
      <label>Impuesto 15%:
        <input name="impuesto_15" type="number" step="0.01" value="${f.impuesto_15}">
      </label>
      <label>Impuesto 18%:
        <input name="impuesto_18" type="number" step="0.01" value="${f.impuesto_18}">
      </label>
      <label>Exento:
        <input name="importe_exento" type="number" step="0.01" value="${f.importe_exento}">
      </label>
      <label>Total:
        <input name="total" type="number" step="0.01" value="${f.total}">
      </label>
      <label>Nota:
        <input name="nota" value="${f.nota || ''}">
      </label>
    `;
}
// ======= PDF (solo de la vista, usando jsPDF) =======
function generarPDFVista(id = null) {
    let f = null;
    if (id) {
        f = facturas.find(fa => fa.cod_factura == id);
    } else {
        // Modal abierto: busca la última vista
        const num = document.querySelector('#facturaVistaContent h2').innerText.match(/\d+$/);
        f = facturas.find(fa => fa.numero_factura == (num ? num[0] : ''));
    }
    if (!f) return alert('Factura no encontrada');
    const doc = new window.jspdf.jsPDF('p', 'pt', 'letter');
    let y = 40;
    doc.setFontSize(16);
    doc.text(`Factura N° ${f.numero_factura || ''}`, 40, y);
    y += 20;
    doc.setFontSize(10);
    doc.text(`Fecha: ${f.fecha_emision ? new Date(f.fecha_emision).toLocaleDateString() : ''}`, 40, y);
    y += 20;
    doc.text(`Cliente: ${f.cliente || ''}`, 40, y);
    doc.text(`RTN: ${f.rtn_empresa || f.rtn || ''}`, 320, y);
    y += 15;
    doc.text(`Tipo: ${formatoTipo(f.tipo_factura)}`, 40, y);
    doc.text(`Empleado: ${f.empleado || ''}`, 320, y);
    y += 15;
    doc.text(`CAI: ${f.cod_cai || ''}`, 40, y);
    doc.text(`Evento: ${f.evento || '-'}`, 320, y);
    y += 20;
    // Productos
    if (Array.isArray(f.productos) && f.productos.length > 0) {
        doc.text('Productos:', 40, y);
        y += 12;
        doc.text('Nombre', 40, y);
        doc.text('Cant.', 180, y);
        doc.text('P. Unitario', 240, y);
        doc.text('Total', 340, y);
        y += 12;
        f.productos.forEach(p => {
            doc.text(String(p.nombre), 40, y);
            doc.text(String(p.cantidad), 180, y);
            doc.text('L. ' + parseFloat(p.precio_unitario).toFixed(2), 240, y);
            doc.text('L. ' + parseFloat(p.total).toFixed(2), 340, y);
            y += 12;
        });
    }
    // Boletos
    if (Array.isArray(f.boletos) && f.boletos.length > 0) {
        y += 10;
        doc.text('Boletos:', 40, y);
        y += 12;
        doc.text('Tipo', 40, y);
        doc.text('Cant.', 180, y);
        doc.text('P. Unitario', 240, y);
        doc.text('Total', 340, y);
        y += 12;
        f.boletos.forEach(b => {
            doc.text(String(b.tipo), 40, y);
            doc.text(String(b.cantidad), 180, y);
            doc.text('L. ' + parseFloat(b.precio_unitario).toFixed(2), 240, y);
            doc.text('L. ' + parseFloat(b.total).toFixed(2), 340, y);
            y += 12;
        });
    }
    y += 15;
    doc.text('Subtotal:', 300, y); doc.text('L. ' + parseFloat(f.subtotal).toFixed(2), 380, y);
    y += 12;
    doc.text('Impuesto 15%:', 300, y); doc.text('L. ' + parseFloat(f.impuesto_15).toFixed(2), 380, y);
    y += 12;
    doc.text('Impuesto 18%:', 300, y); doc.text('L. ' + parseFloat(f.impuesto_18).toFixed(2), 380, y);
    y += 12;
    doc.text('Exento:', 300, y); doc.text('L. ' + parseFloat(f.importe_exento).toFixed(2), 380, y);
    y += 12;
    doc.setFontSize(13);
    doc.text('TOTAL:', 300, y); doc.text('L. ' + parseFloat(f.total).toFixed(2), 380, y);
    y += 20;
    doc.setFontSize(10);
    doc.text('Nota: ' + (f.nota || ''), 40, y);
    doc.save(`Factura_${f.numero_factura}.pdf`);
}
// ========== FILTRO ==========
document.getElementById('filtrarBtn').onclick = () => {
    const fd = document.getElementById('fechaDesde').value;
    const fh = document.getElementById('fechaHasta').value;
    const tipo = document.getElementById('tipoFactura').value;
    let filtrados = facturas;
    if (fd) filtrados = filtrados.filter(f => f.fecha_emision >= fd);
    if (fh) filtrados = filtrados.filter(f => f.fecha_emision <= fh);
    if (tipo) filtrados = filtrados.filter(f => f.tipo_factura === tipo);
    pintarTabla(filtrados);
}
// ========== NUEVA FACTURA (BONUS: solo muestra modal) ==========
document.getElementById('nuevaFacturaBtn').onclick = () => {
    document.getElementById('formNuevaFactura').innerHTML = plantillaFormEditar({});
    document.getElementById('nuevaFacturaModal').style.display = 'block';
    document.getElementById('formNuevaFactura').onsubmit = (e) => {
        e.preventDefault();
        alert('Implementar lógica para crear factura');
        cerrarModal('nuevaFacturaModal');
    }
}
window.onclick = function(event) {
  document.querySelectorAll('.modal').forEach(m => {
    if (event.target === m) m.style.display = "none";
  });
};
window.onload = cargarFacturas;
</script>
</body>
</html>
