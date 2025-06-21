-- MySQL dump 10.13  Distrib 8.0.42, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: factura_chiminike
-- ------------------------------------------------------
-- Server version	8.0.42

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `adicionales`
--

DROP TABLE IF EXISTS `adicionales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `adicionales` (
  `cod_adicional` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) DEFAULT NULL,
  `descripcion` text,
  `precio` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`cod_adicional`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `adicionales`
--

LOCK TABLES `adicionales` WRITE;
/*!40000 ALTER TABLE `adicionales` DISABLE KEYS */;
INSERT INTO `adicionales` VALUES (2,'Parque Vial','Acceso al parque vial por persona',80.00),(3,'Merienda actualizada','Nueva descripción',60.00),(4,'no se solo es prueba','myke la mera verdura del caldo',2234.00);
/*!40000 ALTER TABLE `adicionales` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bitacora`
--

DROP TABLE IF EXISTS `bitacora`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bitacora` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cod_usuario` int NOT NULL,
  `objeto` varchar(100) NOT NULL,
  `accion` varchar(20) NOT NULL,
  `descripcion` text,
  `fecha` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bitacora`
--

LOCK TABLES `bitacora` WRITE;
/*!40000 ALTER TABLE `bitacora` DISABLE KEYS */;
INSERT INTO `bitacora` VALUES (1,1,'Login','Acceso','Inicio de sesión exitoso desde IP ::1','2025-06-15 06:57:04');
/*!40000 ALTER TABLE `bitacora` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_locks`
--

LOCK TABLES `cache_locks` WRITE;
/*!40000 ALTER TABLE `cache_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cai`
--

DROP TABLE IF EXISTS `cai`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cai` (
  `cod_cai` int NOT NULL AUTO_INCREMENT,
  `cai` varchar(100) NOT NULL,
  `rango_desde` varchar(25) NOT NULL,
  `rango_hasta` varchar(25) NOT NULL,
  `fecha_limite` date NOT NULL,
  `estado` tinyint(1) DEFAULT '1',
  `creado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`cod_cai`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cai`
--

LOCK TABLES `cai` WRITE;
/*!40000 ALTER TABLE `cai` DISABLE KEYS */;
INSERT INTO `cai` VALUES (2,'CAI-TEST-123456','00000001','00005000','2025-12-16',0,'2025-06-13 03:20:31'),(3,'CAI-TEST-123456-Ulmate','00020001','00150000','2025-12-19',1,'2025-06-13 16:34:02');
/*!40000 ALTER TABLE `cai` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clientes`
--

DROP TABLE IF EXISTS `clientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clientes` (
  `cod_cliente` int NOT NULL AUTO_INCREMENT,
  `rtn` varchar(20) DEFAULT NULL,
  `tipo_cliente` enum('Individual','Empresa') DEFAULT NULL,
  `cod_persona` int DEFAULT NULL,
  PRIMARY KEY (`cod_cliente`),
  KEY `cod_persona` (`cod_persona`),
  CONSTRAINT `clientes_ibfk_1` FOREIGN KEY (`cod_persona`) REFERENCES `personas` (`cod_persona`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clientes`
--

LOCK TABLES `clientes` WRITE;
/*!40000 ALTER TABLE `clientes` DISABLE KEYS */;
INSERT INTO `clientes` VALUES (1,'08011990123456','Empresa',7),(2,'08199912345','Empresa',15),(3,'0801199912345','Individual',16),(4,'0801199345','Individual',17),(5,'0801199912345','Individual',21),(6,'777653425','Individual',26),(12,'3232332','Individual',32),(13,'345222211','Individual',33),(14,'65372333','Individual',34),(15,'77222425','Individual',35),(17,'342872211','Individual',37),(18,'457783632','Individual',43);
/*!40000 ALTER TABLE `clientes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `correos`
--

DROP TABLE IF EXISTS `correos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `correos` (
  `cod_correo` int NOT NULL AUTO_INCREMENT,
  `correo` varchar(255) DEFAULT NULL,
  `cod_persona` int DEFAULT NULL,
  PRIMARY KEY (`cod_correo`),
  KEY `cod_persona` (`cod_persona`),
  CONSTRAINT `correos_ibfk_1` FOREIGN KEY (`cod_persona`) REFERENCES `personas` (`cod_persona`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `correos`
--

LOCK TABLES `correos` WRITE;
/*!40000 ALTER TABLE `correos` DISABLE KEYS */;
INSERT INTO `correos` VALUES (6,'michitogarcia.mg@gmail.com',6),(7,'carlos.mendoza@gmail.com',7),(8,'carlos.rivera@gmail.com',10),(9,'guerraclanes65@gmail.com',14),(10,'juansdarez@gmail.com',15),(11,'juanperez@gmail.com',16),(12,'jua453rez@gmail.com',17),(13,'camila@example.com',21),(14,'ju222ez@gmail.com',26),(20,'myke_mg@correo.com',32),(21,'myke_mg@correo.com',33),(22,'myke_mg@correo.com',34),(23,'ju222e22z@gmail.com',35),(25,'hackerputos2@gmail.com',37),(26,'miguelbarahona718@gmail.com',38),(27,'hackerputos2@gmail.com',39),(28,'michitogarcia12@gmail.com',40),(29,'miguelbarahona718@gmail.com',41),(30,'miguelgarcia@gmail.com',43),(33,'narutoizumaki265@gmail.com',46),(34,'narutoizumaki265@gmail.com',47),(35,'momobellaco@gmail.com',49),(36,'momobellaco@gmail.com',50);
/*!40000 ALTER TABLE `correos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cotizacion`
--

DROP TABLE IF EXISTS `cotizacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cotizacion` (
  `cod_cotizacion` int NOT NULL AUTO_INCREMENT,
  `cod_cliente` int NOT NULL,
  `fecha` date NOT NULL DEFAULT (curdate()),
  `fecha_validez` date NOT NULL,
  `estado` enum('pendiente','confirmada','expirada','completada') DEFAULT 'pendiente',
  PRIMARY KEY (`cod_cotizacion`),
  KEY `cod_cliente` (`cod_cliente`),
  CONSTRAINT `cotizacion_ibfk_1` FOREIGN KEY (`cod_cliente`) REFERENCES `clientes` (`cod_cliente`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cotizacion`
--

LOCK TABLES `cotizacion` WRITE;
/*!40000 ALTER TABLE `cotizacion` DISABLE KEYS */;
INSERT INTO `cotizacion` VALUES (1,2,'2025-06-07','2025-06-12','pendiente'),(2,3,'2025-06-07','2025-06-12','pendiente'),(3,4,'2025-06-07','2025-06-12','pendiente'),(4,5,'2025-06-07','2025-06-12','pendiente'),(5,6,'2025-06-07','2025-06-12','pendiente'),(11,12,'2025-06-07','2025-06-12','pendiente'),(12,13,'2025-06-07','2025-06-12','pendiente'),(13,14,'2025-06-07','2025-06-12','pendiente'),(14,15,'2025-06-07','2025-06-12','pendiente'),(16,17,'2025-06-07','2025-06-12','pendiente'),(17,18,'2025-06-08','2025-06-13','pendiente');
/*!40000 ALTER TABLE `cotizacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `departamento_empresa`
--

DROP TABLE IF EXISTS `departamento_empresa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `departamento_empresa` (
  `cod_departamento_empresa` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(60) NOT NULL,
  PRIMARY KEY (`cod_departamento_empresa`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `departamento_empresa`
--

LOCK TABLES `departamento_empresa` WRITE;
/*!40000 ALTER TABLE `departamento_empresa` DISABLE KEYS */;
INSERT INTO `departamento_empresa` VALUES (1,'Dirección General'),(2,'Facturación'),(3,'Eventos'),(4,'Recorridos Escolares');
/*!40000 ALTER TABLE `departamento_empresa` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `departamentos`
--

DROP TABLE IF EXISTS `departamentos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `departamentos` (
  `cod_departamento` int NOT NULL AUTO_INCREMENT,
  `departamento` varchar(60) NOT NULL,
  PRIMARY KEY (`cod_departamento`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `departamentos`
--

LOCK TABLES `departamentos` WRITE;
/*!40000 ALTER TABLE `departamentos` DISABLE KEYS */;
INSERT INTO `departamentos` VALUES (1,'Atlántida'),(2,'Choluteca'),(3,'Colón'),(4,'Comayagua'),(5,'Copán'),(6,'Cortés'),(7,'El Paraíso'),(8,'Francisco Morazán'),(9,'Gracias a Dios'),(10,'Intibucá'),(11,'Islas de la Bahía'),(12,'La Paz'),(13,'Lempira'),(14,'Ocotepeque'),(15,'Olancho'),(16,'Santa Bárbara'),(17,'Valle'),(18,'Yoro');
/*!40000 ALTER TABLE `departamentos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detalle_cotizacion`
--

DROP TABLE IF EXISTS `detalle_cotizacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `detalle_cotizacion` (
  `cod_detallecotizacion` int NOT NULL AUTO_INCREMENT,
  `cantidad` int NOT NULL,
  `descripcion` text NOT NULL,
  `precio_unitario` decimal(10,2) NOT NULL,
  `total` decimal(10,2) NOT NULL,
  `cod_cotizacion` int NOT NULL,
  PRIMARY KEY (`cod_detallecotizacion`),
  KEY `cod_cotizacion` (`cod_cotizacion`),
  CONSTRAINT `detalle_cotizacion_ibfk_1` FOREIGN KEY (`cod_cotizacion`) REFERENCES `cotizacion` (`cod_cotizacion`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detalle_cotizacion`
--

LOCK TABLES `detalle_cotizacion` WRITE;
/*!40000 ALTER TABLE `detalle_cotizacion` DISABLE KEYS */;
INSERT INTO `detalle_cotizacion` VALUES (1,2,'Silla blanca',25.00,50.00,1),(2,1,'Proyector HD',500.00,500.00,1),(6,5,'Silla VIP',35.00,175.00,2),(7,1,'Pantalla gigante',1800.00,1800.00,2),(19,10,'Silla blanca',25.00,250.00,3),(20,2,'Proyector HD',500.00,1000.00,3),(21,1,'Equipo de sonido',1000.00,1000.00,3),(22,5,'Mesa redonda',150.00,750.00,3),(23,10,'Mantel blanco',35.00,350.00,3),(24,10,'probando json 200',5000.00,50000.00,3),(26,2,'Tour Guiado',250.00,500.00,4),(27,1,'Paquete Familiar',950.00,950.00,4),(29,10,'Silla blnca',25.00,250.00,5),(30,2,'Proyector HD',500.00,1000.00,5),(31,1,'Equipo de sonido',1000.00,1000.00,5),(32,4,'espero que funcione esta vez',2343.00,9372.00,11),(33,2,'pruebita',213.00,426.00,12),(34,234,'sera que si funciona',23.00,5382.00,13),(35,10,'Silla blnca',75.00,750.00,14),(36,2,'Proyector HD',500.00,1000.00,14),(37,1,'Equipo de sonido',1000.00,1000.00,14),(41,1,'dffdf',232.00,232.00,16),(42,1,'vfvfdd',234.00,234.00,16),(44,1,'a festejar',200.00,200.00,17),(45,3,'champions',4388.00,13164.00,17);
/*!40000 ALTER TABLE `detalle_cotizacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `direcciones`
--

DROP TABLE IF EXISTS `direcciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `direcciones` (
  `cod_direccion` int NOT NULL AUTO_INCREMENT,
  `direccion` text,
  `cod_persona` int DEFAULT NULL,
  `cod_municipio` int DEFAULT NULL,
  PRIMARY KEY (`cod_direccion`),
  KEY `cod_persona` (`cod_persona`),
  KEY `cod_municipio` (`cod_municipio`),
  CONSTRAINT `direcciones_ibfk_1` FOREIGN KEY (`cod_persona`) REFERENCES `personas` (`cod_persona`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `direcciones_ibfk_2` FOREIGN KEY (`cod_municipio`) REFERENCES `municipios` (`cod_municipio`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `direcciones`
--

LOCK TABLES `direcciones` WRITE;
/*!40000 ALTER TABLE `direcciones` DISABLE KEYS */;
INSERT INTO `direcciones` VALUES (6,'Zambrano actualizado',6,3),(7,'Col. El Sauce, Tegucigalpa',7,2),(8,'Barrio Abajo, Tegucigalpa',10,3),(9,'Col. Las Brisas, Tegucigalpa',14,3),(10,'Col. San Ángel',15,1),(11,'Col. Las Uvas',16,1),(12,'Colonia Las Uvas',17,1),(13,'Col. Palmira, Tegucigalpa',21,1),(14,'Colonia Las Uvas',26,1),(20,'sdfghgfd',32,1),(21,'gguhhhhuhubuu',33,1),(22,'hola prueba',34,1),(23,'Colonia Las Uvas',35,1),(25,'dcsdcdscs',37,1),(26,'Canaán',38,2),(27,'Col. El Prado, Casa 15',39,2),(28,'Col. Las Brisas, Tegucigalpa',40,3),(29,'Canaán',41,2),(30,'aldea zambrano',43,2),(33,'Col. Las Brisas, Tegucigalpa',46,3),(34,'Zambrano',47,2),(35,'Siguatepeque',49,1),(36,'hjasjsjasjajsajsa',50,1);
/*!40000 ALTER TABLE `direcciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `empleados`
--

DROP TABLE IF EXISTS `empleados`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `empleados` (
  `cod_empleado` int NOT NULL AUTO_INCREMENT,
  `cargo` varchar(50) DEFAULT NULL,
  `salario` decimal(10,2) NOT NULL,
  `fecha_contratacion` datetime DEFAULT NULL,
  `cod_persona` int DEFAULT NULL,
  `cod_departamento_empresa` int DEFAULT NULL,
  PRIMARY KEY (`cod_empleado`),
  KEY `cod_persona` (`cod_persona`),
  KEY `cod_departamento_empresa` (`cod_departamento_empresa`),
  CONSTRAINT `empleados_ibfk_1` FOREIGN KEY (`cod_persona`) REFERENCES `personas` (`cod_persona`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `empleados_ibfk_2` FOREIGN KEY (`cod_departamento_empresa`) REFERENCES `departamento_empresa` (`cod_departamento_empresa`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `empleados`
--

LOCK TABLES `empleados` WRITE;
/*!40000 ALTER TABLE `empleados` DISABLE KEYS */;
INSERT INTO `empleados` VALUES (6,'Admin total',95000.00,'2025-05-07 00:00:00',6,1),(7,'Coordinador de Eventos',22000.00,'2025-06-07 00:00:00',10,2),(8,'Técnico audiovisual',16000.00,'2025-06-10 00:00:00',14,2),(9,'La Bonita del Grupo',89000.00,'2025-06-18 00:00:00',38,2),(10,'The Best',56897.00,'2024-12-25 00:00:00',39,3),(11,'Técnico audiovisual',15000.00,'2025-06-10 00:00:00',40,1),(12,'La Bonita del Grupo',23451.00,'2025-06-18 00:00:00',41,2),(13,'Técnico audiovisual',15000.00,'2025-06-10 00:00:00',46,1),(14,'solo se que ya no',12000.00,'2024-10-09 00:00:00',47,2),(15,'Barcelona',12345.00,'2025-02-12 00:00:00',49,1),(16,'probando valiaaciones',89999.00,'2025-03-04 00:00:00',50,1);
/*!40000 ALTER TABLE `empleados` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `entradas`
--

DROP TABLE IF EXISTS `entradas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `entradas` (
  `cod_entrada` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) DEFAULT NULL,
  `precio` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`cod_entrada`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `entradas`
--

LOCK TABLES `entradas` WRITE;
/*!40000 ALTER TABLE `entradas` DISABLE KEYS */;
INSERT INTO `entradas` VALUES (1,'Entrada General',150.00),(2,'Entrada VIP actualizada',400.00),(3,'myke mejor',1234.00);
/*!40000 ALTER TABLE `entradas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `evento`
--

DROP TABLE IF EXISTS `evento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `evento` (
  `cod_evento` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `fecha_programa` date NOT NULL,
  `hora_programada` time NOT NULL,
  `cod_cotizacion` int NOT NULL,
  PRIMARY KEY (`cod_evento`),
  KEY `cod_cotizacion` (`cod_cotizacion`),
  CONSTRAINT `evento_ibfk_1` FOREIGN KEY (`cod_cotizacion`) REFERENCES `cotizacion` (`cod_cotizacion`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `evento`
--

LOCK TABLES `evento` WRITE;
/*!40000 ALTER TABLE `evento` DISABLE KEYS */;
INSERT INTO `evento` VALUES (1,'Fiesta de cumpleaños','2025-07-10','15:30:00',1),(2,'Cumpleaños de Sofía','2025-07-10','15:30:00',2),(3,'Cumpleos de Sofía','2025-07-10','15:30:00',3),(4,'Evento Educativo','2025-07-01','09:30:00',4),(5,'Cum de Sofía','2025-07-10','19:30:00',5),(11,'ya que se poner','2025-06-17','22:22:00',11),(12,'probado alertas','2025-06-16','21:29:00',12),(13,'alertas si?','2025-06-15','23:39:00',13),(14,'Cum de Sofía','2025-07-10','19:30:00',14),(16,'dfsdcdsvd','2025-06-09','22:45:00',16),(17,'Gano Portugal','2025-06-08','22:00:00',17);
/*!40000 ALTER TABLE `evento` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventario`
--

DROP TABLE IF EXISTS `inventario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventario` (
  `cod_inventario` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text,
  `precio_unitario` decimal(10,2) NOT NULL,
  `cantidad_disponible` int NOT NULL,
  `estado` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`cod_inventario`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventario`
--

LOCK TABLES `inventario` WRITE;
/*!40000 ALTER TABLE `inventario` DISABLE KEYS */;
INSERT INTO `inventario` VALUES (2,'Laptop Gamer Actualizada','Asus ROG Strix 2025',1599.99,13,1);
/*!40000 ALTER TABLE `inventario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_batches`
--

LOCK TABLES `job_batches` WRITE;
/*!40000 ALTER TABLE `job_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint unsigned NOT NULL,
  `reserved_at` int unsigned DEFAULT NULL,
  `available_at` int unsigned NOT NULL,
  `created_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'0001_01_01_000000_create_users_table',1),(2,'0001_01_01_000001_create_cache_table',1),(3,'0001_01_01_000002_create_jobs_table',1);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `municipios`
--

DROP TABLE IF EXISTS `municipios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `municipios` (
  `cod_municipio` int NOT NULL AUTO_INCREMENT,
  `municipio` varchar(60) NOT NULL,
  `cod_departamento` int DEFAULT NULL,
  PRIMARY KEY (`cod_municipio`),
  KEY `cod_departamento` (`cod_departamento`),
  CONSTRAINT `municipios_ibfk_1` FOREIGN KEY (`cod_departamento`) REFERENCES `departamentos` (`cod_departamento`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=299 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `municipios`
--

LOCK TABLES `municipios` WRITE;
/*!40000 ALTER TABLE `municipios` DISABLE KEYS */;
INSERT INTO `municipios` VALUES (1,'La Ceiba',1),(2,'El Porvenir',1),(3,'Tela',1),(4,'Jutiapa',1),(5,'La Masica',1),(6,'San Francisco',1),(7,'Arizona',1),(8,'Esparta',1),(9,'Choluteca',2),(10,'Apacilagua',2),(11,'Concepción de María',2),(12,'Duyure',2),(13,'El Corpus',2),(14,'El Triunfo',2),(15,'Marcovia',2),(16,'Morolica',2),(17,'Namasigüe',2),(18,'Orocuina',2),(19,'Pespire',2),(20,'San Antonio de Flores',2),(21,'San Isidro',2),(22,'San José',2),(23,'San Marcos de Colón',2),(24,'Santa Ana de Yusguare',2),(25,'Trujillo',3),(26,'Balfate',3),(27,'Iriona',3),(28,'Limón',3),(29,'Sabá',3),(30,'Santa Fe',3),(31,'Santa Rosa de Aguán',3),(32,'Sonaguera',3),(33,'Tocoa',3),(34,'Bonito Oriental',3),(35,'Comayagua',4),(36,'Ajuterique',4),(37,'El Rosario',4),(38,'Esquías',4),(39,'Humuya',4),(40,'La Libertad',4),(41,'Lamaní',4),(42,'La Trinidad',4),(43,'Lejamaní',4),(44,'Meámbar',4),(45,'Minas de Oro',4),(46,'Ojos de Agua',4),(47,'San Jerónimo',4),(48,'San José de Comayagua',4),(49,'San José del Potrero',4),(50,'San Luis',4),(51,'San Sebastián',4),(52,'Siguatepeque',4),(53,'Villa de San Antonio',4),(54,'Las Lajas',4),(55,'Taulabé',4),(56,'Santa Rosa de Copán',5),(57,'Cabañas',5),(58,'Concepción',5),(59,'Copán Ruinas',5),(60,'Corquín',5),(61,'Cucuyagua',5),(62,'Dolores',5),(63,'Dulce Nombre',5),(64,'El Paraíso',5),(65,'Florida',5),(66,'La Jigua',5),(67,'La Unión',5),(68,'Nueva Arcadia',5),(69,'San Agustín',5),(70,'San Antonio',5),(71,'San Jerónimo',5),(72,'San José',5),(73,'San Juan de Opoa',5),(74,'San Nicolás',5),(75,'San Pedro',5),(76,'Santa Rita',5),(77,'Trinidad de Copán',5),(78,'Veracruz',5),(79,'San Pedro Sula',6),(80,'Choloma',6),(81,'Omoa',6),(82,'Pimienta',6),(83,'Potrerillos',6),(84,'Puerto Cortés',6),(85,'San Antonio de Cortés',6),(86,'San Francisco de Yojoa',6),(87,'San Manuel',6),(88,'Santa Cruz de Yojoa',6),(89,'Villanueva',6),(90,'La Lima',6),(91,'Yuscarán',7),(92,'Alauca',7),(93,'Danlí',7),(94,'El Paraíso',7),(95,'Güinope',7),(96,'Jacaleapa',7),(97,'Liure',7),(98,'Morocelí',7),(99,'Oropolí',7),(100,'Potrerillos',7),(101,'San Antonio de Flores',7),(102,'San Lucas',7),(103,'San Matías',7),(104,'Soledad',7),(105,'Teupasenti',7),(106,'Texiguat',7),(107,'Vado Ancho',7),(108,'Yauyupe',7),(109,'Trojes',7),(110,'Distrito Central',8),(111,'Alubarén',8),(112,'Cedros',8),(113,'Curarén',8),(114,'El Porvenir',8),(115,'Guaimaca',8),(116,'La Libertad',8),(117,'La Venta',8),(118,'Lepaterique',8),(119,'Maraita',8),(120,'Marale',8),(121,'Nueva Armenia',8),(122,'Ojojona',8),(123,'Orica',8),(124,'Reitoca',8),(125,'Sabanagrande',8),(126,'San Antonio de Oriente',8),(127,'San Buenaventura',8),(128,'San Ignacio',8),(129,'Cantarranas',8),(130,'San Miguelito',8),(131,'Santa Ana',8),(132,'Santa Lucía',8),(133,'Talanga',8),(134,'Tatumbla',8),(135,'Valle de Ángeles',8),(136,'Villa de San Francisco',8),(137,'Vallecillo',8),(138,'Puerto Lempira',9),(139,'Brus Laguna',9),(140,'Ahuas',9),(141,'Juan Francisco Bulnes',9),(142,'Villeda Morales',9),(143,'Wampusirpe',9),(144,'La Esperanza',10),(145,'Camasca',10),(146,'Colomoncagua',10),(147,'Concepción',10),(148,'Dolores',10),(149,'Intibucá',10),(150,'Jesús de Otoro',10),(151,'Magdalena',10),(152,'Masaguara',10),(153,'San Antonio',10),(154,'San Isidro',10),(155,'San Juan',10),(156,'San Marcos de la Sierra',10),(157,'San Miguel Guancapla',10),(158,'Santa Lucía',10),(159,'Yamaranguila',10),(160,'San Francisco de Opalaca',10),(161,'Roatán',11),(162,'Guanaja',11),(163,'José Santos Guardiola',11),(164,'Utila',11),(165,'La Paz',12),(166,'Aguanqueterique',12),(167,'Cabañas',12),(168,'Cane',12),(169,'Chinacla',12),(170,'Guajiquiro',12),(171,'Lauterique',12),(172,'Marcala',12),(173,'Mercedes de Oriente',12),(174,'Opatoro',12),(175,'San Antonio del Norte',12),(176,'San José',12),(177,'San Juan',12),(178,'San Pedro de Tutule',12),(179,'Santa Ana',12),(180,'Santa Elena',12),(181,'Santa María',12),(182,'Santiago de Puringla',12),(183,'Yarula',12),(184,'Gracias',13),(185,'Belén',13),(186,'Candelaria',13),(187,'Cololaca',13),(188,'Erandique',13),(189,'Gualcince',13),(190,'Guarita',13),(191,'La Campa',13),(192,'La Iguala',13),(193,'Las Flores',13),(194,'La Unión',13),(195,'La Virtud',13),(196,'Lepaera',13),(197,'Mapulaca',13),(198,'Piraera',13),(199,'San Andrés',13),(200,'San Francisco',13),(201,'San Juan Guarita',13),(202,'San Manuel Colohete',13),(203,'San Rafael',13),(204,'San Sebastián',13),(205,'Santa Cruz',13),(206,'Talgua',13),(207,'Tambla',13),(208,'Tomalá',13),(209,'Valladolid',13),(210,'Virginia',13),(211,'San Marcos de Caiquín',13),(212,'Ocotepeque',14),(213,'Belén Gualcho',14),(214,'Concepción',14),(215,'Dolores Merendón',14),(216,'Fraternidad',14),(217,'La Encarnación',14),(218,'La Labor',14),(219,'Lucerna',14),(220,'Mercedes',14),(221,'San Fernando',14),(222,'San Francisco del Valle',14),(223,'San Jorge',14),(224,'San Marcos',14),(225,'Santa Fe',14),(226,'Sensenti',14),(227,'Sinuapa',14),(228,'Juticalpa',15),(229,'Campamento',15),(230,'Catacamas',15),(231,'Concordia',15),(232,'Dulce Nombre de Culmí',15),(233,'El Rosario',15),(234,'Esquipulas del Norte',15),(235,'Gualaco',15),(236,'Guarizama',15),(237,'Guata',15),(238,'Guayape',15),(239,'Jano',15),(240,'La Unión',15),(241,'Mangulile',15),(242,'Manto',15),(243,'Salamá',15),(244,'San Esteban',15),(245,'San Francisco de Becerra',15),(246,'San Francisco de la Paz',15),(247,'Santa María del Real',15),(248,'Silca',15),(249,'Yocón',15),(250,'Patuca',15),(251,'Santa Bárbara',16),(252,'Arada',16),(253,'Atima',16),(254,'Azacualpa',16),(255,'Ceguaca',16),(256,'Concepción del Norte',16),(257,'Concepción del Sur',16),(258,'Chinda',16),(259,'El Níspero',16),(260,'Gualala',16),(261,'Ilama',16),(262,'Las Vegas',16),(263,'Macuelizo',16),(264,'Naranjito',16),(265,'Nuevo Celilac',16),(266,'Nueva Frontera',16),(267,'Petoa',16),(268,'Protección',16),(269,'Quimistán',16),(270,'San Francisco de Ojuera',16),(271,'San José de las Colinas',16),(272,'San Luis',16),(273,'San Marcos',16),(274,'San Nicolás',16),(275,'San Pedro Zacapa',16),(276,'San Vicente Centenario',16),(277,'Santa Rita',16),(278,'Trinidad',16),(279,'Nacaome',17),(280,'Alianza',17),(281,'Amapala',17),(282,'Aramecina',17),(283,'Caridad',17),(284,'Goascorán',17),(285,'Langue',17),(286,'San Francisco de Coray',17),(287,'San Lorenzo',17),(288,'Yoro',18),(289,'Arenal',18),(290,'El Negrito',18),(291,'El Progreso',18),(292,'Jocón',18),(293,'Morazán',18),(294,'Olanchito',18),(295,'Santa Rita',18),(296,'Sulaco',18),(297,'Victoria',18),(298,'Yorito',18);
/*!40000 ALTER TABLE `municipios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `objetos`
--

DROP TABLE IF EXISTS `objetos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `objetos` (
  `cod_objeto` int NOT NULL AUTO_INCREMENT,
  `tipo_objeto` varchar(50) DEFAULT NULL,
  `descripcion` text,
  PRIMARY KEY (`cod_objeto`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `objetos`
--

LOCK TABLES `objetos` WRITE;
/*!40000 ALTER TABLE `objetos` DISABLE KEYS */;
INSERT INTO `objetos` VALUES (1,'Pantalla','Gestión de empleados'),(2,'Pantalla','Gestión de productos'),(3,'Pantalla','Gestión de salones'),(4,'Pantalla','Gestión de cotizaciones'),(5,'Pantalla','Gestión de reservaciones'),(6,'Pantalla','Facturación de eventos'),(7,'Pantalla','Facturación de entradas generales'),(8,'Pantalla','Panel de administración'),(9,'Pantalla','Gestión de CAI'),(10,'Pantalla','Bitácora del sistema'),(11,'Pantalla','Gestión de clientes'),(12,'Pantalla','Gestión de recorridos escolares'),(13,'Pantalla','Gestión de Backup');
/*!40000 ALTER TABLE `objetos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paquetes`
--

DROP TABLE IF EXISTS `paquetes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `paquetes` (
  `cod_paquete` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) DEFAULT NULL,
  `descripcion` text,
  `precio` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`cod_paquete`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paquetes`
--

LOCK TABLES `paquetes` WRITE;
/*!40000 ALTER TABLE `paquetes` DISABLE KEYS */;
INSERT INTO `paquetes` VALUES (1,'Paquete VIP Actualizado','Incluye acceso VIP, catering de lujo, transporte y hospedaje',3800.00),(3,'nuevo paquete xq si','myke el mejor',5342.00);
/*!40000 ALTER TABLE `paquetes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permisos`
--

DROP TABLE IF EXISTS `permisos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permisos` (
  `cod_permiso` int NOT NULL AUTO_INCREMENT,
  `cod_rol` int DEFAULT NULL,
  `cod_objeto` int DEFAULT NULL,
  `nombre` varchar(50) DEFAULT NULL,
  `crear` tinyint(1) DEFAULT '0',
  `modificar` tinyint(1) DEFAULT '0',
  `mostrar` tinyint(1) DEFAULT '0',
  `eliminar` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`cod_permiso`),
  KEY `cod_rol` (`cod_rol`),
  KEY `cod_objeto` (`cod_objeto`),
  CONSTRAINT `permisos_ibfk_1` FOREIGN KEY (`cod_rol`) REFERENCES `roles` (`cod_rol`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `permisos_ibfk_2` FOREIGN KEY (`cod_objeto`) REFERENCES `objetos` (`cod_objeto`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permisos`
--

LOCK TABLES `permisos` WRITE;
/*!40000 ALTER TABLE `permisos` DISABLE KEYS */;
INSERT INTO `permisos` VALUES (1,1,1,'Acceso total a Gestión de empleados',1,1,1,1),(2,1,2,'Acceso total a Gestión de productos',1,1,1,1),(3,1,3,'Acceso total a Gestión de salones',1,1,1,1),(4,1,4,'Acceso total a Gestión de cotizaciones',1,1,1,1),(5,1,5,'Acceso total a Gestión de reservaciones',1,1,1,1),(6,1,6,'Acceso total a Facturación de eventos',1,1,1,1),(7,1,7,'Acceso total a Facturación de entradas generales',1,1,1,1),(8,2,8,'Acceso total a Panel de administración',1,1,1,1),(9,1,9,'Acceso total a Gestión de CAI',1,1,1,1),(10,1,10,'Acceso total a Bitácora del sistema',1,1,1,1),(16,2,6,'Facturación de eventos',1,0,1,0),(17,3,2,'Gestión de productos',0,1,1,0),(18,4,3,'Gestión de salones',1,1,1,1),(19,4,4,'Gestión de cotizaciones',1,1,1,1),(20,4,5,'Gestión de reservaciones',1,1,1,1),(21,5,7,'Facturación entradas generales',1,0,1,0),(23,9,5,'Permiso actualizado por myke',1,0,1,1),(25,1,11,'Acceso total a Gestión de clientes',1,1,1,1),(26,1,12,'Acceso total a Gestión de recorridos escolares',1,1,1,1),(27,1,8,'Acceso total al Panel de administración',1,1,1,1),(28,1,13,'Acceso total a Gestión de Backup',1,1,1,1);
/*!40000 ALTER TABLE `permisos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personas`
--

DROP TABLE IF EXISTS `personas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `personas` (
  `cod_persona` int NOT NULL AUTO_INCREMENT,
  `nombre_persona` varchar(100) NOT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `sexo` enum('Masculino','Femenino') DEFAULT NULL,
  `dni` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`cod_persona`),
  UNIQUE KEY `dni` (`dni`)
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personas`
--

LOCK TABLES `personas` WRITE;
/*!40000 ALTER TABLE `personas` DISABLE KEYS */;
INSERT INTO `personas` VALUES (6,'Miguel García','2025-05-15','Masculino','0801890021222'),(7,'Carlos Mendoza','1990-12-05','Masculino','0801199012345'),(10,'Carlos Riveras','1992-03-20','Masculino','0801199211223'),(14,'Javier Salgado si paso la prue','1990-06-15','Masculino','5674625387985'),(15,'Juan josue','1990-06-15','Masculino','08011912345'),(16,'Juan Pérez','1990-06-15','Masculino','0801199912345'),(17,'probanddo api','1990-06-15','Masculino','080912345'),(21,'Camila García','1995-08-12','Femenino','0801199512345'),(26,'probando el tipo','9999-06-15','Masculino','080120032341'),(32,'probando la vista','2002-02-07','Masculino','080120222222'),(33,'probando sweetalert2','2001-12-31','Masculino','08103421'),(34,'miguel barahona','2008-01-29','Masculino','08102345'),(35,'probando el tipo rsultad','9999-06-15','Masculino','333332341'),(37,'probando la vista','2001-06-05','Masculino','080120031345'),(38,'kellyn Castillo','1996-05-05','Masculino','08190121'),(39,'Admin Lord','1997-01-07','Masculino','080120259801'),(40,'Enviar Credenciales','1990-06-15','Masculino','89129011000'),(41,'kellyn Castillo','2003-06-09','Masculino','6754333'),(43,'san antonio','2025-06-17','Masculino','0890109122'),(46,'probando api','1990-06-15','Masculino','12098211221'),(47,'ya se jodio','2024-11-12','Masculino','65782129876'),(49,'funxiona siono','2007-01-30','Masculino','2345232314151'),(50,'Ultima prueba','2001-02-14','Masculino','6532653265236');
/*!40000 ALTER TABLE `personas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `cod_rol` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `descripcion` text,
  `estado` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`cod_rol`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'Dirección','probando api con laravel',1),(2,'FacEL',NULL,1),(3,'Escolar',NULL,1),(4,'Evento',NULL,1),(5,'Factaquilla',NULL,1),(8,'Myke_pros','Es el mejor programando, la real.',1),(9,'ADMON Reservas','NUEVO PERMISO.',1);
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `salon_horario`
--

DROP TABLE IF EXISTS `salon_horario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `salon_horario` (
  `cod_salon_horario` int NOT NULL AUTO_INCREMENT,
  `cod_salon` int DEFAULT NULL,
  `cod_tipo_horario` int DEFAULT NULL,
  `precio` decimal(10,2) DEFAULT NULL,
  `precio_hora_extra` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`cod_salon_horario`),
  KEY `cod_salon` (`cod_salon`),
  KEY `fk_tipo_horario` (`cod_tipo_horario`),
  CONSTRAINT `fk_tipo_horario` FOREIGN KEY (`cod_tipo_horario`) REFERENCES `tipo_horario` (`cod_tipo_horario`) ON DELETE CASCADE,
  CONSTRAINT `salon_horario_ibfk_1` FOREIGN KEY (`cod_salon`) REFERENCES `salones` (`cod_salon`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `salon_horario`
--

LOCK TABLES `salon_horario` WRITE;
/*!40000 ALTER TABLE `salon_horario` DISABLE KEYS */;
INSERT INTO `salon_horario` VALUES (1,1,1,1200.00,100.00),(2,1,2,1380.00,150.00),(3,2,1,10000.00,1200.00),(4,2,2,16000.00,1800.00),(5,3,1,120.00,100.00),(6,3,2,180.00,150.00),(7,4,1,1800.00,200.00),(8,4,2,2070.00,300.00),(11,6,1,1100.00,800.00),(12,6,2,1265.00,900.00),(13,7,1,800.00,87.00),(14,7,2,920.00,200.00),(15,8,1,100.00,80.00),(16,8,2,150.00,90.00),(23,12,1,12321.00,43421.00),(24,12,2,32411.00,1234.00),(25,13,1,12346.00,234.00),(26,13,2,12345.00,234.00),(27,14,1,2332.00,23.00),(28,14,2,2342.00,23.00),(29,15,1,34232.00,324343.00),(30,15,2,323432.00,324234.00),(31,16,1,34232.00,324343.00),(32,16,2,323432.00,324234.00);
/*!40000 ALTER TABLE `salon_horario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `salones`
--

DROP TABLE IF EXISTS `salones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `salones` (
  `cod_salon` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text,
  `capacidad` int DEFAULT NULL,
  `estado` tinyint DEFAULT '1',
  PRIMARY KEY (`cod_salon`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `salones`
--

LOCK TABLES `salones` WRITE;
/*!40000 ALTER TABLE `salones` DISABLE KEYS */;
INSERT INTO `salones` VALUES (1,'Plaza Cultural','Área abierta para actividades culturales.',200,1),(2,'Salón VIP Gold','Salón remodelado con barra premium',400,0),(3,'Salón VIP','Salón remodelado con capacidad para 300 personas.',300,1),(4,'Auditorio Central','Auditorio techado con escenario y sonido.',120,1),(6,'Salón VIP','Interior con aire acondicionado y mobiliario moderno.',35,1),(7,'Salón Creativo','Espacio interior ideal para talleres educativos.',50,1),(8,'Salón Principal','Salón amplio con capacidad para 500 personas.',500,1),(12,'myke','jndhsdfhifsdihdfsihdfsih',234235,1),(13,'ya estoy aburrido','hhbhjubjbj',4345,1),(14,'ya estoy aburrido','fsdfdf',234,1),(15,'asdfdf','sasfdfsdf',234,1),(16,'asdfdf','sasfdfsdf',234,1);
/*!40000 ALTER TABLE `salones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES ('BmZg1nEezaOByMD9ZwYSZoxq2mWbAd3HPRWIl0gb',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0','YTo2OntzOjY6Il9mbGFzaCI7YToyOntzOjM6Im5ldyI7YTowOnt9czozOiJvbGQiO2E6MDp7fX1zOjY6Il90b2tlbiI7czo0MDoiR0xkek9vczB2TmNjZFpHQ1o2ZXc1bGVhU3VyRlZqT3BpYmtHZnNrTCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6Mzk6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9iaXRhY29yYS9leHBvcnRhciI7fXM6ODoicGVybWlzb3MiO2E6MTM6e2k6MDthOjU6e3M6Njoib2JqZXRvIjtzOjIxOiJHZXN0acOzbiBkZSBlbXBsZWFkb3MiO3M6ODoiaW5zZXJ0YXIiO2I6MTtzOjEwOiJhY3R1YWxpemFyIjtiOjE7czo3OiJtb3N0cmFyIjtiOjE7czo4OiJlbGltaW5hciI7YjoxO31pOjE7YTo1OntzOjY6Im9iamV0byI7czoyMToiR2VzdGnDs24gZGUgcHJvZHVjdG9zIjtzOjg6Imluc2VydGFyIjtiOjE7czoxMDoiYWN0dWFsaXphciI7YjoxO3M6NzoibW9zdHJhciI7YjoxO3M6ODoiZWxpbWluYXIiO2I6MTt9aToyO2E6NTp7czo2OiJvYmpldG8iO3M6MTk6Ikdlc3Rpw7NuIGRlIHNhbG9uZXMiO3M6ODoiaW5zZXJ0YXIiO2I6MTtzOjEwOiJhY3R1YWxpemFyIjtiOjE7czo3OiJtb3N0cmFyIjtiOjE7czo4OiJlbGltaW5hciI7YjoxO31pOjM7YTo1OntzOjY6Im9iamV0byI7czoyNDoiR2VzdGnDs24gZGUgY290aXphY2lvbmVzIjtzOjg6Imluc2VydGFyIjtiOjE7czoxMDoiYWN0dWFsaXphciI7YjoxO3M6NzoibW9zdHJhciI7YjoxO3M6ODoiZWxpbWluYXIiO2I6MTt9aTo0O2E6NTp7czo2OiJvYmpldG8iO3M6MjU6Ikdlc3Rpw7NuIGRlIHJlc2VydmFjaW9uZXMiO3M6ODoiaW5zZXJ0YXIiO2I6MTtzOjEwOiJhY3R1YWxpemFyIjtiOjE7czo3OiJtb3N0cmFyIjtiOjE7czo4OiJlbGltaW5hciI7YjoxO31pOjU7YTo1OntzOjY6Im9iamV0byI7czoyMzoiRmFjdHVyYWNpw7NuIGRlIGV2ZW50b3MiO3M6ODoiaW5zZXJ0YXIiO2I6MTtzOjEwOiJhY3R1YWxpemFyIjtiOjE7czo3OiJtb3N0cmFyIjtiOjE7czo4OiJlbGltaW5hciI7YjoxO31pOjY7YTo1OntzOjY6Im9iamV0byI7czozNDoiRmFjdHVyYWNpw7NuIGRlIGVudHJhZGFzIGdlbmVyYWxlcyI7czo4OiJpbnNlcnRhciI7YjoxO3M6MTA6ImFjdHVhbGl6YXIiO2I6MTtzOjc6Im1vc3RyYXIiO2I6MTtzOjg6ImVsaW1pbmFyIjtiOjE7fWk6NzthOjU6e3M6Njoib2JqZXRvIjtzOjE1OiJHZXN0acOzbiBkZSBDQUkiO3M6ODoiaW5zZXJ0YXIiO2I6MTtzOjEwOiJhY3R1YWxpemFyIjtiOjE7czo3OiJtb3N0cmFyIjtiOjE7czo4OiJlbGltaW5hciI7YjoxO31pOjg7YTo1OntzOjY6Im9iamV0byI7czoyMToiQml0w6Fjb3JhIGRlbCBzaXN0ZW1hIjtzOjg6Imluc2VydGFyIjtiOjE7czoxMDoiYWN0dWFsaXphciI7YjoxO3M6NzoibW9zdHJhciI7YjoxO3M6ODoiZWxpbWluYXIiO2I6MTt9aTo5O2E6NTp7czo2OiJvYmpldG8iO3M6MjA6Ikdlc3Rpw7NuIGRlIGNsaWVudGVzIjtzOjg6Imluc2VydGFyIjtiOjE7czoxMDoiYWN0dWFsaXphciI7YjoxO3M6NzoibW9zdHJhciI7YjoxO3M6ODoiZWxpbWluYXIiO2I6MTt9aToxMDthOjU6e3M6Njoib2JqZXRvIjtzOjMyOiJHZXN0acOzbiBkZSByZWNvcnJpZG9zIGVzY29sYXJlcyI7czo4OiJpbnNlcnRhciI7YjoxO3M6MTA6ImFjdHVhbGl6YXIiO2I6MTtzOjc6Im1vc3RyYXIiO2I6MTtzOjg6ImVsaW1pbmFyIjtiOjE7fWk6MTE7YTo1OntzOjY6Im9iamV0byI7czoyNDoiUGFuZWwgZGUgYWRtaW5pc3RyYWNpw7NuIjtzOjg6Imluc2VydGFyIjtiOjE7czoxMDoiYWN0dWFsaXphciI7YjoxO3M6NzoibW9zdHJhciI7YjoxO3M6ODoiZWxpbWluYXIiO2I6MTt9aToxMjthOjU6e3M6Njoib2JqZXRvIjtzOjE4OiJHZXN0acOzbiBkZSBCYWNrdXAiO3M6ODoiaW5zZXJ0YXIiO2I6MTtzOjEwOiJhY3R1YWxpemFyIjtiOjE7czo3OiJtb3N0cmFyIjtiOjE7czo4OiJlbGltaW5hciI7YjoxO319czo1OiJ0b2tlbiI7czoxODY1OiJleUpoYkdjaU9pSklVekkxTmlJc0luUjVjQ0k2SWtwWFZDSjkuZXlKamIyUmZkWE4xWVhKcGJ5STZJakVpTENKd1pYSnRhWE52Y3lJNlczc2liMkpxWlhSdklqb2lSMlZ6ZEduRHMyNGdaR1VnWlcxd2JHVmhaRzl6SWl3aVkzSmxZWElpT25SeWRXVXNJbTF2WkdsbWFXTmhjaUk2ZEhKMVpTd2liVzl6ZEhKaGNpSTZkSEoxWlN3aVpXeHBiV2x1WVhJaU9uUnlkV1Y5TEhzaWIySnFaWFJ2SWpvaVIyVnpkR25EczI0Z1pHVWdjSEp2WkhWamRHOXpJaXdpWTNKbFlYSWlPblJ5ZFdVc0ltMXZaR2xtYVdOaGNpSTZkSEoxWlN3aWJXOXpkSEpoY2lJNmRISjFaU3dpWld4cGJXbHVZWElpT25SeWRXVjlMSHNpYjJKcVpYUnZJam9pUjJWemRHbkRzMjRnWkdVZ2MyRnNiMjVsY3lJc0ltTnlaV0Z5SWpwMGNuVmxMQ0p0YjJScFptbGpZWElpT25SeWRXVXNJbTF2YzNSeVlYSWlPblJ5ZFdVc0ltVnNhVzFwYm1GeUlqcDBjblZsZlN4N0ltOWlhbVYwYnlJNklrZGxjM1JwdzdOdUlHUmxJR052ZEdsNllXTnBiMjVsY3lJc0ltTnlaV0Z5SWpwMGNuVmxMQ0p0YjJScFptbGpZWElpT25SeWRXVXNJbTF2YzNSeVlYSWlPblJ5ZFdVc0ltVnNhVzFwYm1GeUlqcDBjblZsZlN4N0ltOWlhbVYwYnlJNklrZGxjM1JwdzdOdUlHUmxJSEpsYzJWeWRtRmphVzl1WlhNaUxDSmpjbVZoY2lJNmRISjFaU3dpYlc5a2FXWnBZMkZ5SWpwMGNuVmxMQ0p0YjNOMGNtRnlJanAwY25WbExDSmxiR2x0YVc1aGNpSTZkSEoxWlgwc2V5SnZZbXBsZEc4aU9pSkdZV04wZFhKaFkybkRzMjRnWkdVZ1pYWmxiblJ2Y3lJc0ltTnlaV0Z5SWpwMGNuVmxMQ0p0YjJScFptbGpZWElpT25SeWRXVXNJbTF2YzNSeVlYSWlPblJ5ZFdVc0ltVnNhVzFwYm1GeUlqcDBjblZsZlN4N0ltOWlhbVYwYnlJNklrWmhZM1IxY21GamFjT3piaUJrWlNCbGJuUnlZV1JoY3lCblpXNWxjbUZzWlhNaUxDSmpjbVZoY2lJNmRISjFaU3dpYlc5a2FXWnBZMkZ5SWpwMGNuVmxMQ0p0YjNOMGNtRnlJanAwY25WbExDSmxiR2x0YVc1aGNpSTZkSEoxWlgwc2V5SnZZbXBsZEc4aU9pSkhaWE4wYWNPemJpQmtaU0JEUVVraUxDSmpjbVZoY2lJNmRISjFaU3dpYlc5a2FXWnBZMkZ5SWpwMGNuVmxMQ0p0YjNOMGNtRnlJanAwY25WbExDSmxiR2x0YVc1aGNpSTZkSEoxWlgwc2V5SnZZbXBsZEc4aU9pSkNhWFREb1dOdmNtRWdaR1ZzSUhOcGMzUmxiV0VpTENKamNtVmhjaUk2ZEhKMVpTd2liVzlrYVdacFkyRnlJanAwY25WbExDSnRiM04wY21GeUlqcDBjblZsTENKbGJHbHRhVzVoY2lJNmRISjFaWDBzZXlKdlltcGxkRzhpT2lKSFpYTjBhY096YmlCa1pTQmpiR2xsYm5SbGN5SXNJbU55WldGeUlqcDBjblZsTENKdGIyUnBabWxqWVhJaU9uUnlkV1VzSW0xdmMzUnlZWElpT25SeWRXVXNJbVZzYVcxcGJtRnlJanAwY25WbGZTeDdJbTlpYW1WMGJ5STZJa2RsYzNScHc3TnVJR1JsSUhKbFkyOXljbWxrYjNNZ1pYTmpiMnhoY21Weklpd2lZM0psWVhJaU9uUnlkV1VzSW0xdlpHbG1hV05oY2lJNmRISjFaU3dpYlc5emRISmhjaUk2ZEhKMVpTd2laV3hwYldsdVlYSWlPblJ5ZFdWOUxIc2liMkpxWlhSdklqb2lVR0Z1Wld3Z1pHVWdZV1J0YVc1cGMzUnlZV05wdzdOdUlpd2lZM0psWVhJaU9uUnlkV1VzSW0xdlpHbG1hV05oY2lJNmRISjFaU3dpYlc5emRISmhjaUk2ZEhKMVpTd2laV3hwYldsdVlYSWlPblJ5ZFdWOUxIc2liMkpxWlhSdklqb2lSMlZ6ZEduRHMyNGdaR1VnUW1GamEzVndJaXdpWTNKbFlYSWlPblJ5ZFdVc0ltMXZaR2xtYVdOaGNpSTZkSEoxWlN3aWJXOXpkSEpoY2lJNmRISjFaU3dpWld4cGJXbHVZWElpT25SeWRXVjlYU3dpYVdGMElqb3hOelE1T1Rjd05qUXpMQ0psZUhBaU9qRTNORGs1TnpReU5ETjkuT1J3QjJXUUVmZWM3T3AxMzE3VEhkcElfVV9YbW5mbXhTWEdxMzA3aGhlSSI7czo3OiJ1c3VhcmlvIjthOjU6e3M6MTE6ImNvZF91c3VhcmlvIjtpOjE7czoxNDoibm9tYnJlX3VzdWFyaW8iO3M6OToienVuZ2EuaGNoIjtzOjEzOiJwcmltZXJfYWNjZXNvIjtpOjA7czozOiJyb2wiO3M6MTA6IkRpcmVjY2nDs24iO3M6ODoicGVybWlzb3MiO2E6MTM6e2k6MDthOjU6e3M6Njoib2JqZXRvIjtzOjIxOiJHZXN0acOzbiBkZSBlbXBsZWFkb3MiO3M6ODoiaW5zZXJ0YXIiO2I6MTtzOjEwOiJhY3R1YWxpemFyIjtiOjE7czo3OiJtb3N0cmFyIjtiOjE7czo4OiJlbGltaW5hciI7YjoxO31pOjE7YTo1OntzOjY6Im9iamV0byI7czoyMToiR2VzdGnDs24gZGUgcHJvZHVjdG9zIjtzOjg6Imluc2VydGFyIjtiOjE7czoxMDoiYWN0dWFsaXphciI7YjoxO3M6NzoibW9zdHJhciI7YjoxO3M6ODoiZWxpbWluYXIiO2I6MTt9aToyO2E6NTp7czo2OiJvYmpldG8iO3M6MTk6Ikdlc3Rpw7NuIGRlIHNhbG9uZXMiO3M6ODoiaW5zZXJ0YXIiO2I6MTtzOjEwOiJhY3R1YWxpemFyIjtiOjE7czo3OiJtb3N0cmFyIjtiOjE7czo4OiJlbGltaW5hciI7YjoxO31pOjM7YTo1OntzOjY6Im9iamV0byI7czoyNDoiR2VzdGnDs24gZGUgY290aXphY2lvbmVzIjtzOjg6Imluc2VydGFyIjtiOjE7czoxMDoiYWN0dWFsaXphciI7YjoxO3M6NzoibW9zdHJhciI7YjoxO3M6ODoiZWxpbWluYXIiO2I6MTt9aTo0O2E6NTp7czo2OiJvYmpldG8iO3M6MjU6Ikdlc3Rpw7NuIGRlIHJlc2VydmFjaW9uZXMiO3M6ODoiaW5zZXJ0YXIiO2I6MTtzOjEwOiJhY3R1YWxpemFyIjtiOjE7czo3OiJtb3N0cmFyIjtiOjE7czo4OiJlbGltaW5hciI7YjoxO31pOjU7YTo1OntzOjY6Im9iamV0byI7czoyMzoiRmFjdHVyYWNpw7NuIGRlIGV2ZW50b3MiO3M6ODoiaW5zZXJ0YXIiO2I6MTtzOjEwOiJhY3R1YWxpemFyIjtiOjE7czo3OiJtb3N0cmFyIjtiOjE7czo4OiJlbGltaW5hciI7YjoxO31pOjY7YTo1OntzOjY6Im9iamV0byI7czozNDoiRmFjdHVyYWNpw7NuIGRlIGVudHJhZGFzIGdlbmVyYWxlcyI7czo4OiJpbnNlcnRhciI7YjoxO3M6MTA6ImFjdHVhbGl6YXIiO2I6MTtzOjc6Im1vc3RyYXIiO2I6MTtzOjg6ImVsaW1pbmFyIjtiOjE7fWk6NzthOjU6e3M6Njoib2JqZXRvIjtzOjE1OiJHZXN0acOzbiBkZSBDQUkiO3M6ODoiaW5zZXJ0YXIiO2I6MTtzOjEwOiJhY3R1YWxpemFyIjtiOjE7czo3OiJtb3N0cmFyIjtiOjE7czo4OiJlbGltaW5hciI7YjoxO31pOjg7YTo1OntzOjY6Im9iamV0byI7czoyMToiQml0w6Fjb3JhIGRlbCBzaXN0ZW1hIjtzOjg6Imluc2VydGFyIjtiOjE7czoxMDoiYWN0dWFsaXphciI7YjoxO3M6NzoibW9zdHJhciI7YjoxO3M6ODoiZWxpbWluYXIiO2I6MTt9aTo5O2E6NTp7czo2OiJvYmpldG8iO3M6MjA6Ikdlc3Rpw7NuIGRlIGNsaWVudGVzIjtzOjg6Imluc2VydGFyIjtiOjE7czoxMDoiYWN0dWFsaXphciI7YjoxO3M6NzoibW9zdHJhciI7YjoxO3M6ODoiZWxpbWluYXIiO2I6MTt9aToxMDthOjU6e3M6Njoib2JqZXRvIjtzOjMyOiJHZXN0acOzbiBkZSByZWNvcnJpZG9zIGVzY29sYXJlcyI7czo4OiJpbnNlcnRhciI7YjoxO3M6MTA6ImFjdHVhbGl6YXIiO2I6MTtzOjc6Im1vc3RyYXIiO2I6MTtzOjg6ImVsaW1pbmFyIjtiOjE7fWk6MTE7YTo1OntzOjY6Im9iamV0byI7czoyNDoiUGFuZWwgZGUgYWRtaW5pc3RyYWNpw7NuIjtzOjg6Imluc2VydGFyIjtiOjE7czoxMDoiYWN0dWFsaXphciI7YjoxO3M6NzoibW9zdHJhciI7YjoxO3M6ODoiZWxpbWluYXIiO2I6MTt9aToxMjthOjU6e3M6Njoib2JqZXRvIjtzOjE4OiJHZXN0acOzbiBkZSBCYWNrdXAiO3M6ODoiaW5zZXJ0YXIiO2I6MTtzOjEwOiJhY3R1YWxpemFyIjtiOjE7czo3OiJtb3N0cmFyIjtiOjE7czo4OiJlbGltaW5hciI7YjoxO319fX0=',1749970699);
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `telefonos`
--

DROP TABLE IF EXISTS `telefonos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `telefonos` (
  `cod_telefono` int NOT NULL AUTO_INCREMENT,
  `telefono` varchar(20) DEFAULT NULL,
  `cod_persona` int DEFAULT NULL,
  PRIMARY KEY (`cod_telefono`),
  KEY `cod_persona` (`cod_persona`),
  CONSTRAINT `telefonos_ibfk_1` FOREIGN KEY (`cod_persona`) REFERENCES `personas` (`cod_persona`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `telefonos`
--

LOCK TABLES `telefonos` WRITE;
/*!40000 ALTER TABLE `telefonos` DISABLE KEYS */;
INSERT INTO `telefonos` VALUES (6,'97497264',6),(7,'99998888',7),(8,'99887766',10),(9,'98765432',14),(10,'9871234',15),(11,'98761234',16),(12,'987234',17),(13,'88889999',21),(14,'987234',26),(20,'54634223',32),(21,'88689857',33),(22,'4354543',34),(23,'987234',35),(25,'8868574',37),(26,'67543234',38),(27,'6789999',39),(28,'98765432',40),(29,'232232',41),(30,'124132122',43),(33,'98765432',46),(34,'56756433',47),(35,'67676767',49),(36,'63643563',50);
/*!40000 ALTER TABLE `telefonos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tipo_horario`
--

DROP TABLE IF EXISTS `tipo_horario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tipo_horario` (
  `cod_tipo_horario` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(23) DEFAULT NULL,
  PRIMARY KEY (`cod_tipo_horario`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tipo_horario`
--

LOCK TABLES `tipo_horario` WRITE;
/*!40000 ALTER TABLE `tipo_horario` DISABLE KEYS */;
INSERT INTO `tipo_horario` VALUES (1,'Día',NULL),(2,'Noche',NULL);
/*!40000 ALTER TABLE `tipo_horario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tipo_usuario`
--

DROP TABLE IF EXISTS `tipo_usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tipo_usuario` (
  `cod_tipo_usuario` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`cod_tipo_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tipo_usuario`
--

LOCK TABLES `tipo_usuario` WRITE;
/*!40000 ALTER TABLE `tipo_usuario` DISABLE KEYS */;
INSERT INTO `tipo_usuario` VALUES (1,'Interno'),(2,'Externo');
/*!40000 ALTER TABLE `tipo_usuario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `cod_usuario` int NOT NULL AUTO_INCREMENT,
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
  `cod_empleado` int DEFAULT NULL,
  PRIMARY KEY (`cod_usuario`),
  UNIQUE KEY `cod_empleado` (`cod_empleado`),
  KEY `cod_rol` (`cod_rol`),
  KEY `cod_tipo_usuario` (`cod_tipo_usuario`),
  CONSTRAINT `usuarios_ibfk_1` FOREIGN KEY (`cod_rol`) REFERENCES `roles` (`cod_rol`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `usuarios_ibfk_2` FOREIGN KEY (`cod_tipo_usuario`) REFERENCES `tipo_usuario` (`cod_tipo_usuario`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `usuarios_ibfk_3` FOREIGN KEY (`cod_empleado`) REFERENCES `empleados` (`cod_empleado`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,'zunga.hch','$2b$10$G.HlDamnc6VsYeYyLH.S.eIBvVuxAfe1YdEPVaNQUEfNGMeslV4pq',1,0,1,1,0,'::1',NULL,NULL,'2025-06-06 23:38:29',NULL,NULL,6),(2,'carlosr','$2b$10$abcdefghijk1234567890ZXCvbnm',0,0,2,2,1,NULL,NULL,NULL,'2025-06-07 08:07:33',NULL,NULL,7),(3,'javiers','$2b$10$/cqTzSocLHuITxi4Cg3hwuu8D03aGr6.KTCwE3pPnfD6YBLTtQcWq',0,0,2,1,0,'::1',NULL,NULL,'2025-06-07 08:18:52',NULL,NULL,8),(4,'kellyn.castillo121','$2b$10$dGTb1qAG1t7SiUalGyKkaum3Creolx3.qdEQCYfrJfdqGRw2i8HjW',1,0,1,1,1,NULL,NULL,NULL,'2025-06-08 12:11:25',NULL,NULL,9),(5,'admin.lord801','$2b$10$AmSNyP9pEiLax6sUNfeuYuKcguDwgPYjnzgwa78LxFvTzrHYm9fme',1,0,1,1,1,NULL,NULL,NULL,'2025-06-08 12:14:41',NULL,NULL,10),(6,'javiers','$2b$10$epNqTgUnbWtHGsqjTr49LeZysAWr3eVjI2wkRUT3B3H.DL7BGxoqm',1,0,1,1,1,NULL,NULL,NULL,'2025-06-08 12:26:11',NULL,NULL,11),(7,'kellyn.castillo333','$2b$10$HwaV2kDHQe6DlFP8gDZLEehC5iKtLL0Rlg84ldHN136MNoXBu9iFa',1,0,1,1,0,'::1',NULL,NULL,'2025-06-08 13:56:06',NULL,NULL,12),(8,'javiers','$2b$10$0BIrzFKUDcmpaC5u7onkGul4Z3FgsQCS/JI16/N9O8TDqDlvO7Dmu',1,0,1,1,1,NULL,NULL,NULL,'2025-06-14 18:45:43',NULL,NULL,13),(9,'ya.se.jodio876','$2b$10$VawRySYI2MQGGZXmPH1/NeVgZO8jiF/GYlclsGrAudGuxdikaFz1a',1,0,4,1,1,NULL,NULL,NULL,'2025-06-14 18:57:06',NULL,NULL,14),(10,'funxiona.siono151','$2b$10$fA0TPMxG5DVvEpJm1Vip2.0AmNNpW1jixhNE2W1DdtZNT2/gT4cQ6',0,0,1,1,1,NULL,NULL,NULL,'2025-06-14 19:21:16',NULL,NULL,15),(11,'ultima.prueba236','$2b$10$1NtXXe3V3adBeq7Xo2aTX.SY33OwDc1ZrOE8qKx78c/vSyIBrUy.K',1,0,1,1,1,NULL,NULL,NULL,'2025-06-14 19:40:51',NULL,NULL,16);
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `verificacion_2fa`
--

DROP TABLE IF EXISTS `verificacion_2fa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `verificacion_2fa` (
  `cod_usuario` int NOT NULL,
  `codigo` varchar(6) DEFAULT NULL,
  `expira` datetime DEFAULT NULL,
  PRIMARY KEY (`cod_usuario`),
  CONSTRAINT `verificacion_2fa_ibfk_1` FOREIGN KEY (`cod_usuario`) REFERENCES `usuarios` (`cod_usuario`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `verificacion_2fa`
--

LOCK TABLES `verificacion_2fa` WRITE;
/*!40000 ALTER TABLE `verificacion_2fa` DISABLE KEYS */;
INSERT INTO `verificacion_2fa` VALUES (1,'245564','2025-06-15 01:02:04'),(3,'165400','2025-06-07 08:58:58'),(7,'500816','2025-06-10 10:30:57');
/*!40000 ALTER TABLE `verificacion_2fa` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-06-15  0:59:41
