CREATE DATABASE IF NOT EXISTS tacomanda
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE tacomanda;

CREATE TABLE empleados (
  no_control INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  telefono VARCHAR(13),
  contrasena VARCHAR(255) NOT NULL,
  tipo_empleado ENUM('mesero','cajero','admin') NOT NULL
);

CREATE TABLE mesas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  numero INT NOT NULL,
  estado ENUM('libre','ocupada','reservada') NOT NULL DEFAULT 'libre'
);

CREATE TABLE platillos (
  id_platillo INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL,
  categoria VARCHAR(25),
  descripcion VARCHAR(100),
  precio DECIMAL(8,2) NOT NULL,
  emoji VARCHAR(8) NOT NULL DEFAULT '🌮',
  activo TINYINT(1) NOT NULL DEFAULT 1
);

CREATE TABLE productos (
  id_producto INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL
);

CREATE TABLE platillo_producto (
  id_platillo INT NOT NULL,
  id_producto INT NOT NULL,
  cantidad_usada DECIMAL(6,2) NOT NULL DEFAULT 1,
  PRIMARY KEY (id_platillo, id_producto),
  CONSTRAINT fk_pp_platillo FOREIGN KEY (id_platillo) REFERENCES platillos(id_platillo),
  CONSTRAINT fk_pp_producto FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

CREATE TABLE comandas (
  id_comanda INT AUTO_INCREMENT PRIMARY KEY,
  mesa_id INT NOT NULL,
  no_control INT NOT NULL,
  fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  estado ENUM('abierta','en_preparacion','lista','cerrada','cancelada') NOT NULL DEFAULT 'abierta',
  CONSTRAINT fk_comanda_mesa FOREIGN KEY (mesa_id) REFERENCES mesas(id),
  CONSTRAINT fk_comanda_empleado FOREIGN KEY (no_control) REFERENCES empleados(no_control)
);

CREATE TABLE detalle_comanda (
  id_detalle INT AUTO_INCREMENT PRIMARY KEY,
  id_comanda INT NOT NULL,
  id_platillo INT NOT NULL,
  cantidad INT NOT NULL DEFAULT 1,
  nota VARCHAR(100),
  subtotal DECIMAL(8,2) NOT NULL,
  CONSTRAINT fk_detalle_comanda FOREIGN KEY (id_comanda) REFERENCES comandas(id_comanda),
  CONSTRAINT fk_detalle_platillo FOREIGN KEY (id_platillo) REFERENCES platillos(id_platillo)
);

CREATE TABLE pedidos (
  id_pedido INT AUTO_INCREMENT PRIMARY KEY,
  id_comanda INT NOT NULL UNIQUE,
  cambio DECIMAL(8,2) NOT NULL DEFAULT 0,
  tipo_pago VARCHAR(20) NOT NULL,
  tipo_pedido VARCHAR(20) NOT NULL,
  fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_pedido_comanda FOREIGN KEY (id_comanda) REFERENCES comandas(id_comanda)
);

CREATE TABLE encuestas_cierre (
  id_encuesta INT AUTO_INCREMENT PRIMARY KEY,
  no_control INT NOT NULL,
  fecha_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  total_sistema DECIMAL(10,2) NOT NULL,
  total_contado DECIMAL(10,2) NOT NULL,
  diferencia DECIMAL(10,2) NOT NULL,
  hubo_incidencias TINYINT(1) NOT NULL DEFAULT 0,
  comentarios TEXT,
  CONSTRAINT fk_encuesta_empleado FOREIGN KEY (no_control) REFERENCES empleados(no_control)
);

CREATE TABLE retroalimentacion_app (
  id_retro INT AUTO_INCREMENT PRIMARY KEY,
  no_control INT NOT NULL,
  calificacion TINYINT NOT NULL,
  comentario TEXT,
  fecha_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_retro_empleado FOREIGN KEY (no_control) REFERENCES empleados(no_control),
  CONSTRAINT chk_retro_calificacion CHECK (calificacion BETWEEN 1 AND 5)
);

INSERT INTO mesas (numero, estado) VALUES
 (1,'libre'), (2,'libre'), (3,'libre'), (4,'libre'), (5,'libre');

INSERT INTO productos (nombre) VALUES
 ('Tortilla de maíz'), ('Carne al pastor'), ('Piña'), ('Cebolla'),
 ('Cilantro'), ('Bistec'), ('Queso'), ('Masa para gordita'),
 ('Refresco de cola'), ('Agua de horchata'), ('Café'), ('Leche condensada');

INSERT INTO platillos (nombre, categoria, descripcion, precio, emoji, activo) VALUES
 ('Taco al pastor', 'tacos', 'Piña, cilantro, cebolla', 25.00, '🌮', 1),
 ('Taco de bistec', 'tacos', 'Cebolla, salsa verde', 28.00, '🌮', 1),
 ('Quesadilla', 'extras', 'Queso Oaxaca + relleno', 45.00, '🧀', 1),
 ('Gordita', 'extras', 'Con chicharrón o frijol', 35.00, '🫔', 1),
 ('Refresco', 'bebidas', 'Lata 355ml', 18.00, '🥤', 1),
 ('Agua fresca', 'bebidas', 'Jamaica, horchata, limón', 20.00, '🥤', 1),
 ('Café de olla', 'bebidas', 'Canela y piloncillo', 22.00, '☕', 1),
 ('Flan napolitano', 'postres', 'Caramelo, receta casera', 35.00, '🍮', 1);

INSERT INTO platillo_producto (id_platillo, id_producto, cantidad_usada) VALUES
 (1, 1, 2), (1, 2, 1), (1, 3, 1), (1, 4, 1), (1, 5, 1),
 (2, 1, 2), (2, 6, 1), (2, 4, 1),
 (5, 9, 1),
 (7, 11, 1);
