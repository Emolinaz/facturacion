-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1:3306
-- Tiempo de generación: 28-06-2025 a las 05:33:33
-- Versión del servidor: 8.0.42
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `facturas_chiminike`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actualizar_correlativo` (IN `p_cod_correlativo` INT, IN `p_siguiente_numero` VARCHAR(25))   BEGIN
    UPDATE correlativos_factura SET siguiente_numero = p_siguiente_numero WHERE cod_correlativo = p_cod_correlativo;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actualizar_detalle_cotizacion` (IN `pv_cod_cotizacion` INT, IN `pv_json_productos` JSON)   BEGIN
    DECLARE v_error TEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_error = MESSAGE_TEXT;
        ROLLBACK;
        SELECT CONCAT('Error SQL: ', v_error) AS mensaje;
    END;

    START TRANSACTION;

    -- 1. Eliminar detalle anterior
    DELETE FROM detalle_cotizacion
    WHERE cod_cotizacion = pv_cod_cotizacion;

    -- 2. Insertar nuevo detalle desde JSON
    INSERT INTO detalle_cotizacion (cantidad, descripcion, precio_unitario, total, cod_cotizacion)
    SELECT 
        cantidad,
        descripcion,
        precio_unitario,
        cantidad * precio_unitario,
        pv_cod_cotizacion
    FROM JSON_TABLE(
        pv_json_productos,
        '$[*]' COLUMNS (
            cantidad INT PATH '$.cantidad',
            descripcion TEXT PATH '$.descripcion',
            precio_unitario DECIMAL(10,2) PATH '$.precio_unitario'
        )
    ) AS productos;

    COMMIT;

    -- 3. Mostrar datos completos de la cotización
    SELECT 
        c.cod_cotizacion,
        p.nombre_persona AS nombre_cliente,
        c.fecha,
        c.fecha_validez,
        e.nombre AS nombre_evento,
        e.fecha_programa,
        e.hora_programada,
        c.estado
    FROM cotizacion c
    JOIN clientes cli ON c.cod_cliente = cli.cod_cliente
    JOIN personas p ON cli.cod_persona = p.cod_persona
    LEFT JOIN evento e ON e.cod_cotizacion = c.cod_cotizacion
    WHERE c.cod_cotizacion = pv_cod_cotizacion;

    -- 4. Mostrar nuevo detalle
    SELECT 
        cantidad,
        descripcion,
        precio_unitario,
        total
    FROM detalle_cotizacion
    WHERE cod_cotizacion = pv_cod_cotizacion;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actualizar_detalle_factura` (IN `p_cod_detalle` INT, IN `p_cantidad` INT, IN `p_descripcion` TEXT, IN `p_precio_unitario` DECIMAL(10,2), IN `p_total` DECIMAL(10,2), IN `p_tipo` ENUM('Evento','Entrada','Paquete','Adicional','Inventario','Otro'), IN `p_referencia` INT)   BEGIN
    UPDATE detalle_factura SET
        cantidad        = p_cantidad,
        descripcion     = p_descripcion,
        precio_unitario = p_precio_unitario,
        total           = p_total,
        tipo            = p_tipo,
        referencia      = p_referencia
    WHERE cod_detalle_factura = p_cod_detalle;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actualizar_factura` (IN `p_cod_factura` INT, IN `p_numero_factura` VARCHAR(30), IN `p_fecha_emision` DATE, IN `p_cod_cliente` INT, IN `p_direccion` TEXT, IN `p_rtn` VARCHAR(20), IN `p_cod_cai` INT, IN `p_rango_desde` VARCHAR(25), IN `p_rango_hasta` VARCHAR(25), IN `p_fecha_limite` DATE, IN `p_tipo_factura` ENUM('Evento','Recorrido Escolar','Taquilla General','Libros'), IN `p_descuento_otorgado` DECIMAL(10,2), IN `p_rebajas_otorgadas` DECIMAL(10,2), IN `p_importe_exento` DECIMAL(10,2), IN `p_importe_gravado_18` DECIMAL(10,2), IN `p_importe_gravado_15` DECIMAL(10,2), IN `p_impuesto_15` DECIMAL(10,2), IN `p_impuesto_18` DECIMAL(10,2), IN `p_importe_exonerado` DECIMAL(10,2), IN `p_subtotal` DECIMAL(10,2), IN `p_total_pago` DECIMAL(10,2), IN `p_observaciones` TEXT)   BEGIN
    UPDATE facturas SET
        numero_factura       = p_numero_factura,
        fecha_emision        = p_fecha_emision,
        cod_cliente          = p_cod_cliente,
        direccion            = p_direccion,
        rtn                  = p_rtn,
        cod_cai              = p_cod_cai,
        rango_desde          = p_rango_desde,
        rango_hasta          = p_rango_hasta,
        fecha_limite         = p_fecha_limite,
        tipo_factura         = p_tipo_factura,
        descuento_otorgado   = p_descuento_otorgado,
        rebajas_otorgadas    = p_rebajas_otorgadas,
        importe_exento       = p_importe_exento,
        importe_gravado_18   = p_importe_gravado_18,
        importe_gravado_15   = p_importe_gravado_15,
        impuesto_15          = p_impuesto_15,
        impuesto_18          = p_impuesto_18,
        importe_exonerado    = p_importe_exonerado,
        subtotal             = p_subtotal,
        total_pago           = p_total_pago,
        observaciones        = p_observaciones
    WHERE cod_factura = p_cod_factura;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actualizar_permiso` (IN `p_cod_rol` INT, IN `p_cod_objeto` INT, IN `p_permiso` VARCHAR(20), IN `p_valor` TINYINT)   BEGIN
    SET @sql = CONCAT('UPDATE Permisos SET ', p_permiso, ' = ? WHERE cod_rol = ? AND cod_objeto = ?');
    SET @v_valor = p_valor;
    SET @v_rol = p_cod_rol;
    SET @v_objeto = p_cod_objeto;

    PREPARE stmt FROM @sql;
    EXECUTE stmt USING @v_valor, @v_rol, @v_objeto;
    DEALLOCATE PREPARE stmt;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actualizar_personas` (IN `PV_COD` INT, IN `PV_NOMBRE` VARCHAR(100), IN `PV_FECHA_NACIMIENTO` DATE, IN `PV_SEXO` ENUM('Masculino','Femenino','Otro'), IN `PV_DNI` VARCHAR(20), IN `PV_CORREO` VARCHAR(255), IN `PV_TELEFONO` VARCHAR(20), IN `PV_DIRECCION` TEXT, IN `PV_COD_MUNICIPIO` INT, IN `PV_RTN` VARCHAR(20), IN `PV_TIPO_CLIENTE` ENUM('Individual','Empresa'), IN `PV_CARGO` VARCHAR(50), IN `PV_SALARIO` DECIMAL(10,2), IN `PV_FECHA_CONTRATACION` DATETIME, IN `PV_COD_DEP_EMPRESA` INT, IN `PV_COD_ROL` INT, IN `PV_ESTADO` TINYINT, IN `PV_NOMBRE_ROL` VARCHAR(50), IN `PV_DESC_ROL` TEXT, IN `PV_ACTION` ENUM('CLIENTE','EMPLEADO','ROL'))   BEGIN
    DECLARE v_cod_persona INT;
    DECLARE v_cod_empleado INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error. Se realizó rollback.' AS mensaje;
    END;

    START TRANSACTION;

    IF PV_ACTION = 'CLIENTE' THEN
        SELECT cod_persona INTO v_cod_persona FROM Clientes WHERE cod_cliente = PV_COD LIMIT 1;

        UPDATE Personas
        SET nombre_persona = PV_NOMBRE,
            fecha_nacimiento = PV_FECHA_NACIMIENTO,
            sexo = PV_SEXO,
            dni = PV_DNI
        WHERE cod_persona = v_cod_persona;

        UPDATE Correos
        SET correo = PV_CORREO
        WHERE cod_persona = v_cod_persona
        LIMIT 1;

        UPDATE Telefonos
        SET telefono = PV_TELEFONO
        WHERE cod_persona = v_cod_persona
        LIMIT 1;

        UPDATE Direcciones
        SET direccion = PV_DIRECCION,
            cod_municipio = PV_COD_MUNICIPIO
        WHERE cod_persona = v_cod_persona
        LIMIT 1;

        UPDATE Clientes
        SET rtn = PV_RTN,
            tipo_cliente = PV_TIPO_CLIENTE
        WHERE cod_persona = v_cod_persona;

    ELSEIF PV_ACTION = 'EMPLEADO' THEN
        SELECT cod_persona, cod_empleado INTO v_cod_persona, v_cod_empleado
        FROM Empleados
        WHERE cod_empleado = PV_COD
        LIMIT 1;

        UPDATE Personas
        SET nombre_persona = PV_NOMBRE,
            fecha_nacimiento = PV_FECHA_NACIMIENTO,
            sexo = PV_SEXO,
            dni = PV_DNI
        WHERE cod_persona = v_cod_persona;

        UPDATE Correos
        SET correo = PV_CORREO
        WHERE cod_persona = v_cod_persona
        LIMIT 1;

        UPDATE Telefonos
        SET telefono = PV_TELEFONO
        WHERE cod_persona = v_cod_persona
        LIMIT 1;

        UPDATE Direcciones
        SET direccion = PV_DIRECCION,
            cod_municipio = PV_COD_MUNICIPIO
        WHERE cod_persona = v_cod_persona
        LIMIT 1;

        UPDATE Empleados
        SET cargo = PV_CARGO,
            salario = PV_SALARIO,
            fecha_contratacion = PV_FECHA_CONTRATACION,
            cod_departamento_empresa = PV_COD_DEP_EMPRESA
        WHERE cod_persona = v_cod_persona;

        UPDATE Usuarios
        SET cod_rol = PV_COD_ROL,
            estado = PV_ESTADO
        WHERE cod_empleado = v_cod_empleado
        LIMIT 1;

    ELSEIF PV_ACTION = 'ROL' THEN
        UPDATE Roles
        SET nombre = PV_NOMBRE_ROL,
            descripcion = PV_DESC_ROL
        WHERE cod_rol = PV_COD;

    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'PV_ACTION no es válido. Debe ser CLIENTE, EMPLEADO o ROL';
    END IF;

    COMMIT;
    SELECT 'Actualización completada exitosamente' AS mensaje;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_consultar_bitacora` (IN `p_cod_usuario` INT, IN `p_fecha_inicio` DATE, IN `p_fecha_fin` DATE, IN `p_objeto` VARCHAR(100))   BEGIN
    SELECT b.*, u.nombre_usuario
    FROM bitacora b
    JOIN usuarios u ON b.cod_usuario = u.cod_usuario
    WHERE (p_cod_usuario = 0 OR b.cod_usuario = p_cod_usuario)
      AND (p_fecha_inicio IS NULL OR DATE(b.fecha) >= p_fecha_inicio)
      AND (p_fecha_fin IS NULL OR DATE(b.fecha) <= p_fecha_fin)
      AND (p_objeto IS NULL OR p_objeto = '' OR b.objeto = p_objeto)
    ORDER BY b.fecha DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_consultar_bitacora_paginado` (IN `p_cod_usuario` INT, IN `p_fecha_inicio` DATE, IN `p_fecha_fin` DATE, IN `p_objeto` VARCHAR(100), IN `p_limit` INT, IN `p_offset` INT)   BEGIN
    SELECT b.*, u.nombre_usuario
    FROM bitacora b
    JOIN usuarios u ON b.cod_usuario = u.cod_usuario
    WHERE (p_cod_usuario = 0 OR b.cod_usuario = p_cod_usuario)
      AND (p_fecha_inicio IS NULL OR DATE(b.fecha) >= p_fecha_inicio)
      AND (p_fecha_fin IS NULL OR DATE(b.fecha) <= p_fecha_fin)
      AND (p_objeto IS NULL OR p_objeto = '' OR b.objeto = p_objeto)
    ORDER BY b.fecha DESC
    LIMIT p_limit OFFSET p_offset;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cotizacion_completa_json` (IN `PV_NOMBRE` VARCHAR(100), IN `PV_FECHA_NACIMIENTO` DATE, IN `PV_SEXO` ENUM('Masculino','Femenino','Otro'), IN `PV_DNI` VARCHAR(20), IN `PV_CORREO` VARCHAR(255), IN `PV_TELEFONO` VARCHAR(20), IN `PV_DIRECCION` TEXT, IN `PV_COD_MUNICIPIO` INT, IN `PV_RTN` VARCHAR(20), IN `PV_TIPO_CLIENTE` ENUM('Individual','Empresa'), IN `PV_EVENTO_NOMBRE` VARCHAR(100), IN `PV_FECHA_EVENTO` DATE, IN `PV_HORA_EVENTO` TIME, IN `PV_JSON_PRODUCTOS` JSON)   BEGIN
    DECLARE v_cod_persona INT;
    DECLARE v_cod_cliente INT;
    DECLARE v_cod_cotizacion INT;
    DECLARE v_error TEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_error = MESSAGE_TEXT;
        ROLLBACK;
        SELECT CONCAT('Error SQL: ', v_error) AS mensaje;
    END;

    START TRANSACTION;

    -- Insertar cliente
    INSERT INTO Personas (nombre_persona, fecha_nacimiento, sexo, dni)
    VALUES (PV_NOMBRE, PV_FECHA_NACIMIENTO, PV_SEXO, PV_DNI);
    SET v_cod_persona = LAST_INSERT_ID();

    INSERT INTO Correos (correo, cod_persona) VALUES (PV_CORREO, v_cod_persona);
    INSERT INTO Telefonos (telefono, cod_persona) VALUES (PV_TELEFONO, v_cod_persona);
    INSERT INTO Direcciones (direccion, cod_persona, cod_municipio) 
    VALUES (PV_DIRECCION, v_cod_persona, PV_COD_MUNICIPIO);

    INSERT INTO Clientes (rtn, tipo_cliente, cod_persona) 
    VALUES (PV_RTN, PV_TIPO_CLIENTE, v_cod_persona);
    SET v_cod_cliente = LAST_INSERT_ID();

    -- Cotización
    INSERT INTO Cotizacion (cod_cliente, fecha, fecha_validez, estado)
    VALUES (v_cod_cliente, CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 5 DAY), 'pendiente');
    SET v_cod_cotizacion = LAST_INSERT_ID();

    -- Evento
    INSERT INTO Evento (nombre, fecha_programa, hora_programada, cod_cotizacion)
    VALUES (PV_EVENTO_NOMBRE, PV_FECHA_EVENTO, PV_HORA_EVENTO, v_cod_cotizacion);

    -- Insertar productos desde JSON
    INSERT INTO detalle_cotizacion (cantidad, descripcion, precio_unitario, total, cod_cotizacion)
    SELECT 
        cantidad,
        descripcion,
        precio_unitario,
        cantidad * precio_unitario,
        v_cod_cotizacion
    FROM JSON_TABLE(
        PV_JSON_PRODUCTOS,
        '$[*]' COLUMNS (
            cantidad INT PATH '$.cantidad',
            descripcion TEXT PATH '$.descripcion',
            precio_unitario DECIMAL(10,2) PATH '$.precio_unitario'
        )
    ) AS detalles;

    COMMIT;

    SELECT v_cod_cotizacion AS cod_cotizacion_generada;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_detalle_cotizacion_por_id` (IN `pv_cod_cotizacion` INT)   BEGIN
  
    SELECT 
        c.cod_cotizacion,
        p.nombre_persona AS nombre_cliente,
        c.fecha,
        c.fecha_validez,
        e.nombre AS nombre_evento,
        e.fecha_programa,
        e.hora_programada,
        c.estado
    FROM cotizacion c
    JOIN clientes cli ON c.cod_cliente = cli.cod_cliente
    JOIN personas p ON cli.cod_persona = p.cod_persona
    LEFT JOIN evento e ON e.cod_cotizacion = c.cod_cotizacion
    WHERE c.cod_cotizacion = pv_cod_cotizacion
    LIMIT 1;

   
    SELECT 
        dc.cantidad,
        dc.descripcion,
        dc.precio_unitario,
        dc.total
    FROM detalle_cotizacion dc
    WHERE dc.cod_cotizacion = pv_cod_cotizacion;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_eliminar_detalle_factura` (IN `p_cod_detalle` INT)   BEGIN
    DELETE FROM detalle_factura
    WHERE cod_detalle_factura = p_cod_detalle;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_eliminar_factura` (IN `p_cod_factura` INT)   BEGIN
    DELETE FROM facturas
    WHERE cod_factura = p_cod_factura;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_form_empleado` (IN `pv_accion` VARCHAR(20))   BEGIN
    IF pv_accion = 'ROLES' THEN
        SELECT cod_rol AS cod, nombre AS nombre
        FROM roles
        ORDER BY nombre;

    ELSEIF pv_accion = 'DEPARTAMENTOS' THEN
        SELECT cod_departamento_empresa AS cod, nombre AS nombre
        FROM departamento_empresa
        ORDER BY nombre;

    ELSEIF pv_accion = 'MUNICIPIOS' THEN
        SELECT cod_municipio AS cod, municipio AS nombre
        FROM municipios
        ORDER BY municipio;

    ELSE
        SELECT 'Acción no válida' AS error;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_generar_token_recuperacion` (IN `pv_correo` VARCHAR(100), IN `pv_token` VARCHAR(64), IN `pv_expira` DATETIME)   BEGIN
    DECLARE v_cod_usuario INT DEFAULT NULL;
    DECLARE v_nombre_usuario VARCHAR(50) DEFAULT NULL;

    SELECT u.cod_usuario, u.nombre_usuario
    INTO v_cod_usuario, v_nombre_usuario
    FROM Correos c
    JOIN Personas p ON c.cod_persona = p.cod_persona
    JOIN Empleados e ON e.cod_persona = p.cod_persona
    JOIN Usuarios u ON u.cod_empleado = e.cod_empleado
    WHERE c.correo = pv_correo
    LIMIT 1;

    IF v_cod_usuario IS NULL THEN
        SELECT 'El correo no pertenece a ningún usuario del sistema' AS error;
    ELSE
        UPDATE Usuarios
        SET token_recuperacion = pv_token,
            expira_token = pv_expira
        WHERE cod_usuario = v_cod_usuario;

        SELECT v_nombre_usuario AS usuario;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_gestion_salon` (IN `pv_accion` VARCHAR(20), IN `pv_cod_salon` INT, IN `pv_nombre` VARCHAR(100), IN `pv_descripcion` TEXT, IN `pv_capacidad` INT, IN `pv_activo` TINYINT, IN `pv_precio_dia` DECIMAL(10,2), IN `pv_precio_noche` DECIMAL(10,2))   BEGIN
    DECLARE v_error TEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error. Se realizó rollback.' AS mensaje;
    END;

    START TRANSACTION;

    IF pv_accion = 'INSERTAR' THEN
        INSERT INTO salones(nombre, descripcion, capacidad, activo)
        VALUES (pv_nombre, pv_descripcion, pv_capacidad, pv_activo);

        SET @nuevo_id = LAST_INSERT_ID();

        INSERT INTO salon_horario(cod_salon, cod_tipo_horario, precio_por_hora)
        VALUES
            (@nuevo_id, 1, pv_precio_dia),
            (@nuevo_id, 2, pv_precio_noche);

        COMMIT;
        SELECT CONCAT('Salón insertado con ID: ', @nuevo_id) AS mensaje;

    ELSEIF pv_accion = 'ACTUALIZAR' THEN
        UPDATE salones
        SET nombre = pv_nombre,
            descripcion = pv_descripcion,
            capacidad = pv_capacidad,
            activo = pv_activo
        WHERE cod_salon = pv_cod_salon;

        UPDATE salon_horario
        SET precio_por_hora = pv_precio_dia
        WHERE cod_salon = pv_cod_salon AND cod_tipo_horario = 1;

        UPDATE salon_horario
        SET precio_por_hora = pv_precio_noche
        WHERE cod_salon = pv_cod_salon AND cod_tipo_horario = 2;

        COMMIT;
        SELECT 'Salón actualizado correctamente' AS mensaje;

    ELSEIF pv_accion = 'MOSTRAR' THEN
        SELECT 
            s.cod_salon,
            s.nombre,
            s.descripcion,
            s.capacidad,
            s.activo,
            sh1.precio_por_hora AS precio_dia,
            sh2.precio_por_hora AS precio_noche
        FROM salones s
        LEFT JOIN salon_horario sh1 ON s.cod_salon = sh1.cod_salon AND sh1.cod_tipo_horario = 1
        LEFT JOIN salon_horario sh2 ON s.cod_salon = sh2.cod_salon AND sh2.cod_tipo_horario = 2;

    ELSEIF pv_accion = 'ELIMINAR' THEN
        DELETE FROM salones WHERE cod_salon = pv_cod_salon;
        COMMIT;
        SELECT 'Salón eliminado correctamente' AS mensaje;

    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Acción no válida. Usa INSERTAR, ACTUALIZAR, MOSTRAR o ELIMINAR';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_guardar_codigo_2fa` (IN `p_cod_usuario` INT, IN `p_codigo` VARCHAR(6), IN `p_expira` DATETIME)   BEGIN
    DELETE FROM verificacion_2fa 
    WHERE cod_usuario = p_cod_usuario;

    INSERT INTO verificacion_2fa (cod_usuario, codigo, expira)
    VALUES (p_cod_usuario, p_codigo, p_expira);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insertar_detalle_factura` (IN `p_cod_factura` INT, IN `p_cantidad` INT, IN `p_descripcion` TEXT, IN `p_precio_unitario` DECIMAL(10,2), IN `p_total` DECIMAL(10,2), IN `p_tipo` ENUM('Evento','Entrada','Paquete','Adicional','Inventario','Otro'), IN `p_referencia` INT)   BEGIN
    INSERT INTO detalle_factura (
        cod_factura, cantidad, descripcion, precio_unitario,
        total, tipo, referencia
    ) VALUES (
        p_cod_factura, p_cantidad, p_descripcion, p_precio_unitario,
        p_total, p_tipo, p_referencia
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insertar_factura` (IN `p_numero_factura` VARCHAR(30), IN `p_fecha_emision` DATE, IN `p_cod_cliente` INT, IN `p_direccion` TEXT, IN `p_rtn` VARCHAR(20), IN `p_cod_cai` INT, IN `p_rango_desde` VARCHAR(25), IN `p_rango_hasta` VARCHAR(25), IN `p_fecha_limite` DATE, IN `p_tipo_factura` ENUM('Evento','Recorrido Escolar','Taquilla General','Libros'), IN `p_descuento_otorgado` DECIMAL(10,2), IN `p_rebajas_otorgadas` DECIMAL(10,2), IN `p_importe_exento` DECIMAL(10,2), IN `p_importe_gravado_18` DECIMAL(10,2), IN `p_importe_gravado_15` DECIMAL(10,2), IN `p_impuesto_15` DECIMAL(10,2), IN `p_impuesto_18` DECIMAL(10,2), IN `p_importe_exonerado` DECIMAL(10,2), IN `p_subtotal` DECIMAL(10,2), IN `p_total_pago` DECIMAL(10,2), IN `p_observaciones` TEXT)   BEGIN
    INSERT INTO facturas (
        numero_factura, fecha_emision, cod_cliente, direccion, rtn, cod_cai,
        rango_desde, rango_hasta, fecha_limite, tipo_factura,
        descuento_otorgado, rebajas_otorgadas, importe_exento,
        importe_gravado_18, importe_gravado_15,
        impuesto_15, impuesto_18, importe_exonerado,
        subtotal, total_pago, observaciones
    ) VALUES (
        p_numero_factura, p_fecha_emision, p_cod_cliente, p_direccion, p_rtn, p_cod_cai,
        p_rango_desde, p_rango_hasta, p_fecha_limite, p_tipo_factura,
        p_descuento_otorgado, p_rebajas_otorgadas, p_importe_exento,
        p_importe_gravado_18, p_importe_gravado_15,
        p_impuesto_15, p_impuesto_18, p_importe_exonerado,
        p_subtotal, p_total_pago, p_observaciones
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insertar_personas` (IN `PV_NOMBRE` VARCHAR(100), IN `PV_FECHA_NACIMIENTO` DATE, IN `PV_SEXO` ENUM('Masculino','Femenino','Otro'), IN `PV_DNI` VARCHAR(20), IN `PV_CORREO` VARCHAR(255), IN `PV_TELEFONO` VARCHAR(20), IN `PV_DIRECCION` TEXT, IN `PV_COD_MUNICIPIO` INT, IN `PV_RTN` VARCHAR(20), IN `PV_TIPO_CLIENTE` ENUM('Individual','Empresa'), IN `PV_CARGO` VARCHAR(50), IN `PV_SALARIO` DECIMAL(10,2), IN `PV_FECHA_CONTRATACION` DATETIME, IN `PV_COD_DEP_EMPRESA` INT, IN `PV_NOMBRE_USUARIO` VARCHAR(50), IN `PV_CONTRASENA` VARCHAR(255), IN `PV_COD_ROL` INT, IN `PV_NOMBRE_ROL` VARCHAR(50), IN `PV_DESC_ROL` TEXT, IN `PV_ACTION` ENUM('CLIENTE','EMPLEADO','ROL'))   BEGIN
    DECLARE v_cod_persona INT;
    DECLARE v_cod_empleado INT;
    DECLARE v_id_resultado INT;
    DECLARE v_error TEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_error = MESSAGE_TEXT;
        ROLLBACK;
        SELECT CONCAT('Error SQL: ', v_error) AS mensaje;
    END;

    START TRANSACTION;

    IF PV_ACTION = 'CLIENTE' OR PV_ACTION = 'EMPLEADO' THEN

        INSERT INTO Personas(nombre_persona, fecha_nacimiento, sexo, dni)
        VALUES (PV_NOMBRE, PV_FECHA_NACIMIENTO, PV_SEXO, PV_DNI);
        SET v_cod_persona = LAST_INSERT_ID();

        INSERT INTO Correos(correo, cod_persona)
        VALUES (PV_CORREO, v_cod_persona);

        INSERT INTO Telefonos(telefono, cod_persona)
        VALUES (PV_TELEFONO, v_cod_persona);

        INSERT INTO Direcciones(direccion, cod_persona, cod_municipio)
        VALUES (PV_DIRECCION, v_cod_persona, PV_COD_MUNICIPIO);

        IF PV_ACTION = 'CLIENTE' THEN
            INSERT INTO Clientes(rtn, tipo_cliente, cod_persona)
            VALUES (PV_RTN, PV_TIPO_CLIENTE, v_cod_persona);
            SET v_id_resultado = LAST_INSERT_ID();

        ELSEIF PV_ACTION = 'EMPLEADO' THEN
            INSERT INTO Empleados(cargo, salario, fecha_contratacion, cod_persona, cod_departamento_empresa)
            VALUES (PV_CARGO, PV_SALARIO, PV_FECHA_CONTRATACION, v_cod_persona, PV_COD_DEP_EMPRESA);
            SET v_cod_empleado = LAST_INSERT_ID();

            INSERT INTO Usuarios(nombre_usuario, contrasena, cod_rol, cod_empleado, cod_tipo_usuario)
            VALUES (PV_NOMBRE_USUARIO, PV_CONTRASENA, PV_COD_ROL, v_cod_empleado, 1);
            SET v_id_resultado = LAST_INSERT_ID();
        END IF;

    ELSEIF PV_ACTION = 'ROL' THEN
        INSERT INTO Roles(nombre, descripcion)
        VALUES (PV_NOMBRE_ROL, PV_DESC_ROL);
        SET v_id_resultado = LAST_INSERT_ID();

    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'PV_ACTION no es válido. Debe ser EMPLEADO, CLIENTE o ROL';
    END IF;

    COMMIT;
    SELECT CONCAT('Se agregó exitosamente con el ID: ', v_id_resultado) AS mensaje;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_detalle_factura` (IN `p_cod_factura` INT)   BEGIN
    SELECT * FROM detalle_factura
    WHERE cod_factura = p_cod_factura;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_facturas` ()   BEGIN
    SELECT * FROM facturas;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_login_usuario` (IN `pv_accion` VARCHAR(30), IN `pv_usuario` VARCHAR(50), IN `pv_ip_conexion` VARCHAR(50))   BEGIN
    DECLARE v_exist INT;
    DECLARE v_intentos INT;

    SELECT COUNT(*) INTO v_exist
    FROM Usuarios
    WHERE nombre_usuario = pv_usuario;

    IF v_exist = 0 THEN
        SELECT 'Usuario no encontrado' AS mensaje;
    ELSE
        CASE pv_accion

            WHEN 'mostrar' THEN
                SELECT 
                    u.cod_usuario,
                    u.nombre_usuario,
                    u.contrasena,
                    u.estado,
                    u.intentos,
                    u.cod_rol,
                    r.nombre AS rol,
                    u.cod_tipo_usuario,
                    u.primer_acceso,
                    c.correo
                FROM Usuarios u
                JOIN Roles r ON u.cod_rol = r.cod_rol
                JOIN Empleados e ON u.cod_empleado = e.cod_empleado
                JOIN Personas p ON e.cod_persona = p.cod_persona
                LEFT JOIN Correos c ON p.cod_persona = c.cod_persona
                WHERE u.nombre_usuario = pv_usuario;

            WHEN 'sumar_intento' THEN
                SELECT intentos INTO v_intentos
                FROM Usuarios
                WHERE nombre_usuario = pv_usuario;

                IF v_intentos + 1 >= 3 THEN
                    UPDATE Usuarios
                    SET intentos = intentos + 1,
                        estado = 0
                    WHERE nombre_usuario = pv_usuario;
                ELSE
                    UPDATE Usuarios
                    SET intentos = intentos + 1
                    WHERE nombre_usuario = pv_usuario;
                END IF;

            WHEN 'login_exitoso' THEN
                UPDATE Usuarios
                SET intentos = 0,
                    ip_conexion = pv_ip_conexion,
                    primer_acceso = 0
                WHERE nombre_usuario = pv_usuario;

            ELSE
                SELECT 'Acción no válida' AS mensaje;

        END CASE;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_mostrar_persona` (IN `PV_COD_PERSONA` INT, IN `PV_ACTION` ENUM('CLIENTE','EMPLEADO','TODOS_CLIENTES','TODOS_EMPLEADOS','ROL','TODOS_ROLES'))   BEGIN
    IF PV_ACTION = 'CLIENTE' THEN
        SELECT 
            CL.cod_cliente,
            P.nombre_persona AS nombre,
            P.fecha_nacimiento,
            P.sexo,
            P.dni,
            C.correo,
            T.telefono,
            D.direccion,
            M.municipio,
            DP.departamento,
            CL.rtn,
            CL.tipo_cliente
        FROM Clientes CL
        INNER JOIN Personas P ON P.cod_persona = CL.cod_persona
        LEFT JOIN Correos C ON C.cod_persona = P.cod_persona
        LEFT JOIN Telefonos T ON T.cod_persona = P.cod_persona
        LEFT JOIN Direcciones D ON D.cod_persona = P.cod_persona
        LEFT JOIN Municipios M ON M.cod_municipio = D.cod_municipio
        LEFT JOIN Departamentos DP ON DP.cod_departamento = M.cod_departamento
        WHERE CL.cod_cliente = PV_COD_PERSONA
        LIMIT 1;

    ELSEIF PV_ACTION = 'EMPLEADO' THEN
        SELECT 
            E.cod_empleado,
            P.nombre_persona AS nombre,
            P.fecha_nacimiento,
            P.sexo,
            P.dni,
            C.correo,
            T.telefono,
            D.direccion,
            M.municipio,
            DP.departamento,
            E.cargo,
            E.salario,
            E.fecha_contratacion,
            DE.nombre AS departamento_empresa,
            U.nombre_usuario,
            U.estado,
            R.nombre AS rol,
            TU.nombre AS tipo_usuario
        FROM Empleados E
        INNER JOIN Personas P ON P.cod_persona = E.cod_persona
        LEFT JOIN Correos C ON C.cod_persona = P.cod_persona
        LEFT JOIN Telefonos T ON T.cod_persona = P.cod_persona
        LEFT JOIN Direcciones D ON D.cod_persona = P.cod_persona
        LEFT JOIN Municipios M ON M.cod_municipio = D.cod_municipio
        LEFT JOIN Departamentos DP ON DP.cod_departamento = M.cod_departamento
        LEFT JOIN Departamento_Empresa DE ON DE.cod_departamento_empresa = E.cod_departamento_empresa
        LEFT JOIN Usuarios U ON U.cod_empleado = E.cod_empleado
        LEFT JOIN Roles R ON R.cod_rol = U.cod_rol
        LEFT JOIN Tipo_Usuario TU ON TU.cod_tipo_usuario = U.cod_tipo_usuario
        WHERE E.cod_empleado = PV_COD_PERSONA
        LIMIT 1;

    ELSEIF PV_ACTION = 'TODOS_CLIENTES' THEN
        SELECT 
            CL.cod_cliente,
            P.nombre_persona AS nombre,
            P.fecha_nacimiento,
            P.sexo,
            P.dni,
            C.correo,
            T.telefono,
            D.direccion,
            M.municipio,
            DP.departamento,
            CL.rtn,
            CL.tipo_cliente
        FROM Clientes CL
        INNER JOIN Personas P ON P.cod_persona = CL.cod_persona
        LEFT JOIN Correos C ON C.cod_persona = P.cod_persona
        LEFT JOIN Telefonos T ON T.cod_persona = P.cod_persona
        LEFT JOIN Direcciones D ON D.cod_persona = P.cod_persona
        LEFT JOIN Municipios M ON M.cod_municipio = D.cod_municipio
        LEFT JOIN Departamentos DP ON DP.cod_departamento = M.cod_departamento;

    ELSEIF PV_ACTION = 'TODOS_EMPLEADOS' THEN
        SELECT 
            E.cod_empleado,
            P.nombre_persona AS nombre,
            P.fecha_nacimiento,
            P.sexo,
            P.dni,
            C.correo,
            T.telefono,
            D.direccion,
            M.municipio,
            DP.departamento,
            E.cargo,
            E.salario,
            E.fecha_contratacion,
            DE.nombre AS departamento_empresa,
            U.nombre_usuario,
            U.estado,
            R.nombre AS rol,
            TU.nombre AS tipo_usuario
        FROM Empleados E
        INNER JOIN Personas P ON P.cod_persona = E.cod_persona
        LEFT JOIN Correos C ON C.cod_persona = P.cod_persona
        LEFT JOIN Telefonos T ON T.cod_persona = P.cod_persona
        LEFT JOIN Direcciones D ON D.cod_persona = P.cod_persona
        LEFT JOIN Municipios M ON M.cod_municipio = D.cod_municipio
        LEFT JOIN Departamentos DP ON DP.cod_departamento = M.cod_departamento
        LEFT JOIN Departamento_Empresa DE ON DE.cod_departamento_empresa = E.cod_departamento_empresa
        LEFT JOIN Usuarios U ON U.cod_empleado = E.cod_empleado
        LEFT JOIN Roles R ON R.cod_rol = U.cod_rol
        LEFT JOIN Tipo_Usuario TU ON TU.cod_tipo_usuario = U.cod_tipo_usuario;

    ELSEIF PV_ACTION = 'ROL' THEN
        SELECT cod_rol, nombre, descripcion
        FROM Roles
        WHERE cod_rol = PV_COD_PERSONA
        LIMIT 1;

    ELSEIF PV_ACTION = 'TODOS_ROLES' THEN
        SELECT cod_rol, nombre, descripcion
        FROM Roles;

    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'PV_ACTION no es válido.';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_cliente` (IN `p_cod_cliente` INT)   BEGIN
    SELECT * FROM clientes WHERE cod_cliente = p_cod_cliente;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_correlativo` (IN `p_cod_correlativo` INT)   BEGIN
    SELECT * FROM correlativos_factura WHERE cod_correlativo = p_cod_correlativo;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_detalle_factura` (IN `p_cod_detalle` INT)   BEGIN
    SELECT * FROM detalle_factura
    WHERE cod_detalle_factura = p_cod_detalle;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_factura` (IN `p_cod_factura` INT)   BEGIN
    SELECT * FROM facturas
    WHERE cod_factura = p_cod_factura;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_primer_acceso` (IN `pv_cod_usuario` INT, IN `pv_nueva_contrasena` VARCHAR(255))   BEGIN
    UPDATE Usuarios
    SET contrasena = pv_nueva_contrasena,
        primer_acceso = 0,
        intentos = 0
    WHERE cod_usuario = pv_cod_usuario;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_registrar_bitacora` (IN `p_cod_usuario` INT, IN `p_objeto` VARCHAR(100), IN `p_accion` VARCHAR(20), IN `p_descripcion` TEXT)   BEGIN
    INSERT INTO bitacora (cod_usuario, objeto, accion, descripcion, fecha)
    VALUES (p_cod_usuario, p_objeto, p_accion, p_descripcion, NOW());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_resetear_contrasena_token` (IN `pv_token` VARCHAR(64), IN `pv_nueva_contra` VARCHAR(255))   BEGIN
    DECLARE filas_afectadas INT;

    UPDATE Usuarios
    SET contrasena = pv_nueva_contra,
        token_recuperacion = NULL,
        expira_token = NULL
    WHERE token_recuperacion = pv_token
      AND expira_token > NOW();

    SET filas_afectadas = ROW_COUNT();

    IF filas_afectadas > 0 THEN
        SELECT 'Contraseña actualizada correctamente' AS mensaje;
    ELSE
        SELECT 'Token inválido o expirado' AS mensaje;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_resumen_cotizacion` (IN `pv_cod_cotizacion` INT)   BEGIN
    SELECT 
        c.cod_cotizacion,
        p.nombre_persona AS nombre_cliente,
        c.fecha,
        c.fecha_validez,
        MAX(e.nombre) AS nombre_evento,
        MAX(e.fecha_programa) AS fecha_programa,
        MAX(e.hora_programada) AS hora_programada,
        c.estado,

        -- Concatenación de productos en formato resumen
        GROUP_CONCAT(
            CONCAT(
                dc.cantidad, 'x ', dc.descripcion, 
                ' (', FORMAT(dc.precio_unitario, 2), ') = ', FORMAT(dc.total, 2)
            )
            SEPARATOR ', '
        ) AS productos,

        -- Total general de la cotización
        SUM(dc.total) AS monto_total

    FROM cotizacion c
    JOIN clientes cli ON c.cod_cliente = cli.cod_cliente
    JOIN personas p ON cli.cod_persona = p.cod_persona
    LEFT JOIN evento e ON e.cod_cotizacion = c.cod_cotizacion
    JOIN detalle_cotizacion dc ON dc.cod_cotizacion = c.cod_cotizacion
    WHERE pv_cod_cotizacion IS NULL OR pv_cod_cotizacion = 0 OR c.cod_cotizacion = pv_cod_cotizacion
    GROUP BY c.cod_cotizacion, p.nombre_persona, c.fecha, c.fecha_validez, c.estado;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_usuarios_con_permisos` ()   BEGIN
    SELECT 
        u.nombre_usuario,
        u.cod_rol,
        r.nombre AS rol,
        o.descripcion AS objeto,
        IF(pers.crear = 1, 'Sí', 'No') AS crear,
        IF(pers.modificar = 1, 'Sí', 'No') AS modificar,
        IF(pers.mostrar = 1, 'Sí', 'No') AS mostrar,
        IF(pers.eliminar = 1, 'Sí', 'No') AS eliminar,
        IF(u.estado = 1, 'Activo', 'Inactivo') AS estado
    FROM Usuarios u
    LEFT JOIN Roles r ON u.cod_rol = r.cod_rol
    LEFT JOIN Permisos pers ON u.cod_rol = pers.cod_rol
    LEFT JOIN Objetos o ON pers.cod_objeto = o.cod_objeto
    ORDER BY u.estado DESC, u.nombre_usuario, o.cod_objeto;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_verificar_codigo_2fa` (IN `p_cod_usuario` INT, IN `p_codigo` VARCHAR(6))   BEGIN
    SELECT 
        CASE 
            WHEN COUNT(*) > 0 THEN 1
            ELSE 0
        END AS es_valido
    FROM verificacion_2fa
    WHERE cod_usuario = p_cod_usuario
      AND codigo = p_codigo
      AND expira > NOW();
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `adicionales`
--

CREATE TABLE `adicionales` (
  `cod_adicional` int NOT NULL,
  `nombre` varchar(100) DEFAULT NULL,
  `descripcion` text,
  `precio` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `adicionales`
--

INSERT INTO `adicionales` (`cod_adicional`, `nombre`, `descripcion`, `precio`) VALUES
(2, 'Parque Vial', 'Acceso al parque vial por persona', 80.00),
(3, 'Merienda actualizada', 'Nueva descripción', 60.00),
(4, 'no se solo es prueba', 'myke la mera verdura del caldo', 2234.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bitacora`
--

CREATE TABLE `bitacora` (
  `id` int NOT NULL,
  `cod_usuario` int NOT NULL,
  `objeto` varchar(100) NOT NULL,
  `accion` varchar(20) NOT NULL,
  `descripcion` text,
  `fecha` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `bitacora`
--

INSERT INTO `bitacora` (`id`, `cod_usuario`, `objeto`, `accion`, `descripcion`, `fecha`) VALUES
(1, 1, 'Login', 'Acceso', 'Inicio de sesión exitoso desde IP ::1', '2025-06-15 06:57:04');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cai`
--

CREATE TABLE `cai` (
  `cod_cai` int NOT NULL,
  `cai` varchar(100) NOT NULL,
  `rango_desde` varchar(25) NOT NULL,
  `rango_hasta` varchar(25) NOT NULL,
  `fecha_limite` date NOT NULL,
  `estado` tinyint(1) DEFAULT '1',
  `creado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `cai`
--

INSERT INTO `cai` (`cod_cai`, `cai`, `rango_desde`, `rango_hasta`, `fecha_limite`, `estado`, `creado_en`) VALUES
(2, 'CAI-TEST-123456', '00000001', '00005000', '2025-12-16', 0, '2025-06-13 03:20:31'),
(3, 'CAI-TEST-123456-Ulmate', '00020001', '00150000', '2025-12-19', 1, '2025-06-13 16:34:02');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clientes`
--

CREATE TABLE `clientes` (
  `cod_cliente` int NOT NULL,
  `rtn` varchar(20) DEFAULT NULL,
  `tipo_cliente` enum('Individual','Empresa') DEFAULT NULL,
  `cod_persona` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `clientes`
--

INSERT INTO `clientes` (`cod_cliente`, `rtn`, `tipo_cliente`, `cod_persona`) VALUES
(2, '08199912345', 'Empresa', 15),
(3, '0801199912345', 'Individual', 16),
(4, '0801199345', 'Individual', 17),
(5, '0801199912345', 'Individual', 21),
(6, '777653425', 'Individual', 26),
(12, '3232332', 'Individual', 32),
(13, '345222211', 'Individual', 33),
(14, '65372333', 'Individual', 34),
(15, '77222425', 'Individual', 35),
(17, '342872211', 'Individual', 37),
(18, '457783632', 'Individual', 43),
(22, '0801199912345', 'Individual', 16);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `correos`
--

CREATE TABLE `correos` (
  `cod_correo` int NOT NULL,
  `correo` varchar(255) DEFAULT NULL,
  `cod_persona` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `correos`
--

INSERT INTO `correos` (`cod_correo`, `correo`, `cod_persona`) VALUES
(6, 'michitogarcia.mg@gmail.com', 6),
(7, 'carlos.mendoza@gmail.com', 7),
(8, 'carlos.rivera@gmail.com', 10),
(9, 'guerraclanes65@gmail.com', 14),
(10, 'juansdarez@gmail.com', 15),
(11, 'juanperez@gmail.com', 16),
(12, 'jua453rez@gmail.com', 17),
(13, 'camila@example.com', 21),
(14, 'ju222ez@gmail.com', 26),
(20, 'myke_mg@correo.com', 32),
(21, 'myke_mg@correo.com', 33),
(22, 'myke_mg@correo.com', 34),
(23, 'ju222e22z@gmail.com', 35),
(25, 'hackerputos2@gmail.com', 37),
(26, 'miguelbarahona718@gmail.com', 38),
(27, 'hackerputos2@gmail.com', 39),
(28, 'michitogarcia12@gmail.com', 40),
(29, 'miguelbarahona718@gmail.com', 41),
(30, 'miguelgarcia@gmail.com', 43),
(33, 'narutoizumaki265@gmail.com', 46),
(34, 'narutoizumaki265@gmail.com', 47),
(35, 'momobellaco@gmail.com', 49),
(36, 'momobellaco@gmail.com', 50);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cotizacion`
--

CREATE TABLE `cotizacion` (
  `cod_cotizacion` int NOT NULL,
  `cod_cliente` int NOT NULL,
  `fecha` date NOT NULL DEFAULT (curdate()),
  `fecha_validez` date NOT NULL,
  `estado` enum('pendiente','confirmada','expirada','completada') DEFAULT 'pendiente'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `cotizacion`
--

INSERT INTO `cotizacion` (`cod_cotizacion`, `cod_cliente`, `fecha`, `fecha_validez`, `estado`) VALUES
(1, 2, '2025-06-07', '2025-06-12', 'pendiente'),
(2, 3, '2025-06-07', '2025-06-12', 'pendiente'),
(3, 4, '2025-06-07', '2025-06-12', 'pendiente'),
(4, 5, '2025-06-07', '2025-06-12', 'pendiente'),
(5, 6, '2025-06-07', '2025-06-12', 'pendiente'),
(11, 12, '2025-06-07', '2025-06-12', 'pendiente'),
(12, 13, '2025-06-07', '2025-06-12', 'pendiente'),
(13, 14, '2025-06-07', '2025-06-12', 'pendiente'),
(14, 15, '2025-06-07', '2025-06-12', 'pendiente'),
(16, 17, '2025-06-07', '2025-06-12', 'pendiente'),
(17, 18, '2025-06-08', '2025-06-13', 'pendiente');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `departamentos`
--

CREATE TABLE `departamentos` (
  `cod_departamento` int NOT NULL,
  `departamento` varchar(60) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `departamentos`
--

INSERT INTO `departamentos` (`cod_departamento`, `departamento`) VALUES
(1, 'Atlántida'),
(2, 'Choluteca'),
(3, 'Colón'),
(4, 'Comayagua'),
(5, 'Copán'),
(6, 'Cortés'),
(7, 'El Paraíso'),
(8, 'Francisco Morazán'),
(9, 'Gracias a Dios'),
(10, 'Intibucá'),
(11, 'Islas de la Bahía'),
(12, 'La Paz'),
(13, 'Lempira'),
(14, 'Ocotepeque'),
(15, 'Olancho'),
(16, 'Santa Bárbara'),
(17, 'Valle'),
(18, 'Yoro');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `departamento_empresa`
--

CREATE TABLE `departamento_empresa` (
  `cod_departamento_empresa` int NOT NULL,
  `nombre` varchar(60) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `departamento_empresa`
--

INSERT INTO `departamento_empresa` (`cod_departamento_empresa`, `nombre`) VALUES
(1, 'Dirección General'),
(2, 'Facturación'),
(3, 'Eventos'),
(4, 'Recorridos Escolares');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_cotizacion`
--

CREATE TABLE `detalle_cotizacion` (
  `cod_detallecotizacion` int NOT NULL,
  `cantidad` int NOT NULL,
  `descripcion` text NOT NULL,
  `precio_unitario` decimal(10,2) NOT NULL,
  `total` decimal(10,2) NOT NULL,
  `cod_cotizacion` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `detalle_cotizacion`
--

INSERT INTO `detalle_cotizacion` (`cod_detallecotizacion`, `cantidad`, `descripcion`, `precio_unitario`, `total`, `cod_cotizacion`) VALUES
(1, 2, 'Silla blanca', 25.00, 50.00, 1),
(2, 1, 'Proyector HD', 500.00, 500.00, 1),
(6, 5, 'Silla VIP', 35.00, 175.00, 2),
(7, 1, 'Pantalla gigante', 1800.00, 1800.00, 2),
(19, 10, 'Silla blanca', 25.00, 250.00, 3),
(20, 2, 'Proyector HD', 500.00, 1000.00, 3),
(21, 1, 'Equipo de sonido', 1000.00, 1000.00, 3),
(22, 5, 'Mesa redonda', 150.00, 750.00, 3),
(23, 10, 'Mantel blanco', 35.00, 350.00, 3),
(24, 10, 'probando json 200', 5000.00, 50000.00, 3),
(26, 2, 'Tour Guiado', 250.00, 500.00, 4),
(27, 1, 'Paquete Familiar', 950.00, 950.00, 4),
(29, 10, 'Silla blnca', 25.00, 250.00, 5),
(30, 2, 'Proyector HD', 500.00, 1000.00, 5),
(31, 1, 'Equipo de sonido', 1000.00, 1000.00, 5),
(32, 4, 'espero que funcione esta vez', 2343.00, 9372.00, 11),
(33, 2, 'pruebita', 213.00, 426.00, 12),
(34, 234, 'sera que si funciona', 23.00, 5382.00, 13),
(35, 10, 'Silla blnca', 75.00, 750.00, 14),
(36, 2, 'Proyector HD', 500.00, 1000.00, 14),
(37, 1, 'Equipo de sonido', 1000.00, 1000.00, 14),
(41, 1, 'dffdf', 232.00, 232.00, 16),
(42, 1, 'vfvfdd', 234.00, 234.00, 16),
(44, 1, 'a festejar', 200.00, 200.00, 17),
(45, 3, 'champions', 4388.00, 13164.00, 17);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_factura`
--

CREATE TABLE `detalle_factura` (
  `cod_detalle_factura` int NOT NULL,
  `cod_factura` int NOT NULL,
  `cantidad` int NOT NULL,
  `descripcion` text NOT NULL,
  `precio_unitario` decimal(10,2) NOT NULL,
  `total` decimal(10,2) NOT NULL,
  `tipo` enum('Evento','Entrada','Paquete','Adicional','Inventario','Otro') NOT NULL,
  `referencia` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `detalle_factura`
--

INSERT INTO `detalle_factura` (`cod_detalle_factura`, `cod_factura`, `cantidad`, `descripcion`, `precio_unitario`, `total`, `tipo`, `referencia`) VALUES
(1, 1, 2, 'Silla blanca', 25.00, 50.00, 'Evento', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `direcciones`
--

CREATE TABLE `direcciones` (
  `cod_direccion` int NOT NULL,
  `direccion` text,
  `cod_persona` int DEFAULT NULL,
  `cod_municipio` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `direcciones`
--

INSERT INTO `direcciones` (`cod_direccion`, `direccion`, `cod_persona`, `cod_municipio`) VALUES
(6, 'Zambrano actualizado', 6, 3),
(7, 'Col. El Sauce, Tegucigalpa', 7, 2),
(8, 'Barrio Abajo, Tegucigalpa', 10, 3),
(9, 'Col. Las Brisas, Tegucigalpa', 14, 3),
(10, 'Col. San Ángel', 15, 1),
(11, 'Col. Las Uvas', 16, 1),
(12, 'Colonia Las Uvas', 17, 1),
(13, 'Col. Palmira, Tegucigalpa', 21, 1),
(14, 'Colonia Las Uvas', 26, 1),
(20, 'sdfghgfd', 32, 1),
(21, 'gguhhhhuhubuu', 33, 1),
(22, 'hola prueba', 34, 1),
(23, 'Colonia Las Uvas', 35, 1),
(25, 'dcsdcdscs', 37, 1),
(26, 'Canaán', 38, 2),
(27, 'Col. El Prado, Casa 15', 39, 2),
(28, 'Col. Las Brisas, Tegucigalpa', 40, 3),
(29, 'Canaán', 41, 2),
(30, 'aldea zambrano', 43, 2),
(33, 'Col. Las Brisas, Tegucigalpa', 46, 3),
(34, 'Zambrano', 47, 2),
(35, 'Siguatepeque', 49, 1),
(36, 'hjasjsjasjajsajsa', 50, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empleados`
--

CREATE TABLE `empleados` (
  `cod_empleado` int NOT NULL,
  `cargo` varchar(50) DEFAULT NULL,
  `salario` decimal(10,2) NOT NULL,
  `fecha_contratacion` datetime DEFAULT NULL,
  `cod_persona` int DEFAULT NULL,
  `cod_departamento_empresa` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `empleados`
--

INSERT INTO `empleados` (`cod_empleado`, `cargo`, `salario`, `fecha_contratacion`, `cod_persona`, `cod_departamento_empresa`) VALUES
(6, 'Admin total', 95000.00, '2025-05-07 00:00:00', 6, 1),
(7, 'Coordinador de Eventos', 22000.00, '2025-06-07 00:00:00', 10, 2),
(8, 'Técnico audiovisual', 16000.00, '2025-06-10 00:00:00', 14, 2),
(9, 'La Bonita del Grupo', 89000.00, '2025-06-18 00:00:00', 38, 2),
(10, 'The Best', 56897.00, '2024-12-25 00:00:00', 39, 3),
(11, 'Técnico audiovisual', 15000.00, '2025-06-10 00:00:00', 40, 1),
(12, 'La Bonita del Grupo', 23451.00, '2025-06-18 00:00:00', 41, 2),
(13, 'Técnico audiovisual', 15000.00, '2025-06-10 00:00:00', 46, 1),
(14, 'solo se que ya no', 12000.00, '2024-10-09 00:00:00', 47, 2),
(15, 'Barcelona', 12345.00, '2025-02-12 00:00:00', 49, 1),
(16, 'probando valiaaciones', 89999.00, '2025-03-04 00:00:00', 50, 1),
(17, 'Administrador del sistema', 50000.00, '2025-06-20 21:18:27', 52, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `entradas`
--

CREATE TABLE `entradas` (
  `cod_entrada` int NOT NULL,
  `nombre` varchar(100) DEFAULT NULL,
  `precio` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `entradas`
--

INSERT INTO `entradas` (`cod_entrada`, `nombre`, `precio`) VALUES
(1, 'Entrada General', 150.00),
(2, 'Entrada VIP actualizada', 400.00),
(3, 'myke mejor', 1234.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `evento`
--

CREATE TABLE `evento` (
  `cod_evento` int NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `fecha_programa` date NOT NULL,
  `hora_programada` time NOT NULL,
  `cod_cotizacion` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `evento`
--

INSERT INTO `evento` (`cod_evento`, `nombre`, `fecha_programa`, `hora_programada`, `cod_cotizacion`) VALUES
(1, 'Fiesta de cumpleaños', '2025-07-10', '15:30:00', 1),
(2, 'Cumpleaños de Sofía', '2025-07-10', '15:30:00', 2),
(3, 'Cumpleos de Sofía', '2025-07-10', '15:30:00', 3),
(4, 'Evento Educativo', '2025-07-01', '09:30:00', 4),
(5, 'Cum de Sofía', '2025-07-10', '19:30:00', 5),
(11, 'ya que se poner', '2025-06-17', '22:22:00', 11),
(12, 'probado alertas', '2025-06-16', '21:29:00', 12),
(13, 'alertas si?', '2025-06-15', '23:39:00', 13),
(14, 'Cum de Sofía', '2025-07-10', '19:30:00', 14),
(16, 'dfsdcdsvd', '2025-06-09', '22:45:00', 16),
(17, 'Gano Portugal', '2025-06-08', '22:00:00', 17);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `facturas`
--

CREATE TABLE `facturas` (
  `cod_factura` int NOT NULL,
  `numero_factura` varchar(30) NOT NULL,
  `fecha_emision` date NOT NULL,
  `cod_cliente` int NOT NULL,
  `direccion` text NOT NULL,
  `rtn` varchar(20) DEFAULT NULL,
  `cod_cai` int NOT NULL,
  `rango_desde` varchar(25) DEFAULT NULL,
  `rango_hasta` varchar(25) DEFAULT NULL,
  `fecha_limite` date DEFAULT NULL,
  `tipo_factura` enum('Evento','Recorrido Escolar','Taquilla General','Libros') NOT NULL,
  `descuento_otorgado` decimal(10,2) DEFAULT '0.00',
  `rebajas_otorgadas` decimal(10,2) DEFAULT '0.00',
  `importe_exento` decimal(10,2) DEFAULT '0.00',
  `importe_gravado_18` decimal(10,2) DEFAULT '0.00',
  `importe_gravado_15` decimal(10,2) DEFAULT '0.00',
  `impuesto_15` decimal(10,2) DEFAULT '0.00',
  `impuesto_18` decimal(10,2) DEFAULT '0.00',
  `importe_exonerado` decimal(10,2) DEFAULT '0.00',
  `subtotal` decimal(10,2) NOT NULL,
  `total_pago` decimal(10,2) NOT NULL,
  `observaciones` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `facturas`
--

INSERT INTO `facturas` (`cod_factura`, `numero_factura`, `fecha_emision`, `cod_cliente`, `direccion`, `rtn`, `cod_cai`, `rango_desde`, `rango_hasta`, `fecha_limite`, `tipo_factura`, `descuento_otorgado`, `rebajas_otorgadas`, `importe_exento`, `importe_gravado_18`, `importe_gravado_15`, `impuesto_15`, `impuesto_18`, `importe_exonerado`, `subtotal`, `total_pago`, `observaciones`) VALUES
(1, 'F2025-0001', '2025-06-25', 2, 'Col. Centro, Tegucigalpa', '0801199912345', 3, '00020001', '00150000', '2025-12-19', 'Evento', 0.00, 0.00, 0.00, 1500.00, 0.00, 0.00, 270.00, 0.00, 1500.00, 1770.00, 'Evento de prueba');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint UNSIGNED NOT NULL,
  `uuid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `inventario`
--

CREATE TABLE `inventario` (
  `cod_inventario` int NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text,
  `precio_unitario` decimal(10,2) NOT NULL,
  `cantidad_disponible` int NOT NULL,
  `estado` tinyint(1) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `inventario`
--

INSERT INTO `inventario` (`cod_inventario`, `nombre`, `descripcion`, `precio_unitario`, `cantidad_disponible`, `estado`) VALUES
(2, 'Laptop Gamer Actualizada', 'Asus ROG Strix 2025', 1599.99, 13, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint UNSIGNED NOT NULL,
  `queue` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint UNSIGNED NOT NULL,
  `reserved_at` int UNSIGNED DEFAULT NULL,
  `available_at` int UNSIGNED NOT NULL,
  `created_at` int UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `migrations`
--

CREATE TABLE `migrations` (
  `id` int UNSIGNED NOT NULL,
  `migration` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `municipios`
--

CREATE TABLE `municipios` (
  `cod_municipio` int NOT NULL,
  `municipio` varchar(60) NOT NULL,
  `cod_departamento` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `municipios`
--

INSERT INTO `municipios` (`cod_municipio`, `municipio`, `cod_departamento`) VALUES
(1, 'La Ceiba', 1),
(2, 'El Porvenir', 1),
(3, 'Tela', 1),
(4, 'Jutiapa', 1),
(5, 'La Masica', 1),
(6, 'San Francisco', 1),
(7, 'Arizona', 1),
(8, 'Esparta', 1),
(9, 'Choluteca', 2),
(10, 'Apacilagua', 2),
(11, 'Concepción de María', 2),
(12, 'Duyure', 2),
(13, 'El Corpus', 2),
(14, 'El Triunfo', 2),
(15, 'Marcovia', 2),
(16, 'Morolica', 2),
(17, 'Namasigüe', 2),
(18, 'Orocuina', 2),
(19, 'Pespire', 2),
(20, 'San Antonio de Flores', 2),
(21, 'San Isidro', 2),
(22, 'San José', 2),
(23, 'San Marcos de Colón', 2),
(24, 'Santa Ana de Yusguare', 2),
(25, 'Trujillo', 3),
(26, 'Balfate', 3),
(27, 'Iriona', 3),
(28, 'Limón', 3),
(29, 'Sabá', 3),
(30, 'Santa Fe', 3),
(31, 'Santa Rosa de Aguán', 3),
(32, 'Sonaguera', 3),
(33, 'Tocoa', 3),
(34, 'Bonito Oriental', 3),
(35, 'Comayagua', 4),
(36, 'Ajuterique', 4),
(37, 'El Rosario', 4),
(38, 'Esquías', 4),
(39, 'Humuya', 4),
(40, 'La Libertad', 4),
(41, 'Lamaní', 4),
(42, 'La Trinidad', 4),
(43, 'Lejamaní', 4),
(44, 'Meámbar', 4),
(45, 'Minas de Oro', 4),
(46, 'Ojos de Agua', 4),
(47, 'San Jerónimo', 4),
(48, 'San José de Comayagua', 4),
(49, 'San José del Potrero', 4),
(50, 'San Luis', 4),
(51, 'San Sebastián', 4),
(52, 'Siguatepeque', 4),
(53, 'Villa de San Antonio', 4),
(54, 'Las Lajas', 4),
(55, 'Taulabé', 4),
(56, 'Santa Rosa de Copán', 5),
(57, 'Cabañas', 5),
(58, 'Concepción', 5),
(59, 'Copán Ruinas', 5),
(60, 'Corquín', 5),
(61, 'Cucuyagua', 5),
(62, 'Dolores', 5),
(63, 'Dulce Nombre', 5),
(64, 'El Paraíso', 5),
(65, 'Florida', 5),
(66, 'La Jigua', 5),
(67, 'La Unión', 5),
(68, 'Nueva Arcadia', 5),
(69, 'San Agustín', 5),
(70, 'San Antonio', 5),
(71, 'San Jerónimo', 5),
(72, 'San José', 5),
(73, 'San Juan de Opoa', 5),
(74, 'San Nicolás', 5),
(75, 'San Pedro', 5),
(76, 'Santa Rita', 5),
(77, 'Trinidad de Copán', 5),
(78, 'Veracruz', 5),
(79, 'San Pedro Sula', 6),
(80, 'Choloma', 6),
(81, 'Omoa', 6),
(82, 'Pimienta', 6),
(83, 'Potrerillos', 6),
(84, 'Puerto Cortés', 6),
(85, 'San Antonio de Cortés', 6),
(86, 'San Francisco de Yojoa', 6),
(87, 'San Manuel', 6),
(88, 'Santa Cruz de Yojoa', 6),
(89, 'Villanueva', 6),
(90, 'La Lima', 6),
(91, 'Yuscarán', 7),
(92, 'Alauca', 7),
(93, 'Danlí', 7),
(94, 'El Paraíso', 7),
(95, 'Güinope', 7),
(96, 'Jacaleapa', 7),
(97, 'Liure', 7),
(98, 'Morocelí', 7),
(99, 'Oropolí', 7),
(100, 'Potrerillos', 7),
(101, 'San Antonio de Flores', 7),
(102, 'San Lucas', 7),
(103, 'San Matías', 7),
(104, 'Soledad', 7),
(105, 'Teupasenti', 7),
(106, 'Texiguat', 7),
(107, 'Vado Ancho', 7),
(108, 'Yauyupe', 7),
(109, 'Trojes', 7),
(110, 'Distrito Central', 8),
(111, 'Alubarén', 8),
(112, 'Cedros', 8),
(113, 'Curarén', 8),
(114, 'El Porvenir', 8),
(115, 'Guaimaca', 8),
(116, 'La Libertad', 8),
(117, 'La Venta', 8),
(118, 'Lepaterique', 8),
(119, 'Maraita', 8),
(120, 'Marale', 8),
(121, 'Nueva Armenia', 8),
(122, 'Ojojona', 8),
(123, 'Orica', 8),
(124, 'Reitoca', 8),
(125, 'Sabanagrande', 8),
(126, 'San Antonio de Oriente', 8),
(127, 'San Buenaventura', 8),
(128, 'San Ignacio', 8),
(129, 'Cantarranas', 8),
(130, 'San Miguelito', 8),
(131, 'Santa Ana', 8),
(132, 'Santa Lucía', 8),
(133, 'Talanga', 8),
(134, 'Tatumbla', 8),
(135, 'Valle de Ángeles', 8),
(136, 'Villa de San Francisco', 8),
(137, 'Vallecillo', 8),
(138, 'Puerto Lempira', 9),
(139, 'Brus Laguna', 9),
(140, 'Ahuas', 9),
(141, 'Juan Francisco Bulnes', 9),
(142, 'Villeda Morales', 9),
(143, 'Wampusirpe', 9),
(144, 'La Esperanza', 10),
(145, 'Camasca', 10),
(146, 'Colomoncagua', 10),
(147, 'Concepción', 10),
(148, 'Dolores', 10),
(149, 'Intibucá', 10),
(150, 'Jesús de Otoro', 10),
(151, 'Magdalena', 10),
(152, 'Masaguara', 10),
(153, 'San Antonio', 10),
(154, 'San Isidro', 10),
(155, 'San Juan', 10),
(156, 'San Marcos de la Sierra', 10),
(157, 'San Miguel Guancapla', 10),
(158, 'Santa Lucía', 10),
(159, 'Yamaranguila', 10),
(160, 'San Francisco de Opalaca', 10),
(161, 'Roatán', 11),
(162, 'Guanaja', 11),
(163, 'José Santos Guardiola', 11),
(164, 'Utila', 11),
(165, 'La Paz', 12),
(166, 'Aguanqueterique', 12),
(167, 'Cabañas', 12),
(168, 'Cane', 12),
(169, 'Chinacla', 12),
(170, 'Guajiquiro', 12),
(171, 'Lauterique', 12),
(172, 'Marcala', 12),
(173, 'Mercedes de Oriente', 12),
(174, 'Opatoro', 12),
(175, 'San Antonio del Norte', 12),
(176, 'San José', 12),
(177, 'San Juan', 12),
(178, 'San Pedro de Tutule', 12),
(179, 'Santa Ana', 12),
(180, 'Santa Elena', 12),
(181, 'Santa María', 12),
(182, 'Santiago de Puringla', 12),
(183, 'Yarula', 12),
(184, 'Gracias', 13),
(185, 'Belén', 13),
(186, 'Candelaria', 13),
(187, 'Cololaca', 13),
(188, 'Erandique', 13),
(189, 'Gualcince', 13),
(190, 'Guarita', 13),
(191, 'La Campa', 13),
(192, 'La Iguala', 13),
(193, 'Las Flores', 13),
(194, 'La Unión', 13),
(195, 'La Virtud', 13),
(196, 'Lepaera', 13),
(197, 'Mapulaca', 13),
(198, 'Piraera', 13),
(199, 'San Andrés', 13),
(200, 'San Francisco', 13),
(201, 'San Juan Guarita', 13),
(202, 'San Manuel Colohete', 13),
(203, 'San Rafael', 13),
(204, 'San Sebastián', 13),
(205, 'Santa Cruz', 13),
(206, 'Talgua', 13),
(207, 'Tambla', 13),
(208, 'Tomalá', 13),
(209, 'Valladolid', 13),
(210, 'Virginia', 13),
(211, 'San Marcos de Caiquín', 13),
(212, 'Ocotepeque', 14),
(213, 'Belén Gualcho', 14),
(214, 'Concepción', 14),
(215, 'Dolores Merendón', 14),
(216, 'Fraternidad', 14),
(217, 'La Encarnación', 14),
(218, 'La Labor', 14),
(219, 'Lucerna', 14),
(220, 'Mercedes', 14),
(221, 'San Fernando', 14),
(222, 'San Francisco del Valle', 14),
(223, 'San Jorge', 14),
(224, 'San Marcos', 14),
(225, 'Santa Fe', 14),
(226, 'Sensenti', 14),
(227, 'Sinuapa', 14),
(228, 'Juticalpa', 15),
(229, 'Campamento', 15),
(230, 'Catacamas', 15),
(231, 'Concordia', 15),
(232, 'Dulce Nombre de Culmí', 15),
(233, 'El Rosario', 15),
(234, 'Esquipulas del Norte', 15),
(235, 'Gualaco', 15),
(236, 'Guarizama', 15),
(237, 'Guata', 15),
(238, 'Guayape', 15),
(239, 'Jano', 15),
(240, 'La Unión', 15),
(241, 'Mangulile', 15),
(242, 'Manto', 15),
(243, 'Salamá', 15),
(244, 'San Esteban', 15),
(245, 'San Francisco de Becerra', 15),
(246, 'San Francisco de la Paz', 15),
(247, 'Santa María del Real', 15),
(248, 'Silca', 15),
(249, 'Yocón', 15),
(250, 'Patuca', 15),
(251, 'Santa Bárbara', 16),
(252, 'Arada', 16),
(253, 'Atima', 16),
(254, 'Azacualpa', 16),
(255, 'Ceguaca', 16),
(256, 'Concepción del Norte', 16),
(257, 'Concepción del Sur', 16),
(258, 'Chinda', 16),
(259, 'El Níspero', 16),
(260, 'Gualala', 16),
(261, 'Ilama', 16),
(262, 'Las Vegas', 16),
(263, 'Macuelizo', 16),
(264, 'Naranjito', 16),
(265, 'Nuevo Celilac', 16),
(266, 'Nueva Frontera', 16),
(267, 'Petoa', 16),
(268, 'Protección', 16),
(269, 'Quimistán', 16),
(270, 'San Francisco de Ojuera', 16),
(271, 'San José de las Colinas', 16),
(272, 'San Luis', 16),
(273, 'San Marcos', 16),
(274, 'San Nicolás', 16),
(275, 'San Pedro Zacapa', 16),
(276, 'San Vicente Centenario', 16),
(277, 'Santa Rita', 16),
(278, 'Trinidad', 16),
(279, 'Nacaome', 17),
(280, 'Alianza', 17),
(281, 'Amapala', 17),
(282, 'Aramecina', 17),
(283, 'Caridad', 17),
(284, 'Goascorán', 17),
(285, 'Langue', 17),
(286, 'San Francisco de Coray', 17),
(287, 'San Lorenzo', 17),
(288, 'Yoro', 18),
(289, 'Arenal', 18),
(290, 'El Negrito', 18),
(291, 'El Progreso', 18),
(292, 'Jocón', 18),
(293, 'Morazán', 18),
(294, 'Olanchito', 18),
(295, 'Santa Rita', 18),
(296, 'Sulaco', 18),
(297, 'Victoria', 18),
(298, 'Yorito', 18);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `objetos`
--

CREATE TABLE `objetos` (
  `cod_objeto` int NOT NULL,
  `tipo_objeto` varchar(50) DEFAULT NULL,
  `descripcion` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `objetos`
--

INSERT INTO `objetos` (`cod_objeto`, `tipo_objeto`, `descripcion`) VALUES
(1, 'Pantalla', 'Gestión de empleados'),
(2, 'Pantalla', 'Gestión de productos'),
(3, 'Pantalla', 'Gestión de salones'),
(4, 'Pantalla', 'Gestión de cotizaciones'),
(5, 'Pantalla', 'Gestión de reservaciones'),
(6, 'Pantalla', 'Facturación de eventos'),
(7, 'Pantalla', 'Facturación de entradas generales'),
(8, 'Pantalla', 'Panel de administración'),
(9, 'Pantalla', 'Gestión de CAI'),
(10, 'Pantalla', 'Bitácora del sistema'),
(11, 'Pantalla', 'Gestión de clientes'),
(12, 'Pantalla', 'Gestión de recorridos escolares'),
(13, 'Pantalla', 'Gestión de Backup');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `paquetes`
--

CREATE TABLE `paquetes` (
  `cod_paquete` int NOT NULL,
  `nombre` varchar(100) DEFAULT NULL,
  `descripcion` text,
  `precio` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `paquetes`
--

INSERT INTO `paquetes` (`cod_paquete`, `nombre`, `descripcion`, `precio`) VALUES
(1, 'Paquete VIP Actualizado', 'Incluye acceso VIP, catering de lujo, transporte y hospedaje', 3800.00),
(3, 'nuevo paquete xq si', 'myke el mejor', 5342.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `permisos`
--

CREATE TABLE `permisos` (
  `cod_permiso` int NOT NULL,
  `cod_rol` int DEFAULT NULL,
  `cod_objeto` int DEFAULT NULL,
  `nombre` varchar(50) DEFAULT NULL,
  `crear` tinyint(1) DEFAULT '0',
  `modificar` tinyint(1) DEFAULT '0',
  `mostrar` tinyint(1) DEFAULT '0',
  `eliminar` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `permisos`
--

INSERT INTO `permisos` (`cod_permiso`, `cod_rol`, `cod_objeto`, `nombre`, `crear`, `modificar`, `mostrar`, `eliminar`) VALUES
(1, 1, 1, 'Acceso total a Gestión de empleados', 1, 1, 1, 1),
(2, 1, 2, 'Acceso total a Gestión de productos', 1, 1, 1, 1),
(3, 1, 3, 'Acceso total a Gestión de salones', 1, 1, 1, 1),
(4, 1, 4, 'Acceso total a Gestión de cotizaciones', 1, 1, 1, 1),
(5, 1, 5, 'Acceso total a Gestión de reservaciones', 1, 1, 1, 1),
(6, 1, 6, 'Acceso total a Facturación de eventos', 1, 1, 1, 1),
(7, 1, 7, 'Acceso total a Facturación de entradas generales', 1, 1, 1, 1),
(8, 2, 8, 'Acceso total a Panel de administración', 1, 1, 1, 1),
(9, 1, 9, 'Acceso total a Gestión de CAI', 1, 1, 1, 1),
(10, 1, 10, 'Acceso total a Bitácora del sistema', 1, 1, 1, 1),
(16, 2, 6, 'Facturación de eventos', 1, 0, 1, 0),
(17, 3, 2, 'Gestión de productos', 0, 1, 1, 0),
(18, 4, 3, 'Gestión de salones', 1, 1, 1, 1),
(19, 4, 4, 'Gestión de cotizaciones', 1, 1, 1, 1),
(20, 4, 5, 'Gestión de reservaciones', 1, 1, 1, 1),
(21, 5, 7, 'Facturación entradas generales', 1, 0, 1, 0),
(23, 9, 5, 'Permiso actualizado por myke', 1, 0, 1, 1),
(25, 1, 11, 'Acceso total a Gestión de clientes', 1, 1, 1, 1),
(26, 1, 12, 'Acceso total a Gestión de recorridos escolares', 1, 1, 1, 1),
(27, 1, 8, 'Acceso total al Panel de administración', 1, 1, 1, 1),
(28, 1, 13, 'Acceso total a Gestión de Backup', 1, 1, 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `personas`
--

CREATE TABLE `personas` (
  `cod_persona` int NOT NULL,
  `nombre_persona` varchar(100) NOT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `sexo` enum('Masculino','Femenino') DEFAULT NULL,
  `dni` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `personas`
--

INSERT INTO `personas` (`cod_persona`, `nombre_persona`, `fecha_nacimiento`, `sexo`, `dni`) VALUES
(6, 'Miguel García', '2025-05-15', 'Masculino', '0801890021222'),
(7, 'Carlos Mendoza', '1990-12-05', 'Masculino', '0801199012345'),
(10, 'Carlos Riveras', '1992-03-20', 'Masculino', '0801199211223'),
(14, 'Javier Salgado si paso la prue', '1990-06-15', 'Masculino', '5674625387985'),
(15, 'Juan josue', '1990-06-15', 'Masculino', '08011912345'),
(16, 'Juan Pérez', '1990-06-15', 'Masculino', '0801199912345'),
(17, 'probanddo api', '1990-06-15', 'Masculino', '080912345'),
(21, 'Camila García', '1995-08-12', 'Femenino', '0801199512345'),
(26, 'probando el tipo', '9999-06-15', 'Masculino', '080120032341'),
(32, 'probando la vista', '2002-02-07', 'Masculino', '080120222222'),
(33, 'probando sweetalert2', '2001-12-31', 'Masculino', '08103421'),
(34, 'miguel barahona', '2008-01-29', 'Masculino', '08102345'),
(35, 'probando el tipo rsultad', '9999-06-15', 'Masculino', '333332341'),
(37, 'probando la vista', '2001-06-05', 'Masculino', '080120031345'),
(38, 'kellyn Castillo', '1996-05-05', 'Masculino', '08190121'),
(39, 'Admin Lord', '1997-01-07', 'Masculino', '080120259801'),
(40, 'Enviar Credenciales', '1990-06-15', 'Masculino', '89129011000'),
(41, 'kellyn Castillo', '2003-06-09', 'Masculino', '6754333'),
(43, 'san antonio', '2025-06-17', 'Masculino', '0890109122'),
(46, 'probando api', '1990-06-15', 'Masculino', '12098211221'),
(47, 'ya se jodio', '2024-11-12', 'Masculino', '65782129876'),
(49, 'funxiona siono', '2007-01-30', 'Masculino', '2345232314151'),
(50, 'Ultima prueba', '2001-02-14', 'Masculino', '6532653265236'),
(52, 'Luis Molina', '1990-01-01', 'Masculino', '0801199011111');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `roles`
--

CREATE TABLE `roles` (
  `cod_rol` int NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `descripcion` text,
  `estado` tinyint NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `roles`
--

INSERT INTO `roles` (`cod_rol`, `nombre`, `descripcion`, `estado`) VALUES
(1, 'Dirección', 'probando api con laravel', 1),
(2, 'FacEL', NULL, 1),
(3, 'Escolar', NULL, 1),
(4, 'Evento', NULL, 1),
(5, 'Factaquilla', NULL, 1),
(8, 'Myke_pros', 'Es el mejor programando, la real.', 1),
(9, 'ADMON Reservas', 'NUEVO PERMISO.', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `salones`
--

CREATE TABLE `salones` (
  `cod_salon` int NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text,
  `capacidad` int DEFAULT NULL,
  `estado` tinyint DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `salones`
--

INSERT INTO `salones` (`cod_salon`, `nombre`, `descripcion`, `capacidad`, `estado`) VALUES
(1, 'Plaza Cultural', 'Área abierta para actividades culturales.', 200, 1),
(2, 'Salón VIP Gold', 'Salón remodelado con barra premium', 400, 0),
(3, 'Salón VIP', 'Salón remodelado con capacidad para 300 personas.', 300, 1),
(4, 'Auditorio Central', 'Auditorio techado con escenario y sonido.', 120, 1),
(6, 'Salón VIP', 'Interior con aire acondicionado y mobiliario moderno.', 35, 1),
(7, 'Salón Creativo', 'Espacio interior ideal para talleres educativos.', 50, 1),
(8, 'Salón Principal', 'Salón amplio con capacidad para 500 personas.', 500, 1),
(12, 'myke', 'jndhsdfhifsdihdfsihdfsih', 234235, 1),
(13, 'ya estoy aburrido', 'hhbhjubjbj', 4345, 1),
(14, 'ya estoy aburrido', 'fsdfdf', 234, 1),
(15, 'asdfdf', 'sasfdfsdf', 234, 1),
(16, 'asdfdf', 'sasfdfsdf', 234, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `salon_horario`
--

CREATE TABLE `salon_horario` (
  `cod_salon_horario` int NOT NULL,
  `cod_salon` int DEFAULT NULL,
  `cod_tipo_horario` int DEFAULT NULL,
  `precio` decimal(10,2) DEFAULT NULL,
  `precio_hora_extra` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `salon_horario`
--

INSERT INTO `salon_horario` (`cod_salon_horario`, `cod_salon`, `cod_tipo_horario`, `precio`, `precio_hora_extra`) VALUES
(1, 1, 1, 1200.00, 100.00),
(2, 1, 2, 1380.00, 150.00),
(3, 2, 1, 10000.00, 1200.00),
(4, 2, 2, 16000.00, 1800.00),
(5, 3, 1, 120.00, 100.00),
(6, 3, 2, 180.00, 150.00),
(7, 4, 1, 1800.00, 200.00),
(8, 4, 2, 2070.00, 300.00),
(11, 6, 1, 1100.00, 800.00),
(12, 6, 2, 1265.00, 900.00),
(13, 7, 1, 800.00, 87.00),
(14, 7, 2, 920.00, 200.00),
(15, 8, 1, 100.00, 80.00),
(16, 8, 2, 150.00, 90.00),
(23, 12, 1, 12321.00, 43421.00),
(24, 12, 2, 32411.00, 1234.00),
(25, 13, 1, 12346.00, 234.00),
(26, 13, 2, 12345.00, 234.00),
(27, 14, 1, 2332.00, 23.00),
(28, 14, 2, 2342.00, 23.00),
(29, 15, 1, 34232.00, 324343.00),
(30, 15, 2, 323432.00, 324234.00),
(31, 16, 1, 34232.00, 324343.00),
(32, 16, 2, 323432.00, 324234.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('R8a4Yhs8BeZMDl1chM4boJVpaGmYUw9BvOYMeKkQ', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibUJhRkdmWmE2aEJGemk2aEhqWWZJWDFHbmtOSWpYcHB1aXF0SDNnNiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6Mjc6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9sb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1750479215),
('tOTovmC859CSz5USKwz7YZQ5iZA5okEE1QiScHLM', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRzJmeTJNak5GVTIzRnNHU3pQbmtrMDZ1UmRzekhqZ0xaTng5bDBTTiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NDA6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9nZW5lcmFkb3ItZmFjdHVyYXMiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1751081410);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `telefonos`
--

CREATE TABLE `telefonos` (
  `cod_telefono` int NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `cod_persona` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `telefonos`
--

INSERT INTO `telefonos` (`cod_telefono`, `telefono`, `cod_persona`) VALUES
(6, '97497264', 6),
(7, '99998888', 7),
(8, '99887766', 10),
(9, '98765432', 14),
(10, '9871234', 15),
(11, '98761234', 16),
(12, '987234', 17),
(13, '88889999', 21),
(14, '987234', 26),
(20, '54634223', 32),
(21, '88689857', 33),
(22, '4354543', 34),
(23, '987234', 35),
(25, '8868574', 37),
(26, '67543234', 38),
(27, '6789999', 39),
(28, '98765432', 40),
(29, '232232', 41),
(30, '124132122', 43),
(33, '98765432', 46),
(34, '56756433', 47),
(35, '67676767', 49),
(36, '63643563', 50);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_horario`
--

CREATE TABLE `tipo_horario` (
  `cod_tipo_horario` int NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(23) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `tipo_horario`
--

INSERT INTO `tipo_horario` (`cod_tipo_horario`, `nombre`, `descripcion`) VALUES
(1, 'Día', NULL),
(2, 'Noche', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_usuario`
--

CREATE TABLE `tipo_usuario` (
  `cod_tipo_usuario` int NOT NULL,
  `nombre` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `tipo_usuario`
--

INSERT INTO `tipo_usuario` (`cod_tipo_usuario`, `nombre`) VALUES
(1, 'Interno'),
(2, 'Externo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `users`
--

CREATE TABLE `users` (
  `id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `cod_usuario` int NOT NULL,
  `nombre_usuario` varchar(50) NOT NULL,
  `contrasena` varchar(255) NOT NULL,
  `estado` tinyint(1) DEFAULT '1',
  `intentos` int DEFAULT '0',
  `cod_rol` int DEFAULT NULL,
  `cod_tipo_usuario` int NOT NULL DEFAULT '1',
  `primer_acceso` tinyint(1) DEFAULT '1',
  `ip_conexion` varchar(50) DEFAULT NULL,
  `ip_mac` varchar(50) DEFAULT NULL,
  `creado_por` varchar(50) DEFAULT NULL,
  `fecha_registro` datetime DEFAULT CURRENT_TIMESTAMP,
  `token_recuperacion` varchar(64) DEFAULT NULL,
  `expira_token` datetime DEFAULT NULL,
  `cod_empleado` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`cod_usuario`, `nombre_usuario`, `contrasena`, `estado`, `intentos`, `cod_rol`, `cod_tipo_usuario`, `primer_acceso`, `ip_conexion`, `ip_mac`, `creado_por`, `fecha_registro`, `token_recuperacion`, `expira_token`, `cod_empleado`) VALUES
(1, 'zunga.hch', '$2b$10$G.HlDamnc6VsYeYyLH.S.eIBvVuxAfe1YdEPVaNQUEfNGMeslV4pq', 1, 0, 1, 1, 0, '::1', NULL, NULL, '2025-06-06 23:38:29', NULL, NULL, 6),
(2, 'carlosr', '$2b$10$abcdefghijk1234567890ZXCvbnm', 0, 0, 2, 2, 1, NULL, NULL, NULL, '2025-06-07 08:07:33', NULL, NULL, 7),
(3, 'javiers', '$2b$10$/cqTzSocLHuITxi4Cg3hwuu8D03aGr6.KTCwE3pPnfD6YBLTtQcWq', 0, 0, 2, 1, 0, '::1', NULL, NULL, '2025-06-07 08:18:52', NULL, NULL, 8),
(4, 'kellyn.castillo121', '$2b$10$dGTb1qAG1t7SiUalGyKkaum3Creolx3.qdEQCYfrJfdqGRw2i8HjW', 1, 0, 1, 1, 1, NULL, NULL, NULL, '2025-06-08 12:11:25', NULL, NULL, 9),
(5, 'admin.lord801', '$2b$10$AmSNyP9pEiLax6sUNfeuYuKcguDwgPYjnzgwa78LxFvTzrHYm9fme', 1, 0, 1, 1, 1, NULL, NULL, NULL, '2025-06-08 12:14:41', NULL, NULL, 10),
(6, 'javiers', '$2b$10$epNqTgUnbWtHGsqjTr49LeZysAWr3eVjI2wkRUT3B3H.DL7BGxoqm', 1, 0, 1, 1, 1, NULL, NULL, NULL, '2025-06-08 12:26:11', NULL, NULL, 11),
(7, 'kellyn.castillo333', '$2b$10$HwaV2kDHQe6DlFP8gDZLEehC5iKtLL0Rlg84ldHN136MNoXBu9iFa', 1, 0, 1, 1, 0, '::1', NULL, NULL, '2025-06-08 13:56:06', NULL, NULL, 12),
(8, 'javiers', '$2b$10$0BIrzFKUDcmpaC5u7onkGul4Z3FgsQCS/JI16/N9O8TDqDlvO7Dmu', 1, 0, 1, 1, 1, NULL, NULL, NULL, '2025-06-14 18:45:43', NULL, NULL, 13),
(9, 'ya.se.jodio876', '$2b$10$VawRySYI2MQGGZXmPH1/NeVgZO8jiF/GYlclsGrAudGuxdikaFz1a', 1, 0, 4, 1, 1, NULL, NULL, NULL, '2025-06-14 18:57:06', NULL, NULL, 14),
(10, 'funxiona.siono151', '$2b$10$fA0TPMxG5DVvEpJm1Vip2.0AmNNpW1jixhNE2W1DdtZNT2/gT4cQ6', 0, 0, 1, 1, 1, NULL, NULL, NULL, '2025-06-14 19:21:16', NULL, NULL, 15),
(11, 'ultima.prueba236', '$2b$10$1NtXXe3V3adBeq7Xo2aTX.SY33OwDc1ZrOE8qKx78c/vSyIBrUy.K', 1, 0, 1, 1, 1, NULL, NULL, NULL, '2025-06-14 19:40:51', NULL, NULL, 16),
(12, 'luis', '$2y$10$rlO5NzhpR1R7Q7P4aUZQIOuuwRWd6fM9b25Obek.K7ONPAK42XeyW', 1, 0, 1, 1, 0, '::1', NULL, 'sistema', '2025-06-20 21:18:27', NULL, NULL, 17);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `verificacion_2fa`
--

CREATE TABLE `verificacion_2fa` (
  `cod_usuario` int NOT NULL,
  `codigo` varchar(6) DEFAULT NULL,
  `expira` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `verificacion_2fa`
--

INSERT INTO `verificacion_2fa` (`cod_usuario`, `codigo`, `expira`) VALUES
(1, '245564', '2025-06-15 01:02:04'),
(3, '165400', '2025-06-07 08:58:58'),
(7, '500816', '2025-06-10 10:30:57');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `adicionales`
--
ALTER TABLE `adicionales`
  ADD PRIMARY KEY (`cod_adicional`);

--
-- Indices de la tabla `bitacora`
--
ALTER TABLE `bitacora`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`);

--
-- Indices de la tabla `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`);

--
-- Indices de la tabla `cai`
--
ALTER TABLE `cai`
  ADD PRIMARY KEY (`cod_cai`);

--
-- Indices de la tabla `clientes`
--
ALTER TABLE `clientes`
  ADD PRIMARY KEY (`cod_cliente`),
  ADD KEY `cod_persona` (`cod_persona`);

--
-- Indices de la tabla `correos`
--
ALTER TABLE `correos`
  ADD PRIMARY KEY (`cod_correo`),
  ADD KEY `cod_persona` (`cod_persona`);

--
-- Indices de la tabla `cotizacion`
--
ALTER TABLE `cotizacion`
  ADD PRIMARY KEY (`cod_cotizacion`),
  ADD KEY `cod_cliente` (`cod_cliente`);

--
-- Indices de la tabla `departamentos`
--
ALTER TABLE `departamentos`
  ADD PRIMARY KEY (`cod_departamento`);

--
-- Indices de la tabla `departamento_empresa`
--
ALTER TABLE `departamento_empresa`
  ADD PRIMARY KEY (`cod_departamento_empresa`);

--
-- Indices de la tabla `detalle_cotizacion`
--
ALTER TABLE `detalle_cotizacion`
  ADD PRIMARY KEY (`cod_detallecotizacion`),
  ADD KEY `cod_cotizacion` (`cod_cotizacion`);

--
-- Indices de la tabla `detalle_factura`
--
ALTER TABLE `detalle_factura`
  ADD PRIMARY KEY (`cod_detalle_factura`),
  ADD KEY `cod_factura` (`cod_factura`);

--
-- Indices de la tabla `direcciones`
--
ALTER TABLE `direcciones`
  ADD PRIMARY KEY (`cod_direccion`),
  ADD KEY `cod_persona` (`cod_persona`),
  ADD KEY `cod_municipio` (`cod_municipio`);

--
-- Indices de la tabla `empleados`
--
ALTER TABLE `empleados`
  ADD PRIMARY KEY (`cod_empleado`),
  ADD KEY `cod_persona` (`cod_persona`),
  ADD KEY `cod_departamento_empresa` (`cod_departamento_empresa`);

--
-- Indices de la tabla `entradas`
--
ALTER TABLE `entradas`
  ADD PRIMARY KEY (`cod_entrada`);

--
-- Indices de la tabla `evento`
--
ALTER TABLE `evento`
  ADD PRIMARY KEY (`cod_evento`),
  ADD KEY `cod_cotizacion` (`cod_cotizacion`);

--
-- Indices de la tabla `facturas`
--
ALTER TABLE `facturas`
  ADD PRIMARY KEY (`cod_factura`),
  ADD UNIQUE KEY `numero_factura` (`numero_factura`),
  ADD KEY `cod_cliente` (`cod_cliente`),
  ADD KEY `cod_cai` (`cod_cai`);

--
-- Indices de la tabla `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indices de la tabla `inventario`
--
ALTER TABLE `inventario`
  ADD PRIMARY KEY (`cod_inventario`);

--
-- Indices de la tabla `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indices de la tabla `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `municipios`
--
ALTER TABLE `municipios`
  ADD PRIMARY KEY (`cod_municipio`),
  ADD KEY `cod_departamento` (`cod_departamento`);

--
-- Indices de la tabla `objetos`
--
ALTER TABLE `objetos`
  ADD PRIMARY KEY (`cod_objeto`);

--
-- Indices de la tabla `paquetes`
--
ALTER TABLE `paquetes`
  ADD PRIMARY KEY (`cod_paquete`);

--
-- Indices de la tabla `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indices de la tabla `permisos`
--
ALTER TABLE `permisos`
  ADD PRIMARY KEY (`cod_permiso`),
  ADD KEY `cod_rol` (`cod_rol`),
  ADD KEY `cod_objeto` (`cod_objeto`);

--
-- Indices de la tabla `personas`
--
ALTER TABLE `personas`
  ADD PRIMARY KEY (`cod_persona`),
  ADD UNIQUE KEY `dni` (`dni`);

--
-- Indices de la tabla `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`cod_rol`);

--
-- Indices de la tabla `salones`
--
ALTER TABLE `salones`
  ADD PRIMARY KEY (`cod_salon`);

--
-- Indices de la tabla `salon_horario`
--
ALTER TABLE `salon_horario`
  ADD PRIMARY KEY (`cod_salon_horario`),
  ADD KEY `cod_salon` (`cod_salon`),
  ADD KEY `fk_tipo_horario` (`cod_tipo_horario`);

--
-- Indices de la tabla `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indices de la tabla `telefonos`
--
ALTER TABLE `telefonos`
  ADD PRIMARY KEY (`cod_telefono`),
  ADD KEY `cod_persona` (`cod_persona`);

--
-- Indices de la tabla `tipo_horario`
--
ALTER TABLE `tipo_horario`
  ADD PRIMARY KEY (`cod_tipo_horario`);

--
-- Indices de la tabla `tipo_usuario`
--
ALTER TABLE `tipo_usuario`
  ADD PRIMARY KEY (`cod_tipo_usuario`);

--
-- Indices de la tabla `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`cod_usuario`),
  ADD UNIQUE KEY `cod_empleado` (`cod_empleado`),
  ADD KEY `cod_rol` (`cod_rol`),
  ADD KEY `cod_tipo_usuario` (`cod_tipo_usuario`);

--
-- Indices de la tabla `verificacion_2fa`
--
ALTER TABLE `verificacion_2fa`
  ADD PRIMARY KEY (`cod_usuario`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `adicionales`
--
ALTER TABLE `adicionales`
  MODIFY `cod_adicional` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `bitacora`
--
ALTER TABLE `bitacora`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `cai`
--
ALTER TABLE `cai`
  MODIFY `cod_cai` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `clientes`
--
ALTER TABLE `clientes`
  MODIFY `cod_cliente` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT de la tabla `correos`
--
ALTER TABLE `correos`
  MODIFY `cod_correo` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT de la tabla `cotizacion`
--
ALTER TABLE `cotizacion`
  MODIFY `cod_cotizacion` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de la tabla `departamentos`
--
ALTER TABLE `departamentos`
  MODIFY `cod_departamento` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT de la tabla `departamento_empresa`
--
ALTER TABLE `departamento_empresa`
  MODIFY `cod_departamento_empresa` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `detalle_cotizacion`
--
ALTER TABLE `detalle_cotizacion`
  MODIFY `cod_detallecotizacion` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=46;

--
-- AUTO_INCREMENT de la tabla `detalle_factura`
--
ALTER TABLE `detalle_factura`
  MODIFY `cod_detalle_factura` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `direcciones`
--
ALTER TABLE `direcciones`
  MODIFY `cod_direccion` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT de la tabla `empleados`
--
ALTER TABLE `empleados`
  MODIFY `cod_empleado` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de la tabla `entradas`
--
ALTER TABLE `entradas`
  MODIFY `cod_entrada` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `evento`
--
ALTER TABLE `evento`
  MODIFY `cod_evento` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de la tabla `facturas`
--
ALTER TABLE `facturas`
  MODIFY `cod_factura` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `inventario`
--
ALTER TABLE `inventario`
  MODIFY `cod_inventario` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `municipios`
--
ALTER TABLE `municipios`
  MODIFY `cod_municipio` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=299;

--
-- AUTO_INCREMENT de la tabla `objetos`
--
ALTER TABLE `objetos`
  MODIFY `cod_objeto` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT de la tabla `paquetes`
--
ALTER TABLE `paquetes`
  MODIFY `cod_paquete` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `permisos`
--
ALTER TABLE `permisos`
  MODIFY `cod_permiso` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT de la tabla `personas`
--
ALTER TABLE `personas`
  MODIFY `cod_persona` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=53;

--
-- AUTO_INCREMENT de la tabla `roles`
--
ALTER TABLE `roles`
  MODIFY `cod_rol` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `salones`
--
ALTER TABLE `salones`
  MODIFY `cod_salon` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT de la tabla `salon_horario`
--
ALTER TABLE `salon_horario`
  MODIFY `cod_salon_horario` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT de la tabla `telefonos`
--
ALTER TABLE `telefonos`
  MODIFY `cod_telefono` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT de la tabla `tipo_horario`
--
ALTER TABLE `tipo_horario`
  MODIFY `cod_tipo_horario` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `tipo_usuario`
--
ALTER TABLE `tipo_usuario`
  MODIFY `cod_tipo_usuario` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `cod_usuario` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `clientes`
--
ALTER TABLE `clientes`
  ADD CONSTRAINT `clientes_ibfk_1` FOREIGN KEY (`cod_persona`) REFERENCES `personas` (`cod_persona`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `correos`
--
ALTER TABLE `correos`
  ADD CONSTRAINT `correos_ibfk_1` FOREIGN KEY (`cod_persona`) REFERENCES `personas` (`cod_persona`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `cotizacion`
--
ALTER TABLE `cotizacion`
  ADD CONSTRAINT `cotizacion_ibfk_1` FOREIGN KEY (`cod_cliente`) REFERENCES `clientes` (`cod_cliente`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `detalle_cotizacion`
--
ALTER TABLE `detalle_cotizacion`
  ADD CONSTRAINT `detalle_cotizacion_ibfk_1` FOREIGN KEY (`cod_cotizacion`) REFERENCES `cotizacion` (`cod_cotizacion`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `detalle_factura`
--
ALTER TABLE `detalle_factura`
  ADD CONSTRAINT `detalle_factura_ibfk_1` FOREIGN KEY (`cod_factura`) REFERENCES `facturas` (`cod_factura`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `direcciones`
--
ALTER TABLE `direcciones`
  ADD CONSTRAINT `direcciones_ibfk_1` FOREIGN KEY (`cod_persona`) REFERENCES `personas` (`cod_persona`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `direcciones_ibfk_2` FOREIGN KEY (`cod_municipio`) REFERENCES `municipios` (`cod_municipio`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `empleados`
--
ALTER TABLE `empleados`
  ADD CONSTRAINT `empleados_ibfk_1` FOREIGN KEY (`cod_persona`) REFERENCES `personas` (`cod_persona`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `empleados_ibfk_2` FOREIGN KEY (`cod_departamento_empresa`) REFERENCES `departamento_empresa` (`cod_departamento_empresa`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `evento`
--
ALTER TABLE `evento`
  ADD CONSTRAINT `evento_ibfk_1` FOREIGN KEY (`cod_cotizacion`) REFERENCES `cotizacion` (`cod_cotizacion`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `facturas`
--
ALTER TABLE `facturas`
  ADD CONSTRAINT `facturas_ibfk_1` FOREIGN KEY (`cod_cliente`) REFERENCES `clientes` (`cod_cliente`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `facturas_ibfk_2` FOREIGN KEY (`cod_cai`) REFERENCES `cai` (`cod_cai`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `municipios`
--
ALTER TABLE `municipios`
  ADD CONSTRAINT `municipios_ibfk_1` FOREIGN KEY (`cod_departamento`) REFERENCES `departamentos` (`cod_departamento`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `permisos`
--
ALTER TABLE `permisos`
  ADD CONSTRAINT `permisos_ibfk_1` FOREIGN KEY (`cod_rol`) REFERENCES `roles` (`cod_rol`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `permisos_ibfk_2` FOREIGN KEY (`cod_objeto`) REFERENCES `objetos` (`cod_objeto`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `salon_horario`
--
ALTER TABLE `salon_horario`
  ADD CONSTRAINT `fk_tipo_horario` FOREIGN KEY (`cod_tipo_horario`) REFERENCES `tipo_horario` (`cod_tipo_horario`) ON DELETE CASCADE,
  ADD CONSTRAINT `salon_horario_ibfk_1` FOREIGN KEY (`cod_salon`) REFERENCES `salones` (`cod_salon`) ON DELETE CASCADE;

--
-- Filtros para la tabla `telefonos`
--
ALTER TABLE `telefonos`
  ADD CONSTRAINT `telefonos_ibfk_1` FOREIGN KEY (`cod_persona`) REFERENCES `personas` (`cod_persona`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD CONSTRAINT `usuarios_ibfk_1` FOREIGN KEY (`cod_rol`) REFERENCES `roles` (`cod_rol`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `usuarios_ibfk_2` FOREIGN KEY (`cod_tipo_usuario`) REFERENCES `tipo_usuario` (`cod_tipo_usuario`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `usuarios_ibfk_3` FOREIGN KEY (`cod_empleado`) REFERENCES `empleados` (`cod_empleado`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `verificacion_2fa`
--
ALTER TABLE `verificacion_2fa`
  ADD CONSTRAINT `verificacion_2fa_ibfk_1` FOREIGN KEY (`cod_usuario`) REFERENCES `usuarios` (`cod_usuario`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
