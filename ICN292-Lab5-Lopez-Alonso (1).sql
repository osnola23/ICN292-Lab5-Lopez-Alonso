-- ============================================================
-- ICN-292 Sistemas de Informacion para la Gestion - 2026/02
-- Laboratorio 5 - SQL (2/2) - Base andesbike
-- Orden: creacion de tablas, carga oficial y diez consultas
-- Ejecutar de principio a fin sobre una base vacia.
-- ============================================================

DROP DATABASE IF EXISTS andesbike;
CREATE DATABASE andesbike CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE andesbike;

-- ------------------------------------------------------------
-- ENTREGABLE 1: CREACION DE TABLAS
-- ------------------------------------------------------------
CREATE TABLE tiendas (
    id_tienda INT          NOT NULL AUTO_INCREMENT,
    nombre    VARCHAR(60)  NOT NULL,
    comuna    VARCHAR(50)  NOT NULL,
    PRIMARY KEY (id_tienda)
);

CREATE TABLE vendedores (
    id_vendedor   INT          NOT NULL AUTO_INCREMENT,
    nombre        VARCHAR(80)  NOT NULL,
    id_tienda     INT          NULL,
    fecha_ingreso DATE         NOT NULL,
    PRIMARY KEY (id_vendedor),
    CONSTRAINT fk_vendedores_tiendas
        FOREIGN KEY (id_tienda) REFERENCES tiendas (id_tienda)
);

CREATE TABLE bicicletas (
    id_bicicleta INT           NOT NULL AUTO_INCREMENT,
    modelo       VARCHAR(60)   NOT NULL,
    categoria    ENUM('Eléctrica','Infantil','Montaña','Ruta','Urbana') NOT NULL,
    precio       DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_bicicleta),
    CONSTRAINT ck_bicicletas_precio CHECK (precio > 0)
);

CREATE TABLE ventas (
    id_venta     INT  NOT NULL AUTO_INCREMENT,
    id_vendedor  INT  NOT NULL,
    id_bicicleta INT  NOT NULL,
    fecha        DATE NOT NULL,
    unidades     INT  NOT NULL,
    PRIMARY KEY (id_venta),
    CONSTRAINT fk_ventas_vendedores
        FOREIGN KEY (id_vendedor)  REFERENCES vendedores (id_vendedor),
    CONSTRAINT fk_ventas_bicicletas
        FOREIGN KEY (id_bicicleta) REFERENCES bicicletas (id_bicicleta),
    CONSTRAINT ck_ventas_unidades CHECK (unidades > 0)
);

-- ------------------------------------------------------------
-- CARGA OFICIAL: 4 tiendas, 8 vendedores, 8 modelos, 18 ventas
-- ------------------------------------------------------------
INSERT INTO tiendas (id_tienda, nombre, comuna) VALUES
(1, 'Andes Providencia', 'Providencia'),
(2, 'Andes Maipú',       'Maipú'),
(3, 'Andes Concepción',  'Concepción'),
(4, 'Andes La Serena',   'La Serena');

INSERT INTO vendedores (id_vendedor, nombre, id_tienda, fecha_ingreso) VALUES
(1, 'Camila Ortiz',    1,    '2024-06-20'),
(2, 'Diego Fuentes',   1,    '2024-01-15'),
(3, 'Javiera Soto',    2,    '2023-07-24'),
(4, 'Matías Herrera',  2,    '2024-01-15'),
(5, 'Paula Riquelme',  3,    '2022-11-02'),
(6, 'Ignacio Vera',    3,    '2024-08-19'),
(7, 'Fernanda Lillo',  1,    '2025-02-03'),
(8, 'Rubén Castro',    NULL, '2025-06-10');

INSERT INTO bicicletas (id_bicicleta, modelo, categoria, precio) VALUES
(1, 'Cordillera 29', 'Montaña',    549990.00),
(2, 'Ruta Austral',  'Ruta',       899990.00),
(3, 'Urbana Pro',    'Urbana',     329990.00),
(4, 'Pequeño Andes', 'Infantil',   149990.00),
(5, 'Volt City',     'Eléctrica', 1249990.00),
(6, 'Trail Master',  'Montaña',    749990.00),
(7, 'Urbana Lite',   'Urbana',     229990.00),
(8, 'Sprint R7',     'Ruta',      1099990.00);

INSERT INTO ventas (id_venta, id_vendedor, id_bicicleta, fecha, unidades) VALUES
( 1, 1, 1, '2025-03-04', 2),
( 2, 1, 3, '2025-03-18', 1),
( 3, 1, 5, '2025-04-02', 1),
( 4, 2, 2, '2025-03-04', 1),
( 5, 2, 1, '2025-04-11', 3),
( 6, 2, 7, '2025-05-06', 2),
( 7, 3, 4, '2025-03-21', 4),
( 8, 3, 3, '2025-04-15', 2),
( 9, 3, 6, '2025-05-20', 1),
(10, 4, 1, '2025-03-27', 1),
(11, 4, 5, '2025-05-09', 2),
(12, 5, 2, '2025-04-08', 1),
(13, 5, 6, '2025-04-23', 2),
(14, 5, 4, '2025-06-02', 5),
(15, 6, 3, '2025-05-13', 3),
(16, 6, 7, '2025-06-17', 1),
(17, 6, 1, '2025-06-24', 2),
(18, 1, 6, '2025-06-30', 1);

-- Verificacion de la carga (18 ventas, 35 unidades, monto 16.969.650)
SELECT COUNT(*) AS ventas, SUM(v.unidades) AS unidades,
       SUM(v.unidades * b.precio) AS monto_total
FROM ventas v JOIN bicicletas b ON b.id_bicicleta = v.id_bicicleta;

-- ------------------------------------------------------------
-- ENTREGABLE 2: CONSULTAS
-- ------------------------------------------------------------

-- Consulta 1: vendedores con su cantidad de ventas (incluye los sin ventas)
SELECT ve.nombre, COUNT(v.id_venta) AS cantidad_ventas
FROM vendedores ve
LEFT JOIN ventas v ON v.id_vendedor = ve.id_vendedor
GROUP BY ve.id_vendedor, ve.nombre
ORDER BY cantidad_ventas DESC, ve.nombre;

-- Consulta 2: por tienda, ventas y unidades (incluye tiendas sin vendedores)
SELECT t.nombre,
       COUNT(v.id_venta)             AS ventas,
       COALESCE(SUM(v.unidades), 0)  AS unidades
FROM tiendas t
LEFT JOIN vendedores ve ON ve.id_tienda   = t.id_tienda
LEFT JOIN ventas v      ON v.id_vendedor  = ve.id_vendedor
GROUP BY t.id_tienda, t.nombre
ORDER BY unidades DESC;

-- Consulta 3: tiendas sin ningun vendedor asignado
SELECT t.id_tienda, t.nombre, t.comuna
FROM tiendas t
LEFT JOIN vendedores ve ON ve.id_tienda = t.id_tienda
WHERE ve.id_vendedor IS NULL;

-- Consulta 4: modelos que no se vendieron en junio de 2025
SELECT b.modelo
FROM bicicletas b
LEFT JOIN ventas v
       ON v.id_bicicleta = b.id_bicicleta
      AND v.fecha >= '2025-06-01' AND v.fecha < '2025-07-01'
WHERE v.id_venta IS NULL
ORDER BY b.modelo;
-- Respuesta: la condicion del mes va en el ON del LEFT JOIN (no en el WHERE),
-- para que el modelo sin ventas en junio conserve su fila con NULL; si el
-- filtro de fecha estuviera en el WHERE, descartaria esas filas NULL y la
-- consulta devolveria cero filas (o solo los modelos que si se vendieron).

-- Consulta 5: vendedores sin ventas, con el nombre de su tienda
-- (LEFT JOIN tambien hacia tiendas: Ruben Castro no tiene tienda)
SELECT ve.nombre AS vendedor, t.nombre AS tienda
FROM vendedores ve
LEFT JOIN ventas v   ON v.id_vendedor = ve.id_vendedor
LEFT JOIN tiendas t  ON t.id_tienda   = ve.id_tienda
WHERE v.id_venta IS NULL
ORDER BY ve.nombre;

-- Consulta 6: pares de vendedores de la misma tienda (primero el de ingreso anterior)
-- Las fechas se devuelven como texto AAAA-MM-DD (DATE_FORMAT) para que el
-- cliente no les aplique conversion de zona horaria al mostrarlas.
SELECT a.nombre AS vendedor_antiguo,
       DATE_FORMAT(a.fecha_ingreso, '%Y-%m-%d') AS ingreso_antiguo,
       b.nombre AS vendedor_nuevo,
       DATE_FORMAT(b.fecha_ingreso, '%Y-%m-%d') AS ingreso_nuevo,
       t.nombre AS tienda
FROM vendedores a
JOIN vendedores b
  ON a.id_tienda = b.id_tienda
 AND (a.fecha_ingreso < b.fecha_ingreso
      OR (a.fecha_ingreso = b.fecha_ingreso AND a.id_vendedor < b.id_vendedor))
JOIN tiendas t ON t.id_tienda = a.id_tienda
ORDER BY t.nombre, a.fecha_ingreso, b.fecha_ingreso;

-- Consulta 7: monto por tienda en categorias Montaña y Ruta, solo > 2.000.000
SELECT t.nombre, SUM(v.unidades * b.precio) AS monto_total
FROM tiendas t
JOIN vendedores ve ON ve.id_tienda    = t.id_tienda
JOIN ventas v      ON v.id_vendedor   = ve.id_vendedor
JOIN bicicletas b  ON b.id_bicicleta  = v.id_bicicleta
WHERE b.categoria IN ('Montaña', 'Ruta')
GROUP BY t.id_tienda, t.nombre
HAVING SUM(v.unidades * b.precio) > 2000000
ORDER BY monto_total DESC;

-- Consulta 8: bicicletas con precio sobre el promedio del catalogo
SELECT modelo, precio
FROM bicicletas
WHERE precio > (SELECT AVG(precio) FROM bicicletas)
ORDER BY precio DESC;
-- Respuesta: el promedio del catalogo es 657.490,00; se obtiene con la
-- subconsulta (SELECT AVG(precio) FROM bicicletas) sobre las 8 bicicletas
-- (5.259.920 / 8).

-- Consulta 9: vendedores cuyo promedio de unidades por venta supera el de la cadena
SELECT ve.nombre, AVG(v.unidades) AS promedio_unidades
FROM vendedores ve
JOIN ventas v ON v.id_vendedor = ve.id_vendedor
GROUP BY ve.id_vendedor, ve.nombre
HAVING AVG(v.unidades) > (SELECT AVG(unidades) FROM ventas)
ORDER BY promedio_unidades DESC, ve.nombre;

-- Consulta 10: monto total por vendedor (incluye los que no vendieron)
SELECT ve.nombre, SUM(v.unidades * b.precio) AS monto_total
FROM vendedores ve
LEFT JOIN ventas v     ON v.id_vendedor  = ve.id_vendedor
LEFT JOIN bicicletas b ON b.id_bicicleta = v.id_bicicleta
GROUP BY ve.id_vendedor, ve.nombre
ORDER BY monto_total DESC, ve.nombre;
-- Respuesta: Fernanda Lillo y Ruben Castro muestran NULL y no 0 porque
-- SUM de un conjunto sin valores (solo NULL del LEFT JOIN) devuelve NULL;
-- habria que envolver la suma con COALESCE(SUM(v.unidades * b.precio), 0).
