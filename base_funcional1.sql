-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 15-06-2025 a las 19:41:39
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `base_funcional`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actualizar_persona` (IN `pv_accion` VARCHAR(20), IN `pv_dni` INT, IN `pv_nombre_persona` VARCHAR(255), IN `pv_fecha_nacimiento` DATE, IN `pv_sexo` ENUM('masculino','femenino'), IN `pv_correo` VARCHAR(100), IN `pv_telefono` VARCHAR(20), IN `pv_direccion` TEXT, IN `pv_cod_municipio` INT, IN `pv_rtn` VARCHAR(20), IN `pv_tipo_cliente` ENUM('natural','juridica'), IN `pv_cargo` VARCHAR(100), IN `pv_fecha_contratacion` DATE, IN `pv_usuario` VARCHAR(50), IN `pv_contrasena` VARCHAR(255), IN `pv_cod_rol` INT, IN `pv_cod_tipo_usuario` INT, IN `pv_salario` DECIMAL(10,2), IN `pv_cod_departamento_empresa` INT, IN `pv_estado` TINYINT)   BEGIN
    DECLARE v_cod_direccion INT;
    DECLARE v_cod_usuario INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error: Revisa los datos.' AS mensaje;
    END;

    START TRANSACTION;

    -- Obtener dirección
    SELECT cod_direccion INTO v_cod_direccion
    FROM Personas
    WHERE dni = pv_dni;

    -- Actualizar dirección
    UPDATE Direcciones
    SET direccion = pv_direccion,
        cod_municipio = pv_cod_municipio
    WHERE cod_direccion = v_cod_direccion;

    -- Actualizar persona
    UPDATE Personas
    SET nombre_persona = pv_nombre_persona,
        fecha_nacimiento = pv_fecha_nacimiento,
        sexo = pv_sexo
    WHERE dni = pv_dni;

    -- Actualizar contacto
    UPDATE Correos SET correo = pv_correo WHERE dni = pv_dni;
    UPDATE Telefonos SET telefono = pv_telefono WHERE dni = pv_dni;

    IF pv_accion = 'actualizar_empleado' THEN
        -- Obtener cod_usuario relacionado
        SELECT cod_usuario INTO v_cod_usuario
        FROM Empleados
        WHERE cod_empleado = pv_dni;

        -- Actualizar usuario
        UPDATE Usuarios
        SET nombre_usuario = pv_usuario,
            contrasena = IFNULL(pv_contrasena, contrasena),
            cod_rol = pv_cod_rol,
            cod_tipo_usuario = pv_cod_tipo_usuario,
            estado = pv_estado
        WHERE cod_usuario = v_cod_usuario;

        -- Actualizar empleado
        UPDATE Empleados
        SET cargo = pv_cargo,
            fecha_contratacion = pv_fecha_contratacion,
            salario = pv_salario,
            cod_departamento_empresa = pv_cod_departamento_empresa
        WHERE cod_empleado = pv_dni;

        SELECT 'Empleado actualizado correctamente' AS mensaje;

    ELSEIF pv_accion = 'actualizar_cliente' THEN
        -- Actualizar cliente
        UPDATE Clientes
        SET rtn = pv_rtn,
            tipo_cliente = pv_tipo_cliente
        WHERE cod_persona = pv_dni;

        SELECT 'Cliente actualizado correctamente' AS mensaje;

    ELSE
        SELECT 'Acción no válida' AS mensaje;
    END IF;

    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_eliminar_persona` (IN `pv_accion` VARCHAR(20), IN `pv_dni` INT)   BEGIN
    DECLARE v_cod_direccion INT;
    DECLARE v_cod_usuario INT;

    -- Manejador de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error: Revisa si la persona existe o si hay claves foráneas activas.' AS mensaje;
    END;

    START TRANSACTION;

    IF EXISTS (SELECT 1 FROM Personas WHERE dni = pv_dni) THEN

        SELECT cod_direccion INTO v_cod_direccion
        FROM Personas
        WHERE dni = pv_dni;

        IF pv_accion = 'eliminar_empleado' THEN
            SELECT cod_usuario INTO v_cod_usuario
            FROM Empleados
            WHERE cod_empleado = pv_dni;

            DELETE FROM Empleados WHERE cod_empleado = pv_dni;
            DELETE FROM Usuarios WHERE cod_usuario = v_cod_usuario;

        ELSEIF pv_accion = 'eliminar_cliente' THEN
            DELETE FROM Clientes WHERE cod_persona = pv_dni;

        ELSE
            
            SET @msg = 'Acción no válida intente de nuevo.';
            ROLLBACK;
            SELECT @msg AS mensaje;
        END IF;

        DELETE FROM Correos WHERE dni = pv_dni;
        DELETE FROM Telefonos WHERE dni = pv_dni;
        DELETE FROM Personas WHERE dni = pv_dni;
        DELETE FROM Direcciones WHERE cod_direccion = v_cod_direccion;

        COMMIT;
        SELECT 'Persona eliminada correctamente' AS mensaje;

    ELSE
        SELECT 'La persona con ese DNI no existe.' AS mensaje;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_generar_token_recuperacion` (IN `pv_correo` VARCHAR(100), IN `pv_token` VARCHAR(64), IN `pv_expira` DATETIME)   BEGIN
    DECLARE v_cod_usuario INT;
    DECLARE v_nombre_usuario VARCHAR(50);

    
    SELECT u.cod_usuario, u.nombre_usuario
    INTO v_cod_usuario, v_nombre_usuario
    FROM Correos c
    JOIN Personas p ON c.dni = p.dni
    JOIN Empleados e ON p.dni = e.cod_empleado
    JOIN Usuarios u ON e.cod_usuario = u.cod_usuario
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_gestion_factura` (IN `pv_accion` VARCHAR(20), IN `pv_cod_factura` INT, IN `pv_cod_evento` INT, IN `pv_cod_cliente` INT, IN `pv_cod_empleado` INT, IN `pv_cod_cai` INT, IN `pv_tipo_factura` ENUM('evento','taquilla','libro','recorrido_escolar'), IN `pv_numero_factura` VARCHAR(25), IN `pv_fecha_emision` DATE, IN `pv_subtotal` DECIMAL(10,2), IN `pv_importe_gravado_15` DECIMAL(10,2), IN `pv_impuesto_15` DECIMAL(10,2), IN `pv_importe_gravado_18` DECIMAL(10,2), IN `pv_impuesto_18` DECIMAL(10,2), IN `pv_importe_exento` DECIMAL(10,2), IN `pv_rebaja_otorgada` DECIMAL(10,2), IN `pv_descuento_otorgado` DECIMAL(10,2), IN `pv_total` DECIMAL(10,2), IN `pv_nota` TEXT)   BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT '¡ERROR en la ejecución! Revisa claves foráneas: evento, cliente, empleado o CAI.' AS mensaje;
    END;

    START TRANSACTION;

    IF pv_accion = 'insertar' THEN
        IF pv_tipo_factura = 'evento' THEN
            IF NOT EXISTS (SELECT 1 FROM eventos WHERE cod_evento = pv_cod_evento) THEN
                ROLLBACK;
                SELECT 'El cod_evento NO existe' AS mensaje;
            ELSEIF NOT EXISTS (SELECT 1 FROM clientes WHERE cod_cliente = pv_cod_cliente) THEN
                ROLLBACK;
                SELECT 'El cod_cliente NO existe' AS mensaje;
            ELSEIF NOT EXISTS (SELECT 1 FROM empleados WHERE cod_empleado = pv_cod_empleado) THEN
                ROLLBACK;
                SELECT 'El cod_empleado NO existe' AS mensaje;
            ELSEIF NOT EXISTS (SELECT 1 FROM cai WHERE cod_cai = pv_cod_cai) THEN
                ROLLBACK;
                SELECT 'El cod_cai NO existe' AS mensaje;
            ELSE
                INSERT INTO facturas (
                    cod_evento, cod_cliente, cod_empleado, cod_cai,
                    tipo_factura,
                    numero_factura, fecha_emision,
                    subtotal, importe_gravado_15, impuesto_15,
                    importe_gravado_18, impuesto_18, importe_exento,
                    rebaja_otorgada, descuento_otorgado, total, nota
                )
                VALUES (
                    pv_cod_evento, pv_cod_cliente, pv_cod_empleado, pv_cod_cai,
                    pv_tipo_factura,
                    pv_numero_factura, pv_fecha_emision,
                    pv_subtotal, pv_importe_gravado_15, pv_impuesto_15,
                    pv_importe_gravado_18, pv_impuesto_18, pv_importe_exento,
                    pv_rebaja_otorgada, pv_descuento_otorgado, pv_total, pv_nota
                );
                COMMIT;
                SELECT LAST_INSERT_ID() AS cod_factura, 'Factura de evento insertada correctamente' AS mensaje;
            END IF;

        ELSE -- Para 'taquilla', 'libro', 'recorrido_escolar'
            IF NOT EXISTS (SELECT 1 FROM clientes WHERE cod_cliente = pv_cod_cliente) THEN
                ROLLBACK;
                SELECT 'El cod_cliente NO existe' AS mensaje;
            ELSEIF NOT EXISTS (SELECT 1 FROM empleados WHERE cod_empleado = pv_cod_empleado) THEN
                ROLLBACK;
                SELECT 'El cod_empleado NO existe' AS mensaje;
            ELSEIF NOT EXISTS (SELECT 1 FROM cai WHERE cod_cai = pv_cod_cai) THEN
                ROLLBACK;
                SELECT 'El cod_cai NO existe' AS mensaje;
            ELSE
                INSERT INTO facturas (
                    cod_evento, cod_cliente, cod_empleado, cod_cai,
                    tipo_factura,
                    numero_factura, fecha_emision,
                    subtotal, importe_gravado_15, impuesto_15,
                    importe_gravado_18, impuesto_18, importe_exento,
                    rebaja_otorgada, descuento_otorgado, total, nota
                )
                VALUES (
                    NULL, pv_cod_cliente, pv_cod_empleado, pv_cod_cai,
                    pv_tipo_factura,
                    pv_numero_factura, pv_fecha_emision,
                    pv_subtotal, pv_importe_gravado_15, pv_impuesto_15,
                    pv_importe_gravado_18, pv_impuesto_18, pv_importe_exento,
                    pv_rebaja_otorgada, pv_descuento_otorgado, pv_total, pv_nota
                );
                COMMIT;
                SELECT LAST_INSERT_ID() AS cod_factura, CONCAT('Factura de ', pv_tipo_factura, ' insertada correctamente') AS mensaje;
            END IF;
        END IF;

    ELSEIF pv_accion = 'eliminar' THEN
        IF EXISTS (SELECT 1 FROM facturas WHERE cod_factura = pv_cod_factura) THEN
            DELETE FROM facturas WHERE cod_factura = pv_cod_factura;
            COMMIT;
            SELECT 'Factura eliminada correctamente' AS mensaje;
        ELSE
            ROLLBACK;
            SELECT 'La factura especificada no existe' AS mensaje;
        END IF;

    ELSEIF pv_accion = 'mostrar' THEN
        IF pv_cod_factura IS NULL THEN
            SELECT * FROM facturas;
        ELSE
            SELECT * FROM facturas WHERE cod_factura = pv_cod_factura;
        END IF;

    ELSE
        ROLLBACK;
        SELECT 'Acción no válida. Usa: insertar, eliminar o mostrar' AS mensaje;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_gestion_factura_productos` (IN `pv_accion` VARCHAR(20), IN `pv_cod_factura_producto` INT, IN `pv_cod_factura` INT, IN `pv_cod_producto` INT, IN `pv_cantidad` INT, IN `pv_precio_unitario` DECIMAL(10,2), IN `pv_total` DECIMAL(10,2))   BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT '❌ Error en factura_productos, verifica datos o claves foráneas' AS mensaje;
    END;

    START TRANSACTION;

    IF pv_accion = 'insertar' THEN
        INSERT INTO factura_productos (cod_factura, cod_producto, cantidad, precio_unitario, total)
        VALUES (pv_cod_factura, pv_cod_producto, pv_cantidad, pv_precio_unitario, pv_total);
        COMMIT;
        SELECT LAST_INSERT_ID() AS cod_factura_producto, '✅ Producto facturado correctamente' AS mensaje;
    ELSEIF pv_accion = 'eliminar' THEN
        DELETE FROM factura_productos WHERE cod_factura_producto = pv_cod_factura_producto;
        COMMIT;
        SELECT '🗑 Producto eliminado de factura' AS mensaje;
    ELSEIF pv_accion = 'mostrar' THEN
        IF pv_cod_factura IS NOT NULL THEN
            SELECT * FROM factura_productos WHERE cod_factura = pv_cod_factura;
        ELSE
            SELECT * FROM factura_productos;
        END IF;
    ELSE
        ROLLBACK;
        SELECT '⚠️ Acción no válida. Usa: insertar, eliminar o mostrar' AS mensaje;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_gestion_objetos` (IN `pv_accion` VARCHAR(20), IN `pv_cod_objeto` INT, IN `pv_tipo_objeto` VARCHAR(50), IN `pv_descripcion` TEXT)   BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error: Revisa los datos enviados o restricciones.' AS mensaje;
    END;

    START TRANSACTION;

    IF pv_accion = 'insertar' THEN
        INSERT INTO Objetos (tipo_objeto, descripcion)
        VALUES (pv_tipo_objeto, pv_descripcion);
        COMMIT;
        SELECT 'Objeto insertado correctamente' AS mensaje;

    ELSEIF pv_accion = 'actualizar' THEN
        UPDATE Objetos
        SET tipo_objeto = pv_tipo_objeto,
            descripcion = pv_descripcion
        WHERE cod_objeto = pv_cod_objeto;
        COMMIT;
        SELECT 'Objeto actualizado correctamente' AS mensaje;

    ELSEIF pv_accion = 'eliminar' THEN
        DELETE FROM Objetos
        WHERE cod_objeto = pv_cod_objeto;
        COMMIT;
        SELECT 'Objeto eliminado correctamente' AS mensaje;

    ELSEIF pv_accion = 'mostrar' THEN
        IF pv_cod_objeto IS NULL THEN
            SELECT * FROM Objetos;
        ELSE
            SELECT * FROM Objetos WHERE cod_objeto = pv_cod_objeto;
        END IF;

    ELSE
        ROLLBACK;
        SELECT 'Acción no válida intente de nuevo.' AS mensaje;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_gestion_permisos` (IN `pv_accion` VARCHAR(20), IN `pv_cod_permiso` INT, IN `pv_cod_rol` INT, IN `pv_cod_objeto` INT, IN `pv_nombre` VARCHAR(50), IN `pv_crear` BOOLEAN, IN `pv_modificar` BOOLEAN, IN `pv_mostrar` BOOLEAN, IN `pv_eliminar` BOOLEAN)   BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error: Revisa si el rol y objeto existen, o si hay conflictos.' AS mensaje;
    END;

    START TRANSACTION;

    IF pv_accion = 'insertar' THEN
        INSERT INTO Permisos (cod_rol, cod_objeto, nombre, crear, modificar, mostrar, eliminar)
        VALUES (pv_cod_rol, pv_cod_objeto, pv_nombre, pv_crear, pv_modificar, pv_mostrar, pv_eliminar);
        COMMIT;
        SELECT 'Permiso insertado correctamente' AS mensaje;

    ELSEIF pv_accion = 'actualizar' THEN
        UPDATE Permisos
        SET cod_rol = pv_cod_rol,
            cod_objeto = pv_cod_objeto,
            nombre = pv_nombre,
            crear = pv_crear,
            modificar = pv_modificar,
            mostrar = pv_mostrar,
            eliminar = pv_eliminar
        WHERE cod_permiso = pv_cod_permiso;
        COMMIT;
        SELECT 'Permiso actualizado correctamente' AS mensaje;

    ELSEIF pv_accion = 'eliminar' THEN
        DELETE FROM Permisos
        WHERE cod_permiso = pv_cod_permiso;
        COMMIT;
        SELECT 'Permiso eliminado correctamente' AS mensaje;

    ELSEIF pv_accion = 'mostrar' THEN
        IF pv_cod_permiso IS NULL THEN
            SELECT p.*, r.nombre AS nombre_rol, o.tipo_objeto, o.descripcion
            FROM Permisos p
            INNER JOIN Roles r ON p.cod_rol = r.cod_rol
            INNER JOIN Objetos o ON p.cod_objeto = o.cod_objeto;
        ELSE
            SELECT p.*, r.nombre AS nombre_rol, o.tipo_objeto, o.descripcion
            FROM Permisos p
            INNER JOIN Roles r ON p.cod_rol = r.cod_rol
            INNER JOIN Objetos o ON p.cod_objeto = o.cod_objeto
            WHERE p.cod_permiso = pv_cod_permiso;
        END IF;

    ELSE
        ROLLBACK;
        SELECT 'Acción no válida intente de nuevo.' AS mensaje;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_gestion_persona` (IN `pv_accion` VARCHAR(20), IN `pv_nombre_persona` VARCHAR(255), IN `pv_fecha_nacimiento` DATE, IN `pv_sexo` ENUM('masculino','femenino'), IN `pv_dni` INT, IN `pv_correo` VARCHAR(100), IN `pv_telefono` VARCHAR(20), IN `pv_direccion` TEXT, IN `pv_cod_municipio` INT, IN `pv_rtn` VARCHAR(20), IN `pv_tipo_cliente` ENUM('natural','juridica'), IN `pv_cargo` VARCHAR(100), IN `pv_fecha_contratacion` DATE, IN `pv_nombre_usuario` VARCHAR(50), IN `pv_contrasena` VARCHAR(255), IN `pv_cod_rol` INT, IN `pv_cod_tipo_usuario` INT, IN `pv_salario` DECIMAL(10,2), IN `pv_cod_departamento_empresa` INT, IN `pv_creado_por` VARCHAR(50))   BEGIN
    DECLARE v_cod_direccion INT;
    DECLARE v_cod_usuario INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error: Revisa los datos.' AS mensaje;
    END;

    START TRANSACTION;

    IF pv_accion = 'insertar_empleado' THEN
        -- Insertar dirección
        INSERT INTO Direcciones (direccion, cod_municipio)
        VALUES (pv_direccion, pv_cod_municipio);
        SET v_cod_direccion = LAST_INSERT_ID();

        -- Insertar persona
        INSERT INTO Personas (dni, nombre_persona, fecha_nacimiento, sexo, cod_direccion)
        VALUES (pv_dni, pv_nombre_persona, pv_fecha_nacimiento, pv_sexo, v_cod_direccion);

        -- Insertar correo y teléfono
        INSERT INTO Correos (correo, dni) VALUES (pv_correo, pv_dni);
        INSERT INTO Telefonos (telefono, dni) VALUES (pv_telefono, pv_dni);

        -- Insertar usuario con creado_por
        INSERT INTO Usuarios (
            nombre_usuario, contrasena, estado, intentos, cod_rol,
            cod_tipo_usuario, primer_acceso, fecha_registro, creado_por
        )
        VALUES (
            pv_nombre_usuario, pv_contrasena, 1, 0, pv_cod_rol,
            pv_cod_tipo_usuario, 1, CURRENT_TIMESTAMP, pv_creado_por
        );
        SET v_cod_usuario = LAST_INSERT_ID();

        -- Insertar empleado
        INSERT INTO Empleados (
            cod_empleado, cargo, fecha_contratacion, cod_usuario, salario, cod_departamento_empresa
        )
        VALUES (
            pv_dni, pv_cargo, pv_fecha_contratacion, v_cod_usuario, pv_salario, pv_cod_departamento_empresa
        );

        SELECT 'Empleado insertado correctamente' AS mensaje;

    ELSEIF pv_accion = 'insertar_cliente' THEN
        -- Insertar dirección
        INSERT INTO Direcciones (direccion, cod_municipio)
        VALUES (pv_direccion, pv_cod_municipio);
        SET v_cod_direccion = LAST_INSERT_ID();

        -- Insertar persona
        INSERT INTO Personas (dni, nombre_persona, fecha_nacimiento, sexo, cod_direccion)
        VALUES (pv_dni, pv_nombre_persona, pv_fecha_nacimiento, pv_sexo, v_cod_direccion);

        -- Insertar correo y teléfono
        INSERT INTO Correos (correo, dni) VALUES (pv_correo, pv_dni);
        INSERT INTO Telefonos (telefono, dni) VALUES (pv_telefono, pv_dni);

        -- Insertar cliente
        INSERT INTO Clientes (rtn, tipo_cliente, cod_persona)
        VALUES (pv_rtn, pv_tipo_cliente, pv_dni);

        SELECT 'Cliente insertado correctamente' AS mensaje;

    ELSE
        SELECT 'Acción no válida, intentalo de nuevo' AS mensaje;
    END IF;

    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_gestion_roles` (IN `pv_accion` VARCHAR(20), IN `pv_cod_rol` INT, IN `pv_nombre` VARCHAR(50))   BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error: Revisa los datos enviados o las claves foráneas.' AS mensaje;
    END;

    START TRANSACTION;

    IF pv_accion = 'insertar' THEN
        INSERT INTO Roles (nombre)
        VALUES (pv_nombre);
        COMMIT;
        SELECT 'Rol insertado correctamente' AS mensaje;

    ELSEIF pv_accion = 'actualizar' THEN
        UPDATE Roles
        SET nombre = pv_nombre
        WHERE cod_rol = pv_cod_rol;
        COMMIT;
        SELECT 'Rol actualizado correctamente' AS mensaje;

    ELSEIF pv_accion = 'eliminar' THEN
        DELETE FROM Roles
        WHERE cod_rol = pv_cod_rol;
        COMMIT;
        SELECT 'Rol eliminado correctamente' AS mensaje;

    ELSEIF pv_accion = 'mostrar' THEN
        IF pv_cod_rol IS NULL THEN
            SELECT * FROM Roles;
        ELSE
            SELECT * FROM Roles WHERE cod_rol = pv_cod_rol;
        END IF;

    ELSE
        ROLLBACK;
        SELECT 'Acción no válida intenta de nuevo.' AS mensaje;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_guardar_codigo_2fa` (IN `p_cod_usuario` INT, IN `p_codigo` VARCHAR(6), IN `p_expira` DATETIME)   BEGIN
    DELETE FROM verificacion_2fa WHERE cod_usuario = p_cod_usuario;

    INSERT INTO verificacion_2fa (cod_usuario, codigo, expira)
    VALUES (p_cod_usuario, p_codigo, p_expira);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_login_usuario` (IN `pv_accion` VARCHAR(30), IN `pv_usuario` VARCHAR(50), IN `pv_ip_conexion` VARCHAR(50))   BEGIN
    DECLARE v_exist INT;
    DECLARE v_intentos INT;

    -- Verificar si el usuario existe
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
                    c.correo  -- 🔥 Se agrega el correo desde tabla Correos
                FROM Usuarios u
                JOIN Roles r ON u.cod_rol = r.cod_rol
                JOIN Empleados e ON u.cod_usuario = e.cod_usuario
                JOIN Personas p ON e.cod_empleado = p.dni
                LEFT JOIN Correos c ON p.dni = c.dni
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_mostrar_cai_activos` ()   BEGIN
  SELECT * FROM cai WHERE activo = 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_mostrar_cliente` (IN `pv_cod_cliente` INT)   BEGIN
  IF pv_cod_cliente IS NULL THEN
    SELECT * FROM clientes;
  ELSE
    SELECT * FROM clientes WHERE cod_cliente = pv_cod_cliente;
  END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_mostrar_empleado` (IN `pv_cod_empleado` INT)   BEGIN
  IF pv_cod_empleado IS NULL THEN
    SELECT * FROM empleados;
  ELSE
    SELECT * FROM empleados WHERE cod_empleado = pv_cod_empleado;
  END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_mostrar_evento` (IN `pv_cod_evento` INT)   BEGIN
  IF pv_cod_evento IS NULL THEN
    SELECT * FROM eventos;
  ELSE
    SELECT * FROM eventos WHERE cod_evento = pv_cod_evento;
  END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_mostrar_persona` (IN `pv_accion` VARCHAR(20), IN `pv_dni` INT)   BEGIN
    IF pv_accion = 'mostrar_empleado' THEN
        IF pv_dni IS NOT NULL THEN
            -- Mostrar empleado específico
            SELECT 
                p.dni,
                p.nombre_persona,
                p.fecha_nacimiento,
                p.sexo,
                d.direccion AS direccion_detallada,
                m.municipio,
                dep.departamento,
                c.correo,
                t.telefono,
                e.cargo,
                e.fecha_contratacion,
                u.nombre_usuario,
                CASE 
                    WHEN u.estado = 1 THEN 'Activo'
                    WHEN u.estado = 0 THEN 'Inactivo'
                    ELSE 'Desconocido'
                END AS estado,
                r.nombre AS rol,
                tu.nombre AS tipo_usuario,
                e.salario,
                de.nombre AS departamento_empresa
            FROM Empleados e
            JOIN Personas p ON e.cod_empleado = p.dni
            JOIN Direcciones d ON p.cod_direccion = d.cod_direccion
            JOIN Municipios m ON d.cod_municipio = m.cod_municipio
            JOIN Departamentos dep ON m.cod_departamento = dep.cod_departamento
            JOIN Correos c ON c.dni = p.dni
            JOIN Telefonos t ON t.dni = p.dni
            JOIN Usuarios u ON e.cod_usuario = u.cod_usuario
            JOIN Roles r ON u.cod_rol = r.cod_rol
            JOIN Tipo_Usuario tu ON u.cod_tipo_usuario = tu.cod_tipo_usuario
            JOIN Departamentos_Empresa de ON e.cod_departamento_empresa = de.cod_departamento_empresa
            WHERE p.dni = pv_dni;
        ELSE
            -- Mostrar todos los empleados
            SELECT 
                p.dni,
                p.nombre_persona,
                p.fecha_nacimiento,
                p.sexo,
                d.direccion AS direccion_detallada,
                m.municipio,
                dep.departamento,
                c.correo,
                t.telefono,
                e.cargo,
                e.fecha_contratacion,
                u.nombre_usuario,
                CASE 
                    WHEN u.estado = 1 THEN 'Activo'
                    WHEN u.estado = 0 THEN 'Inactivo'
                    ELSE 'Desconocido'
                END AS estado,
                r.nombre AS rol,
                tu.nombre AS tipo_usuario,
                e.salario,
                de.nombre AS departamento_empresa
            FROM Empleados e
            JOIN Personas p ON e.cod_empleado = p.dni
            JOIN Direcciones d ON p.cod_direccion = d.cod_direccion
            JOIN Municipios m ON d.cod_municipio = m.cod_municipio
            JOIN Departamentos dep ON m.cod_departamento = dep.cod_departamento
            JOIN Correos c ON c.dni = p.dni
            JOIN Telefonos t ON t.dni = p.dni
            JOIN Usuarios u ON e.cod_usuario = u.cod_usuario
            JOIN Roles r ON u.cod_rol = r.cod_rol
            JOIN Tipo_Usuario tu ON u.cod_tipo_usuario = tu.cod_tipo_usuario
            JOIN Departamentos_Empresa de ON e.cod_departamento_empresa = de.cod_departamento_empresa;
        END IF;

    ELSEIF pv_accion = 'mostrar_cliente' THEN
        IF pv_dni IS NOT NULL THEN
            -- Mostrar cliente específico
            SELECT 
                p.dni,
                p.nombre_persona,
                p.fecha_nacimiento,
                p.sexo,
                d.direccion AS direccion_detallada,
                m.municipio,
                dep.departamento,
                c.correo,
                t.telefono,
                cl.rtn,
                cl.tipo_cliente
            FROM Clientes cl
            JOIN Personas p ON cl.cod_persona = p.dni
            JOIN Direcciones d ON p.cod_direccion = d.cod_direccion
            JOIN Municipios m ON d.cod_municipio = m.cod_municipio
            JOIN Departamentos dep ON m.cod_departamento = dep.cod_departamento
            JOIN Correos c ON c.dni = p.dni
            JOIN Telefonos t ON t.dni = p.dni
            WHERE p.dni = pv_dni;
        ELSE
            -- Mostrar todos los clientes
            SELECT 
                p.dni,
                p.nombre_persona,
                p.fecha_nacimiento,
                p.sexo,
                d.direccion AS direccion_detallada,
                m.municipio,
                dep.departamento,
                c.correo,
                t.telefono,
                cl.rtn,
                cl.tipo_cliente
            FROM Clientes cl
            JOIN Personas p ON cl.cod_persona = p.dni
            JOIN Direcciones d ON p.cod_direccion = d.cod_direccion
            JOIN Municipios m ON d.cod_municipio = m.cod_municipio
            JOIN Departamentos dep ON m.cod_departamento = dep.cod_departamento
            JOIN Correos c ON c.dni = p.dni
            JOIN Telefonos t ON t.dni = p.dni;
        END IF;

    ELSE
        SELECT 'Acción no válida. Usa mostrar_empleado o mostrar_cliente.' AS mensaje;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_permisos_usuario` (IN `pv_cod_rol` INT)   BEGIN
    SELECT 
        o.descripcion AS objeto,
        p.crear,
        p.modificar,
        p.mostrar,
        p.eliminar
    FROM Permisos p
    INNER JOIN Objetos o ON p.cod_objeto = o.cod_objeto
    WHERE p.cod_rol = pv_cod_rol;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_primer_acceso` (IN `pv_cod_usuario` INT, IN `pv_nueva_contrasena` VARCHAR(255))   BEGIN
    UPDATE Usuarios
    SET contrasena = pv_nueva_contrasena,
        primer_acceso = 0,
        intentos = 0
    WHERE cod_usuario = pv_cod_usuario;
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
-- Estructura de tabla para la tabla `bitacora`
--

CREATE TABLE `bitacora` (
  `cod_bitacora` int(11) NOT NULL,
  `cod_usuario` int(11) DEFAULT NULL,
  `accion` varchar(100) DEFAULT NULL,
  `objeto_afectado` varchar(100) DEFAULT NULL,
  `descripcion` text DEFAULT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `boletos_taquilla`
--

CREATE TABLE `boletos_taquilla` (
  `cod_boleto` int(11) NOT NULL,
  `tipo` enum('adulto','menor','discapacitado','escolar') NOT NULL,
  `descripcion` varchar(100) DEFAULT NULL,
  `precio` decimal(10,2) NOT NULL,
  `activo` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `boletos_taquilla`
--

INSERT INTO `boletos_taquilla` (`cod_boleto`, `tipo`, `descripcion`, `precio`, `activo`) VALUES
(1, 'menor', 'Boleto para menores de edad', 5.00, 1),
(2, 'adulto', 'Boleto para adultos', 10.00, 1),
(3, 'discapacitado', 'Boleto para personas con capacidad especial', 15.00, 1),
(4, 'escolar', 'Boleto para escolares', 8.00, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cai`
--

CREATE TABLE `cai` (
  `cod_cai` int(11) NOT NULL,
  `cai` varchar(100) NOT NULL,
  `rango_desde` varchar(25) NOT NULL,
  `rango_hasta` varchar(25) NOT NULL,
  `numero_actual` varchar(25) DEFAULT NULL,
  `fecha_limite` date NOT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `cai`
--

INSERT INTO `cai` (`cod_cai`, `cai`, `rango_desde`, `rango_hasta`, `numero_actual`, `fecha_limite`, `activo`, `creado_en`) VALUES
(2, 'ABCD-EFGH-IJKL', '1', '100', '1', '2025-12-31', 1, '2025-06-08 19:14:26');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clientes`
--

CREATE TABLE `clientes` (
  `cod_cliente` int(11) NOT NULL,
  `rtn` varchar(20) DEFAULT NULL,
  `tipo_cliente` enum('natural','juridica') DEFAULT NULL,
  `cod_persona` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `clientes`
--

INSERT INTO `clientes` (`cod_cliente`, `rtn`, `tipo_cliente`, `cod_persona`) VALUES
(9, '0801199912345', 'natural', 12345678);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `correlativos_factura`
--

CREATE TABLE `correlativos_factura` (
  `id` int(11) NOT NULL,
  `cod_cai` int(11) NOT NULL,
  `numero_actual` int(11) NOT NULL DEFAULT 1,
  `tipo_factura` varchar(30) DEFAULT NULL,
  `fecha_actualizado` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `correlativos_factura`
--

INSERT INTO `correlativos_factura` (`id`, `cod_cai`, `numero_actual`, `tipo_factura`, `fecha_actualizado`) VALUES
(2, 2, 1, NULL, '2025-06-15 11:07:33');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `correos`
--

CREATE TABLE `correos` (
  `cod_correo` int(11) NOT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `dni` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `correos`
--

INSERT INTO `correos` (`cod_correo`, `correo`, `dni`) VALUES
(1, 'kellyn.actualizada@correo.com', 87654321),
(2, 'josue.nuevo@correo.com', 11223344),
(5, 'myke_mg@correo.com', 12345678),
(7, 'jonathancevallos290zunga@gmail.com', 222409008),
(9, 'messisoy.10@correo.com', 87609021),
(10, 'miguelgarcia9647@gmail.com', 99998888),
(11, 'michitogarcia.mg@gmail.com', 2134123),
(12, 'celun4947@gmail.com', 97497264),
(13, 'jonathancevallos290@gmail.com', 8013500),
(14, 'nombretoto@gmail.com', 8012000);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cotizaciones`
--

CREATE TABLE `cotizaciones` (
  `cod_cotizacion` int(11) NOT NULL,
  `cod_evento` int(11) DEFAULT NULL,
  `cod_empleado` int(11) DEFAULT NULL,
  `fecha` date DEFAULT NULL,
  `fecha_limite` date DEFAULT NULL,
  `observaciones` text DEFAULT NULL,
  `estado` enum('pendiente','aprobada','rechazada') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `departamentos`
--

CREATE TABLE `departamentos` (
  `cod_departamento` int(11) NOT NULL,
  `departamento` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
-- Estructura de tabla para la tabla `departamentos_empresa`
--

CREATE TABLE `departamentos_empresa` (
  `cod_departamento_empresa` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `departamentos_empresa`
--

INSERT INTO `departamentos_empresa` (`cod_departamento_empresa`, `nombre`, `descripcion`) VALUES
(1, 'Direccion Gneral', 'es mero jefe');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_cotizacion`
--

CREATE TABLE `detalle_cotizacion` (
  `cod_detalle` int(11) NOT NULL,
  `cod_cotizacion` int(11) DEFAULT NULL,
  `cod_producto` int(11) DEFAULT NULL,
  `cantidad` int(11) DEFAULT NULL,
  `precio_unitario` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_reservacion`
--

CREATE TABLE `detalle_reservacion` (
  `cod_detalle` int(11) NOT NULL,
  `cod_reservacion` int(11) DEFAULT NULL,
  `cod_producto` int(11) DEFAULT NULL,
  `cantidad` int(11) DEFAULT NULL,
  `precio_unitario` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `direcciones`
--

CREATE TABLE `direcciones` (
  `cod_direccion` int(11) NOT NULL,
  `direccion` text DEFAULT NULL,
  `cod_municipio` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `direcciones`
--

INSERT INTO `direcciones` (`cod_direccion`, `direccion`, `cod_municipio`) VALUES
(1, 'Res. El Sauce, bloque B', 2),
(2, 'Col. El Prado, Calle 5', 1),
(5, 'Col. El Prado, Casa 15', 1),
(7, 'Col. El Prado, Casa 15', 1),
(9, 'Res. El Sauce, bloque B', 2),
(10, 'Res. El Flow, Calle 23, Casa 7', 1),
(11, 'zambrano', 1),
(12, 'En algun lugar', 1),
(13, 'El anillo', 1),
(14, 'Zambrano', 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empleados`
--

CREATE TABLE `empleados` (
  `cod_empleado` int(11) NOT NULL,
  `cargo` varchar(100) DEFAULT NULL,
  `fecha_contratacion` date DEFAULT NULL,
  `cod_usuario` int(11) DEFAULT NULL,
  `salario` decimal(10,2) DEFAULT NULL,
  `cod_departamento_empresa` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `empleados`
--

INSERT INTO `empleados` (`cod_empleado`, `cargo`, `fecha_contratacion`, `cod_usuario`, `salario`, `cod_departamento_empresa`) VALUES
(2134123, 'no mucho pesa', '2025-05-07', 7, 675342.00, 1),
(8012000, 'EL Mejor', '2024-10-23', 10, 89000.00, 1),
(8013500, 'Jefe de IT', '2025-02-04', 9, 34244.00, 1),
(12345678, 'Coordinador General', '2024-06-01', 3, 105000.00, 1),
(97497264, 'Coordinador General', '2025-02-12', 8, 12000.00, 1),
(99998888, 'Artista Internacional', '2024-06-01', 6, 50000.00, 1),
(222409008, 'Administrador General', '2024-06-01', 5, 100000.00, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `entradas`
--

CREATE TABLE `entradas` (
  `cod_entrada` int(11) NOT NULL,
  `cod_producto` int(11) DEFAULT NULL,
  `cod_cliente` int(11) DEFAULT NULL,
  `cantidad` int(11) DEFAULT NULL,
  `fecha_compra` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `eventos`
--

CREATE TABLE `eventos` (
  `cod_evento` int(11) NOT NULL,
  `nombre` varchar(100) DEFAULT NULL,
  `descripcion` text DEFAULT NULL,
  `fecha_evento` date DEFAULT NULL,
  `hora_inicio` time DEFAULT NULL,
  `hora_fin` time DEFAULT NULL,
  `cod_cliente` int(11) DEFAULT NULL,
  `observaciones` text DEFAULT NULL,
  `estado` enum('pendiente','cotizado','reservado','cancelado','finalizado') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `eventos`
--

INSERT INTO `eventos` (`cod_evento`, `nombre`, `descripcion`, `fecha_evento`, `hora_inicio`, `hora_fin`, `cod_cliente`, `observaciones`, `estado`) VALUES
(2, 'Visita Escolar', 'Grupo de estudiantes de secundaria', '2025-06-08', '09:00:00', '11:00:00', 9, 'Grupo confirmado por correo', '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `facturas`
--

CREATE TABLE `facturas` (
  `cod_factura` int(11) NOT NULL,
  `cod_evento` int(11) DEFAULT NULL,
  `cod_cliente` int(11) DEFAULT NULL,
  `cod_empleado` int(11) DEFAULT NULL,
  `cod_cai` int(11) DEFAULT NULL,
  `tipo_factura` enum('evento','taquilla','libro','recorrido_escolar') NOT NULL,
  `numero_factura` varchar(25) NOT NULL,
  `fecha_emision` date DEFAULT NULL,
  `subtotal` decimal(10,2) DEFAULT NULL,
  `importe_gravado_15` decimal(10,2) DEFAULT NULL,
  `impuesto_15` decimal(10,2) DEFAULT NULL,
  `importe_gravado_18` decimal(10,2) DEFAULT NULL,
  `impuesto_18` decimal(10,2) DEFAULT NULL,
  `importe_exento` decimal(10,2) DEFAULT NULL,
  `rebaja_otorgada` decimal(10,2) DEFAULT 0.00,
  `descuento_otorgado` decimal(10,2) DEFAULT 0.00,
  `total` decimal(10,2) DEFAULT NULL,
  `nota` text DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `facturas`
--

INSERT INTO `facturas` (`cod_factura`, `cod_evento`, `cod_cliente`, `cod_empleado`, `cod_cai`, `tipo_factura`, `numero_factura`, `fecha_emision`, `subtotal`, `importe_gravado_15`, `impuesto_15`, `importe_gravado_18`, `impuesto_18`, `importe_exento`, `rebaja_otorgada`, `descuento_otorgado`, `total`, `nota`, `creado_en`) VALUES
(18, NULL, 9, 12345678, 2, 'taquilla', '000-001-01-00000005', '2025-06-15', 100.00, 100.00, 15.00, 0.00, 0.00, 0.00, 0.00, 0.00, 115.00, 'Factura de taquilla', '2025-06-14 23:40:17'),
(19, 2, 9, 12345678, 2, 'evento', '000-001-01-00000004', '2025-06-14', 1200.00, 1000.00, 120.00, 0.00, 0.00, 80.00, 0.00, 0.00, 1200.00, 'Factura para evento escolar', '2025-06-14 23:42:16'),
(20, 2, 9, 12345678, 2, 'evento', '000-001-01-000000010', '2025-06-14', 1200.00, 1000.00, 120.00, 0.00, 0.00, 80.00, 0.00, 0.00, 1200.00, 'Factura para evento escolar', '2025-06-14 23:46:00'),
(21, 2, 9, 12345678, 2, 'evento', '000-001-01-00000004', '2025-06-14', 1500.00, 1200.00, 180.00, 0.00, 0.00, 120.00, 0.00, 0.00, 1500.00, 'Factura editada para evento escolar', '2025-06-15 05:55:13'),
(22, NULL, 9, 2134123, 2, 'recorrido_escolar', 'FAC-20250615-771', '2025-06-15', 15.00, 0.00, 0.00, 15.00, 2.70, 0.00, 0.00, 0.00, 17.70, '', '2025-06-15 16:35:37'),
(23, NULL, 9, 2134123, 2, 'taquilla', 'FAC-20250615-138', '2025-06-15', 10.00, 0.00, 0.00, 10.00, 1.80, 0.00, 0.00, 0.00, 11.80, '', '2025-06-15 16:36:09'),
(24, NULL, 9, 8012000, 2, 'recorrido_escolar', 'FAC-20250615-635', '2025-06-15', 20.00, 0.00, 0.00, 20.00, 3.60, 0.00, 0.00, 0.00, 23.60, '', '2025-06-15 16:36:52'),
(25, 2, 9, 2134123, 2, 'evento', 'FAC-20250615-188', '2025-06-15', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '', '2025-06-15 16:38:10'),
(26, NULL, 9, 2134123, 2, 'recorrido_escolar', 'FAC-20250615-551', '2025-06-15', 45.00, 0.00, 0.00, 45.00, 8.10, 0.00, 0.00, 0.00, 53.10, '', '2025-06-15 16:39:42');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `factura_boletos_taquilla`
--

CREATE TABLE `factura_boletos_taquilla` (
  `cod_factura_boleto` int(11) NOT NULL,
  `cod_factura` int(11) NOT NULL,
  `cod_boleto` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_unitario` decimal(10,2) NOT NULL,
  `total` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `factura_boletos_taquilla`
--

INSERT INTO `factura_boletos_taquilla` (`cod_factura_boleto`, `cod_factura`, `cod_boleto`, `cantidad`, `precio_unitario`, `total`) VALUES
(1, 22, 3, 1, 15.00, 15.00),
(2, 23, 2, 1, 10.00, 10.00),
(3, 24, 1, 3, 5.00, 15.00),
(4, 24, 1, 1, 5.00, 5.00),
(5, 26, 1, 9, 5.00, 45.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `factura_productos`
--

CREATE TABLE `factura_productos` (
  `cod_factura_producto` int(11) NOT NULL,
  `cod_factura` int(11) NOT NULL,
  `cod_producto` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_unitario` decimal(10,2) NOT NULL,
  `total` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `factura_productos`
--

INSERT INTO `factura_productos` (`cod_factura_producto`, `cod_factura`, `cod_producto`, `cantidad`, `precio_unitario`, `total`) VALUES
(3, 20, 1, 10, 50.00, 500.00),
(4, 20, 2, 5, 100.00, 500.00),
(9, 21, 1, 8, 50.00, 400.00),
(10, 21, 2, 7, 100.00, 700.00),
(11, 25, 1, 3, 0.00, 0.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `inventario`
--

CREATE TABLE `inventario` (
  `cod_inventario` int(11) NOT NULL,
  `cod_producto` int(11) DEFAULT NULL,
  `cantidad` int(11) DEFAULT NULL,
  `ubicacion` varchar(100) DEFAULT NULL,
  `estado` enum('activo','inactivo') DEFAULT 'activo'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `municipios`
--

CREATE TABLE `municipios` (
  `cod_municipio` int(11) NOT NULL,
  `municipio` varchar(100) DEFAULT NULL,
  `cod_departamento` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
  `cod_objeto` int(11) NOT NULL,
  `tipo_objeto` varchar(50) DEFAULT NULL,
  `descripcion` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
(10, 'Pantalla', 'Bitácora del sistema');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `permisos`
--

CREATE TABLE `permisos` (
  `cod_permiso` int(11) NOT NULL,
  `cod_rol` int(11) DEFAULT NULL,
  `cod_objeto` int(11) DEFAULT NULL,
  `nombre` varchar(50) DEFAULT NULL,
  `crear` tinyint(1) DEFAULT 0,
  `modificar` tinyint(1) DEFAULT 0,
  `mostrar` tinyint(1) DEFAULT 0,
  `eliminar` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
(8, 1, 8, 'Acceso total a Panel de administración', 1, 1, 1, 1),
(9, 1, 9, 'Acceso total a Gestión de CAI', 1, 1, 1, 1),
(10, 1, 10, 'Acceso total a Bitácora del sistema', 1, 1, 1, 1),
(16, 2, 6, 'Facturación de eventos', 1, 0, 1, 0),
(17, 3, 2, 'Gestión de productos', 0, 1, 1, 0),
(18, 4, 3, 'Gestión de salones', 1, 1, 1, 1),
(19, 4, 4, 'Gestión de cotizaciones', 1, 1, 1, 1),
(20, 4, 5, 'Gestión de reservaciones', 1, 1, 1, 1),
(21, 5, 7, 'Facturación entradas generales', 1, 0, 1, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `personas`
--

CREATE TABLE `personas` (
  `dni` int(11) NOT NULL,
  `nombre_persona` varchar(255) DEFAULT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `sexo` enum('masculino','femenino') DEFAULT NULL,
  `cod_direccion` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `personas`
--

INSERT INTO `personas` (`dni`, `nombre_persona`, `fecha_nacimiento`, `sexo`, `cod_direccion`) VALUES
(2134123, 'zungas pawer', '2025-05-15', 'masculino', 11),
(8012000, 'Miguel Garcia', '2004-02-29', 'masculino', 14),
(8013500, 'West Col', '2004-06-08', 'masculino', 13),
(11223344, 'Josué García', '1993-07-15', 'masculino', 2),
(12345678, 'Myke Garcia', '1993-07-15', 'masculino', 5),
(12345679, 'Pedro Martínez', '2000-01-01', 'masculino', NULL),
(87609021, 'Messi Leonel', '1992-11-15', 'femenino', 9),
(87654321, 'Kellyn Castillo', '1992-11-15', 'femenino', 1),
(97497264, 'probando email', '1996-02-28', 'masculino', 12),
(99998888, 'Myke Towers', '1994-01-15', 'masculino', 10),
(222409008, 'Cristiano Ronaldo', '1993-07-15', 'masculino', 7);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `precios_productos`
--

CREATE TABLE `precios_productos` (
  `cod_precio` int(11) NOT NULL,
  `cod_producto` int(11) DEFAULT NULL,
  `cod_tipo_horario` int(11) DEFAULT NULL,
  `precio` decimal(10,2) DEFAULT NULL,
  `fecha_inicio` date DEFAULT NULL,
  `fecha_fin` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `precios_productos`
--

INSERT INTO `precios_productos` (`cod_precio`, `cod_producto`, `cod_tipo_horario`, `precio`, `fecha_inicio`, `fecha_fin`) VALUES
(1, 1, NULL, 25.00, NULL, NULL),
(2, 2, NULL, 35.00, NULL, NULL),
(3, 3, NULL, 120.00, NULL, NULL),
(4, 4, NULL, 200.00, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `preguntas_seguridad`
--

CREATE TABLE `preguntas_seguridad` (
  `cod_pregunta` int(11) NOT NULL,
  `pregunta` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

CREATE TABLE `productos` (
  `cod_producto` int(11) NOT NULL,
  `nombre` varchar(100) DEFAULT NULL,
  `descripcion` text DEFAULT NULL,
  `tipo` enum('mobiliario','equipo') DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `productos`
--

INSERT INTO `productos` (`cod_producto`, `nombre`, `descripcion`, `tipo`, `activo`) VALUES
(1, 'Silla plástica', 'Silla para eventos', 'mobiliario', 1),
(2, 'Mesa redonda', 'Mesa para eventos', 'mobiliario', 1),
(3, 'Entrada general', 'Entrada para taquilla', 'equipo', 1),
(4, 'Libro educativo', 'Libro de recorrido escolar', 'equipo', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `reservaciones`
--

CREATE TABLE `reservaciones` (
  `cod_reservacion` int(11) NOT NULL,
  `cod_evento` int(11) DEFAULT NULL,
  `cod_cotizacion` int(11) DEFAULT NULL,
  `cod_empleado` int(11) DEFAULT NULL,
  `observaciones` text DEFAULT NULL,
  `estado` enum('activa','cancelada','finalizada') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `roles`
--

CREATE TABLE `roles` (
  `cod_rol` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `roles`
--

INSERT INTO `roles` (`cod_rol`, `nombre`) VALUES
(1, 'Dirección'),
(2, 'FacEL'),
(3, 'Escolar'),
(4, 'Evento'),
(5, 'Factaquilla');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `telefonos`
--

CREATE TABLE `telefonos` (
  `cod_telefono` int(11) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `dni` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `telefonos`
--

INSERT INTO `telefonos` (`cod_telefono`, `telefono`, `dni`) VALUES
(1, '88556677', 87654321),
(2, '99991122', 11223344),
(5, '99887711', 12345678),
(7, '99227711', 222409008),
(9, '83677', 87609021),
(10, '98765432', 99998888),
(11, '54634223', 2134123),
(12, '88689857', 97497264),
(13, '88765432', 8013500),
(14, '97497264', 8012000);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipos_horario`
--

CREATE TABLE `tipos_horario` (
  `cod_tipo_horario` int(11) NOT NULL,
  `nombre` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_usuario`
--

CREATE TABLE `tipo_usuario` (
  `cod_tipo_usuario` int(11) NOT NULL,
  `nombre` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tipo_usuario`
--

INSERT INTO `tipo_usuario` (`cod_tipo_usuario`, `nombre`) VALUES
(1, 'Interno'),
(2, 'Externo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `cod_usuario` int(11) NOT NULL,
  `nombre_usuario` varchar(50) NOT NULL,
  `contrasena` varchar(255) NOT NULL,
  `estado` tinyint(1) DEFAULT 1,
  `intentos` int(11) DEFAULT 0,
  `cod_rol` int(11) DEFAULT NULL,
  `cod_tipo_usuario` int(11) NOT NULL DEFAULT 1,
  `primer_acceso` tinyint(1) DEFAULT 1,
  `ip_conexion` varchar(50) DEFAULT NULL,
  `ip_mac` varchar(50) DEFAULT NULL,
  `creado_por` varchar(50) DEFAULT NULL,
  `fecha_registro` datetime DEFAULT current_timestamp(),
  `token_recuperacion` varchar(64) DEFAULT NULL,
  `expira_token` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`cod_usuario`, `nombre_usuario`, `contrasena`, `estado`, `intentos`, `cod_rol`, `cod_tipo_usuario`, `primer_acceso`, `ip_conexion`, `ip_mac`, `creado_por`, `fecha_registro`, `token_recuperacion`, `expira_token`) VALUES
(3, 'myke.garcia', '', 1, 0, 1, 1, 1, NULL, NULL, NULL, '2025-05-23 16:14:30', NULL, NULL),
(5, 'cr7_bicho.siu', 'claveSegura123', 1, 1, 1, 1, 1, NULL, NULL, NULL, '2025-05-23 17:45:31', 'f800fc92140795953a5b4a6c393d66a1e88a9f300ddc847f306d35bedd0a62b4', '2025-05-31 17:41:59'),
(6, 'mtowers', '$2b$10$zt.4sO0DA6ICRwEv9BgjzuIi98DkLy6SMYWMbWtgbK.ZTwzUvcCqK', 1, 1, 1, 1, 0, '::1', NULL, NULL, '2025-05-23 18:00:13', '6ffe033e1e2faeef27491a453135e84ad6a850f28f1da03442561d5acc3778d4', '2025-06-01 22:20:00'),
(7, 'zunga.hch', '$2b$10$2cYiThlGXJbCpQFpcKUNnOPkrDIwOCALpfULk5r4E7TIz4qJqp60K', 1, 0, 1, 1, 0, '::1', NULL, NULL, '2025-05-24 20:57:37', 'cd7c32ecdf2f2244502d83b4310d979b77b427c6b84e7610a56042adff12df3e', '2025-06-01 22:45:03'),
(8, 'probando.email264', '$2b$10$owxnYipElN1H9JpDS7gUHunPtql1tsd3G5sGYoAchPOMqxhOemaay', 1, 0, 1, 1, 0, '::1', NULL, 'admin_desconocido', '2025-06-01 19:12:52', NULL, NULL),
(9, 'west.col500', '$2b$10$AgL0mw25eeEAQxpPxkIT/ue2LnfMd5HIO7lZvxBIMkCR5kwxwq3E6', 1, 0, 1, 1, 1, NULL, NULL, 'admin_desconocido', '2025-06-01 21:24:59', NULL, NULL),
(10, 'miguel.garcia000', '$2b$10$4kz1a.WRE6CvN4DFZcU76.D9lDcspf5ORHb39/c/mCu8nJdIbEQty', 1, 0, 1, 1, 0, '::1', NULL, 'admin_desconocido', '2025-06-01 21:33:34', NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios_preguntas`
--

CREATE TABLE `usuarios_preguntas` (
  `cod_usuario` int(11) NOT NULL,
  `cod_pregunta` int(11) NOT NULL,
  `respuesta_hash` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `verificacion_2fa`
--

CREATE TABLE `verificacion_2fa` (
  `cod_usuario` int(11) NOT NULL,
  `codigo` varchar(6) DEFAULT NULL,
  `expira` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `verificacion_2fa`
--

INSERT INTO `verificacion_2fa` (`cod_usuario`, `codigo`, `expira`) VALUES
(7, '976169', '2025-06-01 21:26:51'),
(8, '610871', '2025-06-01 21:17:13'),
(10, '595471', '2025-06-01 21:41:06');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `bitacora`
--
ALTER TABLE `bitacora`
  ADD PRIMARY KEY (`cod_bitacora`),
  ADD KEY `cod_usuario` (`cod_usuario`);

--
-- Indices de la tabla `boletos_taquilla`
--
ALTER TABLE `boletos_taquilla`
  ADD PRIMARY KEY (`cod_boleto`);

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
  ADD UNIQUE KEY `rtn` (`rtn`),
  ADD KEY `cod_persona` (`cod_persona`);

--
-- Indices de la tabla `correlativos_factura`
--
ALTER TABLE `correlativos_factura`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cod_cai` (`cod_cai`);

--
-- Indices de la tabla `correos`
--
ALTER TABLE `correos`
  ADD PRIMARY KEY (`cod_correo`),
  ADD KEY `dni` (`dni`);

--
-- Indices de la tabla `cotizaciones`
--
ALTER TABLE `cotizaciones`
  ADD PRIMARY KEY (`cod_cotizacion`),
  ADD KEY `cod_evento` (`cod_evento`),
  ADD KEY `cod_empleado` (`cod_empleado`);

--
-- Indices de la tabla `departamentos`
--
ALTER TABLE `departamentos`
  ADD PRIMARY KEY (`cod_departamento`);

--
-- Indices de la tabla `departamentos_empresa`
--
ALTER TABLE `departamentos_empresa`
  ADD PRIMARY KEY (`cod_departamento_empresa`);

--
-- Indices de la tabla `detalle_cotizacion`
--
ALTER TABLE `detalle_cotizacion`
  ADD PRIMARY KEY (`cod_detalle`),
  ADD KEY `cod_cotizacion` (`cod_cotizacion`),
  ADD KEY `cod_producto` (`cod_producto`);

--
-- Indices de la tabla `detalle_reservacion`
--
ALTER TABLE `detalle_reservacion`
  ADD PRIMARY KEY (`cod_detalle`),
  ADD KEY `cod_reservacion` (`cod_reservacion`),
  ADD KEY `cod_producto` (`cod_producto`);

--
-- Indices de la tabla `direcciones`
--
ALTER TABLE `direcciones`
  ADD PRIMARY KEY (`cod_direccion`),
  ADD KEY `cod_municipio` (`cod_municipio`);

--
-- Indices de la tabla `empleados`
--
ALTER TABLE `empleados`
  ADD PRIMARY KEY (`cod_empleado`),
  ADD UNIQUE KEY `cod_usuario` (`cod_usuario`),
  ADD KEY `cod_departamento_empresa` (`cod_departamento_empresa`);

--
-- Indices de la tabla `entradas`
--
ALTER TABLE `entradas`
  ADD PRIMARY KEY (`cod_entrada`),
  ADD KEY `cod_producto` (`cod_producto`),
  ADD KEY `cod_cliente` (`cod_cliente`);

--
-- Indices de la tabla `eventos`
--
ALTER TABLE `eventos`
  ADD PRIMARY KEY (`cod_evento`),
  ADD KEY `cod_cliente` (`cod_cliente`);

--
-- Indices de la tabla `facturas`
--
ALTER TABLE `facturas`
  ADD PRIMARY KEY (`cod_factura`),
  ADD KEY `cod_evento` (`cod_evento`),
  ADD KEY `cod_cliente` (`cod_cliente`),
  ADD KEY `cod_empleado` (`cod_empleado`),
  ADD KEY `cod_cai` (`cod_cai`);

--
-- Indices de la tabla `factura_boletos_taquilla`
--
ALTER TABLE `factura_boletos_taquilla`
  ADD PRIMARY KEY (`cod_factura_boleto`),
  ADD KEY `cod_factura` (`cod_factura`),
  ADD KEY `cod_boleto` (`cod_boleto`);

--
-- Indices de la tabla `factura_productos`
--
ALTER TABLE `factura_productos`
  ADD PRIMARY KEY (`cod_factura_producto`),
  ADD KEY `cod_factura` (`cod_factura`),
  ADD KEY `cod_producto` (`cod_producto`);

--
-- Indices de la tabla `inventario`
--
ALTER TABLE `inventario`
  ADD PRIMARY KEY (`cod_inventario`),
  ADD KEY `cod_producto` (`cod_producto`);

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
  ADD PRIMARY KEY (`dni`),
  ADD KEY `cod_direccion` (`cod_direccion`);

--
-- Indices de la tabla `precios_productos`
--
ALTER TABLE `precios_productos`
  ADD PRIMARY KEY (`cod_precio`),
  ADD KEY `cod_producto` (`cod_producto`),
  ADD KEY `cod_tipo_horario` (`cod_tipo_horario`);

--
-- Indices de la tabla `preguntas_seguridad`
--
ALTER TABLE `preguntas_seguridad`
  ADD PRIMARY KEY (`cod_pregunta`);

--
-- Indices de la tabla `productos`
--
ALTER TABLE `productos`
  ADD PRIMARY KEY (`cod_producto`);

--
-- Indices de la tabla `reservaciones`
--
ALTER TABLE `reservaciones`
  ADD PRIMARY KEY (`cod_reservacion`),
  ADD KEY `cod_evento` (`cod_evento`),
  ADD KEY `cod_cotizacion` (`cod_cotizacion`),
  ADD KEY `cod_empleado` (`cod_empleado`);

--
-- Indices de la tabla `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`cod_rol`);

--
-- Indices de la tabla `telefonos`
--
ALTER TABLE `telefonos`
  ADD PRIMARY KEY (`cod_telefono`),
  ADD KEY `dni` (`dni`);

--
-- Indices de la tabla `tipos_horario`
--
ALTER TABLE `tipos_horario`
  ADD PRIMARY KEY (`cod_tipo_horario`);

--
-- Indices de la tabla `tipo_usuario`
--
ALTER TABLE `tipo_usuario`
  ADD PRIMARY KEY (`cod_tipo_usuario`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`cod_usuario`),
  ADD UNIQUE KEY `nombre_usuario` (`nombre_usuario`),
  ADD KEY `cod_rol` (`cod_rol`),
  ADD KEY `cod_tipo_usuario` (`cod_tipo_usuario`);

--
-- Indices de la tabla `usuarios_preguntas`
--
ALTER TABLE `usuarios_preguntas`
  ADD PRIMARY KEY (`cod_usuario`,`cod_pregunta`),
  ADD KEY `cod_pregunta` (`cod_pregunta`);

--
-- Indices de la tabla `verificacion_2fa`
--
ALTER TABLE `verificacion_2fa`
  ADD PRIMARY KEY (`cod_usuario`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `bitacora`
--
ALTER TABLE `bitacora`
  MODIFY `cod_bitacora` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `boletos_taquilla`
--
ALTER TABLE `boletos_taquilla`
  MODIFY `cod_boleto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `cai`
--
ALTER TABLE `cai`
  MODIFY `cod_cai` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `clientes`
--
ALTER TABLE `clientes`
  MODIFY `cod_cliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `correlativos_factura`
--
ALTER TABLE `correlativos_factura`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `correos`
--
ALTER TABLE `correos`
  MODIFY `cod_correo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `cotizaciones`
--
ALTER TABLE `cotizaciones`
  MODIFY `cod_cotizacion` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `departamentos`
--
ALTER TABLE `departamentos`
  MODIFY `cod_departamento` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT de la tabla `departamentos_empresa`
--
ALTER TABLE `departamentos_empresa`
  MODIFY `cod_departamento_empresa` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `detalle_cotizacion`
--
ALTER TABLE `detalle_cotizacion`
  MODIFY `cod_detalle` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `detalle_reservacion`
--
ALTER TABLE `detalle_reservacion`
  MODIFY `cod_detalle` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `direcciones`
--
ALTER TABLE `direcciones`
  MODIFY `cod_direccion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `entradas`
--
ALTER TABLE `entradas`
  MODIFY `cod_entrada` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `eventos`
--
ALTER TABLE `eventos`
  MODIFY `cod_evento` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `facturas`
--
ALTER TABLE `facturas`
  MODIFY `cod_factura` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT de la tabla `factura_boletos_taquilla`
--
ALTER TABLE `factura_boletos_taquilla`
  MODIFY `cod_factura_boleto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `factura_productos`
--
ALTER TABLE `factura_productos`
  MODIFY `cod_factura_producto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `inventario`
--
ALTER TABLE `inventario`
  MODIFY `cod_inventario` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `municipios`
--
ALTER TABLE `municipios`
  MODIFY `cod_municipio` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=299;

--
-- AUTO_INCREMENT de la tabla `objetos`
--
ALTER TABLE `objetos`
  MODIFY `cod_objeto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `permisos`
--
ALTER TABLE `permisos`
  MODIFY `cod_permiso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT de la tabla `precios_productos`
--
ALTER TABLE `precios_productos`
  MODIFY `cod_precio` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `preguntas_seguridad`
--
ALTER TABLE `preguntas_seguridad`
  MODIFY `cod_pregunta` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `productos`
--
ALTER TABLE `productos`
  MODIFY `cod_producto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `reservaciones`
--
ALTER TABLE `reservaciones`
  MODIFY `cod_reservacion` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `roles`
--
ALTER TABLE `roles`
  MODIFY `cod_rol` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `telefonos`
--
ALTER TABLE `telefonos`
  MODIFY `cod_telefono` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `tipos_horario`
--
ALTER TABLE `tipos_horario`
  MODIFY `cod_tipo_horario` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tipo_usuario`
--
ALTER TABLE `tipo_usuario`
  MODIFY `cod_tipo_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `cod_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `bitacora`
--
ALTER TABLE `bitacora`
  ADD CONSTRAINT `bitacora_ibfk_1` FOREIGN KEY (`cod_usuario`) REFERENCES `usuarios` (`cod_usuario`);

--
-- Filtros para la tabla `clientes`
--
ALTER TABLE `clientes`
  ADD CONSTRAINT `clientes_ibfk_1` FOREIGN KEY (`cod_persona`) REFERENCES `personas` (`dni`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `correlativos_factura`
--
ALTER TABLE `correlativos_factura`
  ADD CONSTRAINT `correlativos_factura_ibfk_1` FOREIGN KEY (`cod_cai`) REFERENCES `cai` (`cod_cai`);

--
-- Filtros para la tabla `correos`
--
ALTER TABLE `correos`
  ADD CONSTRAINT `correos_ibfk_1` FOREIGN KEY (`dni`) REFERENCES `personas` (`dni`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `cotizaciones`
--
ALTER TABLE `cotizaciones`
  ADD CONSTRAINT `cotizaciones_ibfk_1` FOREIGN KEY (`cod_evento`) REFERENCES `eventos` (`cod_evento`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `cotizaciones_ibfk_2` FOREIGN KEY (`cod_empleado`) REFERENCES `empleados` (`cod_empleado`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Filtros para la tabla `detalle_cotizacion`
--
ALTER TABLE `detalle_cotizacion`
  ADD CONSTRAINT `detalle_cotizacion_ibfk_1` FOREIGN KEY (`cod_cotizacion`) REFERENCES `cotizaciones` (`cod_cotizacion`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `detalle_cotizacion_ibfk_2` FOREIGN KEY (`cod_producto`) REFERENCES `productos` (`cod_producto`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Filtros para la tabla `detalle_reservacion`
--
ALTER TABLE `detalle_reservacion`
  ADD CONSTRAINT `detalle_reservacion_ibfk_1` FOREIGN KEY (`cod_reservacion`) REFERENCES `reservaciones` (`cod_reservacion`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `detalle_reservacion_ibfk_2` FOREIGN KEY (`cod_producto`) REFERENCES `productos` (`cod_producto`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Filtros para la tabla `direcciones`
--
ALTER TABLE `direcciones`
  ADD CONSTRAINT `direcciones_ibfk_1` FOREIGN KEY (`cod_municipio`) REFERENCES `municipios` (`cod_municipio`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `empleados`
--
ALTER TABLE `empleados`
  ADD CONSTRAINT `empleados_ibfk_1` FOREIGN KEY (`cod_empleado`) REFERENCES `personas` (`dni`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `empleados_ibfk_2` FOREIGN KEY (`cod_usuario`) REFERENCES `usuarios` (`cod_usuario`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `empleados_ibfk_3` FOREIGN KEY (`cod_departamento_empresa`) REFERENCES `departamentos_empresa` (`cod_departamento_empresa`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Filtros para la tabla `entradas`
--
ALTER TABLE `entradas`
  ADD CONSTRAINT `entradas_ibfk_1` FOREIGN KEY (`cod_producto`) REFERENCES `productos` (`cod_producto`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `entradas_ibfk_2` FOREIGN KEY (`cod_cliente`) REFERENCES `clientes` (`cod_cliente`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Filtros para la tabla `eventos`
--
ALTER TABLE `eventos`
  ADD CONSTRAINT `eventos_ibfk_1` FOREIGN KEY (`cod_cliente`) REFERENCES `clientes` (`cod_cliente`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `facturas`
--
ALTER TABLE `facturas`
  ADD CONSTRAINT `facturas_ibfk_1` FOREIGN KEY (`cod_evento`) REFERENCES `eventos` (`cod_evento`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `facturas_ibfk_2` FOREIGN KEY (`cod_cliente`) REFERENCES `clientes` (`cod_cliente`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `facturas_ibfk_3` FOREIGN KEY (`cod_empleado`) REFERENCES `empleados` (`cod_empleado`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `facturas_ibfk_4` FOREIGN KEY (`cod_cai`) REFERENCES `cai` (`cod_cai`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Filtros para la tabla `factura_boletos_taquilla`
--
ALTER TABLE `factura_boletos_taquilla`
  ADD CONSTRAINT `factura_boletos_taquilla_ibfk_1` FOREIGN KEY (`cod_factura`) REFERENCES `facturas` (`cod_factura`) ON DELETE CASCADE,
  ADD CONSTRAINT `factura_boletos_taquilla_ibfk_2` FOREIGN KEY (`cod_boleto`) REFERENCES `boletos_taquilla` (`cod_boleto`);

--
-- Filtros para la tabla `factura_productos`
--
ALTER TABLE `factura_productos`
  ADD CONSTRAINT `factura_productos_ibfk_1` FOREIGN KEY (`cod_factura`) REFERENCES `facturas` (`cod_factura`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `factura_productos_ibfk_2` FOREIGN KEY (`cod_producto`) REFERENCES `productos` (`cod_producto`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `inventario`
--
ALTER TABLE `inventario`
  ADD CONSTRAINT `inventario_ibfk_1` FOREIGN KEY (`cod_producto`) REFERENCES `productos` (`cod_producto`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `municipios`
--
ALTER TABLE `municipios`
  ADD CONSTRAINT `municipios_ibfk_1` FOREIGN KEY (`cod_departamento`) REFERENCES `departamentos` (`cod_departamento`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `permisos`
--
ALTER TABLE `permisos`
  ADD CONSTRAINT `permisos_ibfk_1` FOREIGN KEY (`cod_rol`) REFERENCES `roles` (`cod_rol`),
  ADD CONSTRAINT `permisos_ibfk_2` FOREIGN KEY (`cod_objeto`) REFERENCES `objetos` (`cod_objeto`);

--
-- Filtros para la tabla `personas`
--
ALTER TABLE `personas`
  ADD CONSTRAINT `personas_ibfk_1` FOREIGN KEY (`cod_direccion`) REFERENCES `direcciones` (`cod_direccion`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `precios_productos`
--
ALTER TABLE `precios_productos`
  ADD CONSTRAINT `precios_productos_ibfk_1` FOREIGN KEY (`cod_producto`) REFERENCES `productos` (`cod_producto`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `precios_productos_ibfk_2` FOREIGN KEY (`cod_tipo_horario`) REFERENCES `tipos_horario` (`cod_tipo_horario`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Filtros para la tabla `reservaciones`
--
ALTER TABLE `reservaciones`
  ADD CONSTRAINT `reservaciones_ibfk_1` FOREIGN KEY (`cod_evento`) REFERENCES `eventos` (`cod_evento`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `reservaciones_ibfk_2` FOREIGN KEY (`cod_cotizacion`) REFERENCES `cotizaciones` (`cod_cotizacion`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `reservaciones_ibfk_3` FOREIGN KEY (`cod_empleado`) REFERENCES `empleados` (`cod_empleado`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Filtros para la tabla `telefonos`
--
ALTER TABLE `telefonos`
  ADD CONSTRAINT `telefonos_ibfk_1` FOREIGN KEY (`dni`) REFERENCES `personas` (`dni`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD CONSTRAINT `usuarios_ibfk_1` FOREIGN KEY (`cod_rol`) REFERENCES `roles` (`cod_rol`),
  ADD CONSTRAINT `usuarios_ibfk_2` FOREIGN KEY (`cod_tipo_usuario`) REFERENCES `tipo_usuario` (`cod_tipo_usuario`);

--
-- Filtros para la tabla `usuarios_preguntas`
--
ALTER TABLE `usuarios_preguntas`
  ADD CONSTRAINT `usuarios_preguntas_ibfk_1` FOREIGN KEY (`cod_usuario`) REFERENCES `usuarios` (`cod_usuario`),
  ADD CONSTRAINT `usuarios_preguntas_ibfk_2` FOREIGN KEY (`cod_pregunta`) REFERENCES `preguntas_seguridad` (`cod_pregunta`);

--
-- Filtros para la tabla `verificacion_2fa`
--
ALTER TABLE `verificacion_2fa`
  ADD CONSTRAINT `verificacion_2fa_ibfk_1` FOREIGN KEY (`cod_usuario`) REFERENCES `usuarios` (`cod_usuario`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
