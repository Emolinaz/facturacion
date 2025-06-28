// Poner la URL base de la API de Node.js
const API_BASE = "http://localhost:3001/api";

// ====== VARIABLES GLOBALES ======
let productosDisponibles = [], boletosDisponibles = [], clientes = [], empleados = [], caiList = [], eventos = [];

// ====== CARGA DE DATOS A SELECTS ======
document.addEventListener('DOMContentLoaded', function() {
    cargarClientes();
    cargarEmpleados();
    cargarCAI();
    cargarEventos();
    cargarBoletos();
    cargarProductos();
    configurarModales();
    configurarFormularios();
});

// ---- Cargar todos los selects ----
function cargarClientes() {
    axios.get(`${API_BASE}/clientes`).then(res => {
        clientes = res.data;
        llenarSelect('cliente-recorrido', clientes, 'cod_cliente', clienteText);
        llenarSelect('cliente-taquilla', clientes, 'cod_cliente', clienteText);
        llenarSelect('cliente-eventos', clientes, 'cod_cliente', clienteText);
        llenarSelect('cliente-libros', clientes, 'cod_cliente', clienteText);
    });
}
function clienteText(c) { return `${c.nombre} (${c.rtn || 'Sin RTN'})`; }

function cargarEmpleados() {
    axios.get(`${API_BASE}/empleados`).then(res => {
        empleados = res.data;
        llenarSelect('empleado-recorrido', empleados, 'cod_empleado', empleadoText);
        llenarSelect('empleado-taquilla', empleados, 'cod_empleado', empleadoText);
        llenarSelect('empleado-eventos', empleados, 'cod_empleado', empleadoText);
        llenarSelect('empleado-libros', empleados, 'cod_empleado', empleadoText);
    });
}
function empleadoText(e) { return `${e.nombre} (${e.cargo})`; }

function cargarCAI() {
    axios.get(`${API_BASE}/cai`).then(res => {
        caiList = res.data;
        llenarSelect('cai-recorrido', caiList, 'cod_cai', caiText);
        llenarSelect('cai-taquilla', caiList, 'cod_cai', caiText);
        llenarSelect('cai-eventos', caiList, 'cod_cai', caiText);
        llenarSelect('cai-libros', caiList, 'cod_cai', caiText);
    });
}
function caiText(c) { return `${c.cai} (${c.rango_desde}-${c.rango_hasta})`; }


function cargarEventos() {
    axios.get(`${API_BASE}/eventos`).then(res => {
        eventos = res.data;
        llenarSelect('evento-eventos', eventos, 'cod_evento', e => e.nombre);
    });
}

function cargarBoletos() {
    axios.get(`${API_BASE}/boletos-taquilla`).then(res => { boletosDisponibles = res.data; });
}
function cargarProductos() {
    axios.get(`${API_BASE}/productos`).then(res => { productosDisponibles = res.data; });
}

function llenarSelect(id, arr, valField, textFunc) {
    const select = document.getElementById(id); if(!select) return;
    select.innerHTML = '<option value="">Seleccione...</option>';
    arr.forEach(item => {
        const opt = document.createElement('option');
        opt.value = item[valField]; opt.textContent = textFunc(item);
        select.appendChild(opt);
    });
}

// ====== MODALES ======
function configurarModales() {
    document.querySelectorAll('.btn-invoice').forEach(btn => {
        btn.onclick = function() {
            const modalId = this.closest('.factura-card').getAttribute('data-modal');
            abrirModal(modalId);
        };
    });
    document.querySelectorAll('.close').forEach(btn => {
        btn.onclick = function() {
            cerrarModal(this.closest('.modal-factura').id);
        };
    });
    window.onclick = function(e) {
        if (e.target.classList.contains('modal-factura')) cerrarModal(e.target.id);
    };

    // Botones agregar producto/boletos
    document.getElementById('agregar-boleto-recorrido').onclick = () => agregarBoletoFila('boletos-container-recorrido', 'recorrido');
    document.getElementById('agregar-boleto-taquilla').onclick = () => agregarBoletoFila('boletos-container-taquilla', 'taquilla');
    document.getElementById('agregar-producto-eventos').onclick = () => agregarProductoFila('productos-container-eventos', 'eventos');
    document.getElementById('agregar-producto-libros').onclick = () => agregarProductoFila('productos-container-libros', 'libros');
}

function abrirModal(id) {
    document.getElementById(id).style.display = 'block';
    document.body.style.overflow = 'hidden';
}
function cerrarModal(id) {
    document.getElementById(id).style.display = 'none';
    document.body.style.overflow = 'auto';
}

// ====== TABLAS DINÁMICAS ======
function agregarBoletoFila(containerId, tipo) {
    const tbody = document.getElementById(containerId);
    const tr = document.createElement('tr');
    tr.innerHTML = `
        <td>
            <select required>
                <option value="">Seleccione...</option>
                ${boletosDisponibles.map(b => `<option value="${b.cod_boleto}" data-precio="${b.precio}">${b.tipo} - ${b.descripcion} (L. ${b.precio})</option>`).join('')}
            </select>
        </td>
        <td><input type="number" min="1" value="1" class="cantidad" required style="width:65px;"></td>
        <td><input type="number" class="precio" readonly style="width:90px;"></td>
        <td class="total">L. 0.00</td>
        <td><button type="button" class="btn-remove" onclick="this.closest('tr').remove(); recalcTotales('${tipo}')">×</button></td>
    `;
    tbody.appendChild(tr);
    const select = tr.querySelector('select');
    const cantidad = tr.querySelector('.cantidad');
    const precio = tr.querySelector('.precio');
    select.onchange = function() {
        precio.value = select.options[select.selectedIndex].dataset.precio;
        calcularTotalFila(tr); recalcTotales(tipo);
    }
    cantidad.oninput = function() { calcularTotalFila(tr); recalcTotales(tipo);}
}
console.log(productosDisponibles);

function agregarProductoFila(containerId, tipo) {
    const tbody = document.getElementById(containerId);
    const tr = document.createElement('tr');
    tr.innerHTML = `
        <td>
            <select required>
                <option value="">Seleccione...</option>
                ${productosDisponibles.map(p => `<option value="${p.cod_producto}" data-precio="${p.precio}">${p.nombre} (L. ${p.precio})</option>`).join('')}
            </select>
        </td>
        <td><input type="number" min="1" value="1" class="cantidad" required style="width:65px;"></td>
        <td><input type="number" class="precio" readonly style="width:90px;"></td>
        <td class="total">L. 0.00</td>
        <td><button type="button" class="btn-remove" onclick="this.closest('tr').remove(); recalcTotales('${tipo}')">×</button></td>
    `;
    tbody.appendChild(tr);
    const select = tr.querySelector('select');
    const cantidad = tr.querySelector('.cantidad');
    const precio = tr.querySelector('.precio');
    select.onchange = function() {
        precio.value = select.options[select.selectedIndex].dataset.precio;
        calcularTotalFila(tr); recalcTotales(tipo);
    }
    cantidad.oninput = function() { calcularTotalFila(tr); recalcTotales(tipo);}
}

function calcularTotalFila(tr) {
    const cantidad = tr.querySelector('.cantidad').value || 0;
    const precio = tr.querySelector('.precio').value || 0;
    const total = cantidad * precio;
    tr.querySelector('.total').textContent = `L. ${Number(total).toFixed(2)}`;
}

// ====== RECALCULAR TOTALES ======
function recalcTotales(tipo) {
    let filas = [];
    if (tipo === 'recorrido') filas = document.querySelectorAll('#boletos-container-recorrido tr');
    if (tipo === 'taquilla') filas = document.querySelectorAll('#boletos-container-taquilla tr');
    if (tipo === 'eventos') filas = document.querySelectorAll('#productos-container-eventos tr');
    if (tipo === 'libros') filas = document.querySelectorAll('#productos-container-libros tr');
    let subtotal = 0;
    filas.forEach(tr => {
        subtotal += parseFloat(tr.querySelector('.total').textContent.replace('L. ', '')) || 0;
    });
    const isv = subtotal * 0.18;
    const total = subtotal + isv;
    document.getElementById('subtotal-'+tipo).textContent = `L. ${subtotal.toFixed(2)}`;
    document.getElementById('isv-'+tipo).textContent = `L. ${isv.toFixed(2)}`;
    document.getElementById('total-'+tipo).textContent = `L. ${total.toFixed(2)}`;
}

// ====== SUBMIT FORMULARIOS ======
function configurarFormularios() {
    document.getElementById('formRecorrido').onsubmit = function(e) { e.preventDefault(); guardarFactura('recorrido'); }
    document.getElementById('formTaquilla').onsubmit = function(e) { e.preventDefault(); guardarFactura('taquilla'); }
    document.getElementById('formEventos').onsubmit = function(e) { e.preventDefault(); guardarFactura('eventos'); }
    document.getElementById('formLibros').onsubmit   = function(e) { e.preventDefault(); guardarFactura('libros'); }
}

function guardarFactura(tipo) {
    let form, detalles = [], subtotal = 0, cod_evento = null;
    if (tipo === 'recorrido') {
        form = document.getElementById('formRecorrido');
        document.querySelectorAll('#boletos-container-recorrido tr').forEach(tr => {
            detalles.push({
                cod_boleto: tr.querySelector('select').value,
                cantidad: tr.querySelector('.cantidad').value,
                precio_unitario: tr.querySelector('.precio').value,
                total: parseFloat(tr.querySelector('.total').textContent.replace('L. ', ''))
            });
        });
        subtotal = detalles.reduce((sum, d) => sum + d.total, 0);
    }
    if (tipo === 'taquilla') {
        form = document.getElementById('formTaquilla');
        document.querySelectorAll('#boletos-container-taquilla tr').forEach(tr => {
            detalles.push({
                cod_boleto: tr.querySelector('select').value,
                cantidad: tr.querySelector('.cantidad').value,
                precio_unitario: tr.querySelector('.precio').value,
                total: parseFloat(tr.querySelector('.total').textContent.replace('L. ', ''))
            });
        });
        subtotal = detalles.reduce((sum, d) => sum + d.total, 0);
    }
    if (tipo === 'eventos') {
        form = document.getElementById('formEventos');
        cod_evento = form.evento.value;
        document.querySelectorAll('#productos-container-eventos tr').forEach(tr => {
            detalles.push({
                cod_producto: tr.querySelector('select').value,
                cantidad: tr.querySelector('.cantidad').value,
                precio_unitario: tr.querySelector('.precio').value,
                total: parseFloat(tr.querySelector('.total').textContent.replace('L. ', ''))
            });
        });
        subtotal = detalles.reduce((sum, d) => sum + d.total, 0);
    }
    if (tipo === 'libros') {
        form = document.getElementById('formLibros');
        document.querySelectorAll('#productos-container-libros tr').forEach(tr => {
            detalles.push({
                cod_producto: tr.querySelector('select').value,
                cantidad: tr.querySelector('.cantidad').value,
                precio_unitario: tr.querySelector('.precio').value,
                total: parseFloat(tr.querySelector('.total').textContent.replace('L. ', ''))
            });
        });
        subtotal = detalles.reduce((sum, d) => sum + d.total, 0);
    }

    const isv = subtotal * 0.18, total = subtotal + isv;
    const formData = new FormData(form);
    const data = {
        cod_cliente: formData.get('cliente'),
        cod_empleado: formData.get('empleado'),
        cod_cai: formData.get('cai'),
        fecha_emision: formData.get('fecha_emision'),
        tipo_factura: tipo === 'recorrido' ? 'recorrido_escolar' :
                      tipo === 'taquilla' ? 'taquilla' :
                      tipo === 'eventos' ? 'evento' : 'libros',
   
        subtotal: subtotal,
        importe_gravado_15: 0,
        impuesto_15: 0,
        importe_gravado_18: subtotal,
        impuesto_18: isv,
        importe_exento: 0,
        rebaja_otorgada: 0,
        descuento_otorgado: 0,
        total: total,
        nota: formData.get('nota'),
        productos: (tipo === 'eventos' || tipo === 'libros') ? detalles : [],
        boletos: (tipo === 'recorrido' || tipo === 'taquilla') ? detalles : [],
        cod_evento: cod_evento
    };
    axios.post(`${API_BASE}/facturas`, data)
        .then(() => {
            alert('¡Factura guardada!');
            form.reset();
            if (tipo === 'recorrido') document.getElementById('boletos-container-recorrido').innerHTML = '';
            if (tipo === 'taquilla') document.getElementById('boletos-container-taquilla').innerHTML = '';
            if (tipo === 'eventos') document.getElementById('productos-container-eventos').innerHTML = '';
            if (tipo === 'libros') document.getElementById('productos-container-libros').innerHTML = '';
            recalcTotales(tipo);
            cerrarModal('modal'+capitalize(tipo));
        })
        .catch(err => alert('Error al guardar: '+(err.response?.data?.error || err.message)));
}

function generarNumeroFactura() {
    const now = new Date();
    return `FAC-${now.getFullYear()}${(now.getMonth()+1).toString().padStart(2,'0')}${now.getDate().toString().padStart(2,'0')}-${Math.floor(Math.random()*1000).toString().padStart(3,'0')}`;
}
function capitalize(txt) { return txt.charAt(0).toUpperCase()+txt.slice(1); }
