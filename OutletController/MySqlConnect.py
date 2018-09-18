from mysql.connector import MySQLConnection, Error
from readDbConfig import readDbConfig

def connect():
    """ Connect to MySQL database """

    dbConfig = readDbConfig()

    try:
        print('Connecting to MySQL database...')
        conn = MySQLConnection(**dbConfig)
        if(conn.is_connected()):
           print('Connected to database')
           return conn
        else:
            print('Failed to connect to database')
    except Error as error:
        print(error)