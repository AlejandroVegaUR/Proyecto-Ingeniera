
def vuelo_hora():
    return """  SELECT EXTRACT('hour' FROM fecha_llegada ) hora_llegada, COUNT(*) total
                FROM Vuelo
                GROUP BY EXTRACT('hour' FROM fecha_llegada )
                ORDER BY hora_llegada ASC;"""
def vuelo_tickets():
    return """SELECT id_vuelo, COUNT(*) num_tickets
              FROM tickets
              GROUP BY id_vuelo;"""
def num_aviones():
    return """  SELECT nombre as aerolinea, COUNT(*) num_aviones
                FROM aviones 
                NATURAL JOIN aerolineas
                GROUP BY nombre;"""
def nacionalidad_asc():
    return """SELECT nacionalidad , COUNT(*) total
                FROM pasajeros 
                NATURAL JOIN tickets GROUP BY nacionalidad ORDER BY total asc LIMIT 20"""
def nacionalidad():
    return """SELECT nacionalidad , COUNT(*) total
                FROM pasajeros 
                NATURAL JOIN tickets GROUP BY nacionalidad ORDER BY total desc LIMIT 20"""


def modelos():
    return """				
            SELECT nombre,COUNT(*) total
            FROM  aviones natural JOIN modelos group by nombre;"""
def mapa():
    return """
   select codigo_pais, count(*) as total
from vuelo natural join aeropuertos  group by (codigo_pais);
    """