<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\FacturaController;

// Ruta principal
Route::get('/', function () {
    return view('Pages.index');
});

// Páginas de facturación
Route::get('/generador-facturas', [FacturaController::class, 'index']);
Route::get('/registro-facturas', function () {
    return view('Pages.registro-facturas');
});
Route::get('/correlativo-facturacion', function () {
    return view('Pages.correlativo-facturacion');
});
Route::get('/cai', function () {
    return view('Pages.cai');
});
Route::get('/facturas-recientes', function () {
    return view('Pages.facturas-recientes');
});
Route::get('/admin', function () {
    return view('Pages.admin');
});

// Endpoints de apoyo para la UI
Route::prefix('api')->group(function () {
    Route::get('/facturas/estadisticas', [FacturaController::class, 'estadisticas']);
    Route::get('/clientes', [FacturaController::class, 'clientes']);
    Route::get('/empleados', [FacturaController::class, 'empleados']);
    Route::get('/productos', [FacturaController::class, 'productos']);
    Route::get('/eventos', [FacturaController::class, 'eventos']);
    Route::get('/cai', [FacturaController::class, 'cai']);
    Route::get('/boletos-taquilla', [FacturaController::class, 'boletosTaquilla']);
    Route::post('/facturas', [FacturaController::class, 'crear']);
});
