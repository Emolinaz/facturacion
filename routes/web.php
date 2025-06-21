<?php

use Illuminate\Support\Facades\Route;

// Ruta principal
Route::get('/', function () {
    return view('Pages.index');
});

// Rutas para las páginas de facturación
Route::get('/generador-facturas', function () {
    return view('Pages.generador-facturas');
});

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
Route::get('/registro-facturas', function () {
    return view('Pages.registro-facturas');
});

// Rutas API proxy (opcional, si necesitas intermediación)
Route::prefix('api')->group(function () {
    Route::get('/facturas', 'Api\FacturaController@index');
    Route::get('/facturas/{id}', 'Api\FacturaController@show');
    Route::delete('/facturas/{id}', 'Api\FacturaController@destroy');
});