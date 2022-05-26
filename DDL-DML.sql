--DDL
CREATE TABLE marcas(
	id_marca int PRIMARY KEY,
	nombre varchar(80) NOT NULL
);

CREATE TABLE pasajeros(
	id_pasajero int PRIMARY KEY,
	nombre varchar(80) NOT NULL,
	apellido varchar(80) NOT NULL,
	nacionalidad varchar(80),
	fecha_nacimiento date NOT NULL
);

CREATE TABLE modelos(
	id_modelo int PRIMARY KEY,
	nombre varchar(80) NOT NULL,
	marca INT,
	FOREIGN KEY (marca) REFERENCES marcas(id_marca)
);

CREATE TABLE aerolineas(
	ID_aerolinea INT PRIMARY KEY,
  	nombre VARCHAR(80) NOT NULL
);

CREATE TABLE aeropuertos(
	ID_aeropuerto INT PRIMARY KEY, 
  	nombre varchar(80) NOT NULL,
  	ciudad VARCHAR(80) NOT NULL
);

CREATE TABLE aviones(
	ID_avion INT PRIMARY KEY,
  	ID_modelo int,
  	ID_aerolinea INT,
  	FOREIGN KEY(ID_aerolinea) REFERENCES aerolineas(ID_aerolinea),
	FOREIGN KEY(ID_modelo) REFERENCES modelos(id_modelo)
);

CREATE TABLE vuelo(
	id_vuelo VARCHAR(80) PRIMARY KEY,
	id_avion INT,
	id_aeropuerto INT,
	fecha_llegada timestamp NOT NULL,
	fecha_salida TIMESTAMP NOT NULL,
	FOREIGN KEY (id_avion) REFERENCES aviones(ID_avion),
	FOREIGN KEY (id_aeropuerto) REFERENCES aeropuertos(ID_aeropuerto)
);

CREATE TABLE tickets(
	id_ticket int PRIMARY KEY,
	id_pasajero INT,
	id_vuelo VARCHAR(80),
	FOREIGN KEY (id_pasajero) REFERENCES pasajeros(id_pasajero),
	FOREIGN KEY (id_vuelo) REFERENCES vuelo(id_vuelo)
);

CREATE TABLE empleados(
	id_empleado INT PRIMARY KEY,
	nombre VARCHAR(80) NOT NULL,
	apellido  VARCHAR(80) NOT NULL,
	rol  VARCHAR(80) NOT NULL,
	id_jefe smallint, 
	id_aerolinea smallint REFERENCES aerolineas(id_aerolinea)
);

CREATE TABLE salarios(
	id_empleado INT PRIMARY KEY REFERENCES empleados(id_empleado), 
	salario REAL

);
/*
DROP table tickets;
DROP  table vuelo;
DROP  TABLE Aviones;
DROP TABLE Aeropuertos;
DROP  TABLE Aerolineas;
DROP  table modelos;
DROP table pasajeros;
DROP table marcas;
DROP table empleados;
DROP table salarios;
*/





--DML

COPY aeropuertos FROM 'pegue aqui su direccion de memoria\Aeropuerto.csv' HEADER CSV DELIMITER ';';
COPY marcas FROM 'pegue aqui su direccion de memoria\marcas.csv' HEADER CSV DELIMITER ';';
COPY modelos FROM 'pegue aqui su direccion de memoria\modelos.csv' HEADER CSV DELIMITER ';';
COPY aerolineas FROM 'pegue aqui su direccion de memoria\aerolineas.csv' HEADER CSV DELIMITER ';';
COPY pasajeros FROM 'pegue aqui su direccion de memoria\pasajeros.csv' HEADER CSV DELIMITER ';';
COPY aviones FROM 'pegue aqui su direccion de memoria\aviones.csv' HEADER CSV DELIMITER ';';
COPY vuelo FROM 'pegue aqui su direccion de memoria\vuelos.csv' HEADER CSV DELIMITER ';';
COPY tickets FROM 'pegue aqui su direccion de memoria\tickets.csv' HEADER CSV DELIMITER ';';
COPY Empleados FROM 'pegue aqui su direccion de memoria\empleado.csv' HEADER CSV DELIMITER ';';
COPY salarios FROM 'pegue aqui su direccion de memoria\salarios.csv' HEADER CSV DELIMITER ';';
