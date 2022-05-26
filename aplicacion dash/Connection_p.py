import psycopg2


class Connection:

    def __init__(self):
        self.connection = None

    def openConnection(self):
        try:
            self.connection = psycopg2.connect(user="postgres",
                                               password="Ingresar su clave aqui",
                                               database="proyecto_ing",
                                               host="localhost",
                                               port="5432")
        except Exception as e:
            print(e)

    def closeConnection(self):
        self.connection.close()
