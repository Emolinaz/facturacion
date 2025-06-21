<!-- resources/views/layouts/app.blade.php -->
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>@yield('title', 'Sistema de Facturación')</title>
    <link rel="stylesheet" href="/css/styles.css">
    <link rel="stylesheet" href="/css/modales.css">
    <link rel="stylesheet" href="/css/generador-facturas.css">
</head>
<body>
    <div class="container">
        @yield('content')
    </div>
    @yield('scripts')
</body>
</html>
