// routes/web.php
<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\FacturaController;

Route::get('/facturas', [FacturaController::class, 'index']);
Route::get('/facturas/estadisticas', [FacturaController::class, 'estadisticas']);
Route::get('/facturas/clientes', [FacturaController::class, 'clientes']);
Route::get('/facturas/empleados', [FacturaController::class, 'empleados']);
Route::get('/facturas/productos', [FacturaController::class, 'productos']);
Route::get('/facturas/eventos', [FacturaController::class, 'eventos']);
Route::get('/facturas/cai', [FacturaController::class, 'cai']);
Route::get('/facturas/boletos-taquilla', [FacturaController::class, 'boletosTaquilla']);
Route::post('/facturas/crear', [FacturaController::class, 'crear']);
