/*
Documentación de los cargos:https://www.cesurformacion.com/blog/los-7-puestos-de-trabajo-en-un-aeropuerto-mas-relevantes
*/
CREATE ROLE Tecnico_administrativo with login;
GRANT SELECT,INSERT,DELETE,UPDATE ON ALL TABLES IN SCHEMA PUBLIC TO Tecnico_administrativo with GRANT OPTION;

CREATE ROLE Tecnico_Operaciones_aeroportuarias with login;
GRANT SELECT,INSERT,DELETE,UPDATE on public.tickets,public.vuelo,public.pasajeros to Tecnico_Operaciones_aeroportuarias;

CREATE ROLE Auxiliar_tierra with login;
GRANT SELECT ON public.tickets,public.vuelo,public.pasajeros to Auxiliar_tierra;

CREATE USER TOA1 with login PASSWORD 'TOA1' IN ROLE Tecnico_Operaciones_aeroportuarias;

CREATE USER Tecni_admi1 PASSWORD 'tecadmi' IN ROLE Tecnico_administrativo;

CREATE USER aux1 PASSWORD 'aux1' IN ROLE Auxiliar_tierra;

--Se busca conocer todos los modelos de aviones
CREATE VIEW Modelos_aviones AS
SELECT F.id_avion,X.nombre marca, F.referencia, F.id_modelo,F.aerolinea
FROM 
(SELECT M.id_avion,A.nombre aerolinea,M.nombre referencia,M.marca id_marca, M.id_modelo
FROM 
(SELECT *
FROM modelos M
NATURAL JOIN aviones A) M
INNER JOIN 
aerolineas A
on A.id_aerolinea = M.id_aerolinea) F
INNER JOIN marcas X
ON F.id_marca = X.id_marca;

-- El gerente quiere saber el nombre de las aerolineas
CREATE VIEW nom_aerolineas
AS
SELECT nombre FROM Aerolineas;

--La gerencia busca saber la información completa de cada pasajero: nombres ticketes de vuelo, aeropuerto, datos del pasajero
CREATE VIEW Pasajeros_vuelos AS 

SELECT p.id_pasajero,p.id_ticket, P.nombre nombre_pasajero, P.apellido apellido_pasajero, P.id_vuelo, V.id_aeropuerto, V.nombre aeropuerto,V.fecha_salida, V.fecha_llegada  --V.nombre,V.
FROM 
(SELECT * 
FROM vuelo
NATURAL JOIN aeropuertos) AS V
INNER JOIN 
(SELECT * 
FROM pasajeros 
NATURAL JOIN tickets) AS P
ON V.id_vuelo = P.id_vuelo;
--Se busca conocer la información de vuelo de los pasajeros(ticketes) y la información del cliente(id,nombre, apellido, nacionalidad)
CREATE VIEW nacionalidad_pasajeros AS 
SELECT p.id_pasajero,p.id_ticket, P.nombre nombre_pasajero, P.apellido apellido_pasajero, P.nacionalidad 
FROM 
(SELECT * 
FROM vuelo
NATURAL JOIN aeropuertos) AS V
INNER JOIN 
(SELECT * 
FROM pasajeros 
NATURAL JOIN tickets) AS P
ON V.id_vuelo = P.id_vuelo;


-- Se necesita saber cual es la aerolinea con mas vuelos, es decir, un ranking de las aerolinea basado en el numero de vuelos

SELECT P.nombre, Count(*), dense_rank() over(order by count(nombre)
			desc) as s_rank 
FROM 
(SELECT * 
FROM aerolineas A
INNER JOIN aviones V
ON A.id_aerolinea = V.id_aerolinea) AS P 
INNER JOIN vuelo F
on P.id_avion = F.id_avion
GROUP BY P.nombre;


-- La gerencia quiere dar un reconociemiento a las personas que mas han viajado. Así pues, se precisa un ranking de los viajeros con mas tickets de vuelo 

SELECT id_pasajero,nombre_pasajero, count(*) num_tickets, DENSE_RANK() OVER (ORDER BY count(nombre_pasajero) DESC) as rank
FROM Pasajeros_vuelos
GROUP BY  id_pasajero,nombre_pasajero

-- Para un programa de incentivos de parte del departamento de marketing, se busca establecer una jerarquia en el numero de viajeros por nacionalidad.

SELECT nacionalidad, count(*),  DENSE_RANK() OVER (ORDER BY count(nacionalidad) DESC) as rank
FROM nacionalidad_pasajeros 
GROUP BY nacionalidad


--Se necesita almacenar la información de los cambios efectuados al número de vuelo de un viajero y la fecha en la que se realizó el cambio
 drop table if exists tr_1;
 create table tr_1(
 	id_ticket int PRIMARY KEY,
	id_pasajero INT,
	id_vuelo_anterior VARCHAR(80),
	id_vuelo_nuevo VARCHAR(80),
	fecha_cambio timestamp
 );
 
 drop function if exists f_tr_1();
 CREATE FUNCTION  f_tr_1() returns Trigger 
 as
 $$
 begin 
 insert into tr_1(id_ticket,id_pasajero, id_vuelo_anterior,id_vuelo_nuevo,fecha_cambio)
 	values(old.id_ticket, old.id_pasajero, old.id_vuelo,new.id_vuelo, now());
 return new; 
 End
 $$
 Language plpgsql;
 
 drop trigger if exists Tr_1 on  tickets;
 create trigger Tr_1 before update on tickets
 for each row
 execute procedure f_tr_1();
 
 select * 
 from tickets;
 update tickets set id_vuelo='WN4239' where id_pasajero=2;
 
 SELECT * 
 FROM tr_1
 
 -- La gerencia considera importante conocer la edad de los viajeros para asi poder crear rankings. 
CREATE OR REPLACE FUNCTION  edad_viajero (id_viajero integer)
RETURNS integer 
AS $$
	DECLARE edad INT;
BEGIN
edad:=(SELECT EXTRACT (YEAR FROM AGE(fecha_nacimiento) ) 
FROM pasajeros
WHERE id_pasajero = id_viajero);

return edad;
end;
$$
language 'plpgsql';

SELECT * FROM edad_viajero(1); 


--Se necesita almacenar la información de los cambios efectuados a la hora de llegada de los vuelos y evidenciar el retraso desde la última fecha en horas
 drop table if exists tr_2;
 create table tr_2(
 	id_vuelo VARCHAR(80),
	id_avion INT,
	id_aeropuerto INT,
	fecha_llegada timestamp,
	anterior_fecha_llegada timestamp,
	retraso int
	
 );
  drop trigger if exists Tr_2 on  vuelo;
 drop function if exists f_tr_2();
 CREATE FUNCTION  f_tr_2() returns Trigger 
 as
 $$
 begin 
 insert into tr_2(id_vuelo,id_avion , id_aeropuerto,fecha_llegada,anterior_fecha_llegada,retraso)
 	values(old.id_vuelo, old.id_avion, old.id_aeropuerto,new.fecha_llegada,old.fecha_llegada,EXTRACT('hour' FROM new.fecha_llegada)-EXTRACT('hour' FROM old.fecha_llegada));
 return new; 
 End
 $$
 Language plpgsql;
 

 create trigger Tr_2 before update on vuelo
 for each row
 execute procedure f_tr_2();
 

 update vuelo set fecha_llegada='2022-04-06 23:30:00' where id_vuelo='WN4239';

 
 select * from tr_2; 

-- Se quiere saber la cantidad de vuelos que llegan por hora 
SELECT EXTRACT('hour' FROM fecha_llegada ) hora_llegada, COUNT(*) total
FROM Vuelo
GROUP BY EXTRACT('hour' FROM fecha_llegada )
ORDER BY hora_llegada ASC;


--Se desea conocer la cantidad de tiquetes por vuelo para asi evitar el overbooking
SELECT id_vuelo, COUNT(*) num_tickets
FROM tickets
GROUP BY id_vuelo;

--Cantidad de aviones por aerolinea 
SELECT nombre, COUNT(*)
FROM aviones 
NATURAL JOIN aerolineas
GROUP BY nombre;

--Consultas sobre los empleados

--todos los empleados de lufthansa
CREATE VIEW empleados_lufthansa AS
SELECT * FROM empleados NATURAL JOIN salarios
WHERE id_aerolinea = 9820;

SELECT * FROM empleados_lufthansa 

--todos los empleados de singapore
CREATE VIEW empleados_singapore AS
SELECT * FROM empleados NATURAL JOIN salarios
WHERE id_aerolinea = 2343;

SELECT * FROM empleados_singapore;

--todos los empleados de qatar
CREATE VIEW empleados_qatar AS
SELECT * FROM empleados NATURAL JOIN salarios
WHERE id_aerolinea = 8964;

SELECT * FROM empleados_qatar;

--todos los empleados de nipon
CREATE VIEW empleados_nipon AS
SELECT * FROM empleados NATURAL JOIN salarios
WHERE id_aerolinea = 1234;

SELECT * FROM empleados_nipon;

--Promedio de salario por cargo 
SELECT rol, ROUND( AVG( salario )::numeric, 2 ) avg_rental
FROM empleados E
JOIN salarios S
ON E.id_empleado =S.id_empleado
GROUP BY rol
ORDER BY avg_rental DESC;

--transacciones

-- En retribución a su gran trabajo, la aerolinea lufthansa ha decidido aumentar en un millón de pesos el salario de Keith craig 
BEGIN; 

UPDATE salarios
SET salario = salario +10000000
WHERE id_empleado = 4878;

--cometimos un error y aumentamos el salario en 10 millones en vez de 1 millón
ROLLBACK;

--iniciamos la transaccion nuevamente
BEGIN; 
UPDATE salarios
SET salario = salario +1000000
WHERE id_empleado = 4878;

COMMIT;

--Se busca el cambio de la fecha de llegada del vuelo WN4239 debido al retraso en la salida de 2 horas
BEGIN; 
UPDATE vuelo
SET fecha_salida = '2022-06-04 10:30:00'
WHERE id_vuelo = 'WN4239';

COMMIT;
BEGIN; 
UPDATE vuelo
SET fecha_llegada = '2022-06-04 13:30:00'
WHERE id_vuelo = 'WN4239';

COMMIT;

--consultas recursivas sobre empleados

--todos los empleados de Jeremy Hughes
with recursive subordinados
	as(

		select id_jefe, id_empleado, nombre, apellido 
		from Empleados 
		where id_empleado = 3866
		union 
		select e.id_jefe, e.id_empleado, e.nombre, e.apellido
		from Empleados e
		inner join subordinados s on s.id_empleado = e.id_jefe

	)
select * from subordinados;

--todos los empleados de Brett Castro
with recursive subordinados
	as(

		select id_jefe, id_empleado, nombre, apellido 
		from Empleados 
		where id_empleado = 1942
		union 
		select e.id_jefe, e.id_empleado, e.nombre, e.apellido
		from Empleados e
		inner join subordinados s on s.id_empleado = e.id_jefe

	)
select * from subordinados;

--todos los empleados de Collin Odom
with recursive subordinados
	as(

		select id_jefe, id_empleado, nombre, apellido 
		from Empleados 
		where id_empleado = 1895
		union 
		select e.id_jefe, e.id_empleado, e.nombre, e.apellido
		from Empleados e
		inner join subordinados s on s.id_empleado = e.id_jefe

	)
select * from subordinados;

--todos los empleados de Jennifer Lloyd
with recursive subordinados
	as(

		select id_jefe, id_empleado, nombre, apellido 
		from Empleados 
		where id_empleado = 1855
		union 
		select e.id_jefe, e.id_empleado, e.nombre, e.apellido
		from Empleados e
		inner join subordinados s on s.id_empleado = e.id_jefe

	)
select * from subordinados;

--todos los empleados de Jessica Morales
with recursive subordinados
	as(

		select id_jefe, id_empleado, nombre, apellido 
		from Empleados 
		where id_empleado = 3550
		union 
		select e.id_jefe, e.id_empleado, e.nombre, e.apellido
		from Empleados e
		inner join subordinados s on s.id_empleado = e.id_jefe
select * from empleados
	)
select * from subordinados;