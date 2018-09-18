import MySqlConnect
import os.path
import re
import subprocess
import logging
import datetime
from configparser import ConfigParser
from mysql.connector import MySQLConnection, Error

def connect():
    """ Connect to MySQL database """

    dbConfig = readDbConfig()

    try:
        logging.debug('Connecting to MySQL database...')
        conn = MySQLConnection(**dbConfig)
        if(conn.is_connected()):
           logging.debug('Connected to database')
           return conn
        else:
            logging.debug('Failed to connect to database')
    except Error as error:
        logging.debug(error)

def readDbConfig(filename='/usr/local/bin/OutletController/config.ini',section='mysql'):
    """ Read database configuration file and return a dictionary object
    :param filename: name of the configuration file
    :param section: section of database configuration
    :return: a dictionary of database parameters
    """
    #create a parser and read ini configuration file
    parser = ConfigParser()
    parser.read(filename)

    #get section, default to mysql
    db = {}
    if parser.has_section(section):
        items = parser.items(section);
        for item in items:
            db[item[0]]=item[1]
    else:
        raise Exception('{0} not found in the {1} file'.format(section,filename))
    return db

def sendCode(code:int):
    try:
        logging.debug("Sending code {0}".format(code))
        procArgs = ("/home/pi/OutletController/codesend",code)
        popen = subprocess.Popen(procArgs)
        popen.wait()
    except:
        logging.exception("Send Code Exception")
        raise
def logSensor(cursor,conn:MySQLConnection,sensorId:int,sensorTemp:int,outletSetting:int,outletId:int):
    
    logging.debug("logSensor")
    try:
        args = [sensorId,sensorTemp,outletSetting,outletId]
        result_args = cursor.callproc("LogSensor",args)
        conn.commit()
    except:
        logging.exception("logSensor Exception")
        raise
try:
    logging.basicConfig(filename="/tmp/outlet.log",level=logging.ERROR,format='%(asctime)s %(message)s')
    path = "/sys/bus/w1/devices/"
    crcPattern = re.compile("^([a-f0-9]{2} ){9}: crc=[a-f0-9]{2} YES$")
    tempPattern = re.compile(r"^([a-f0-9]{2} ){9}t=(\d+)$")
    conn = connect()
    cursor = conn.cursor()
    cursor.execute('SELECT Sensors.Id,Sensors.Serial,Sensors.SetTemperature,Outlets.Id,Outlets.OnCode,Outlets.OffCode FROM Sensors JOIN Outlets ON Outlets.Id=Sensors.OutletId WHERE Sensors.Monitor=1')
    rows = list(cursor)
    sensors = []
    for (sensorId,serial,setTemperature,outletId,onCode,offCode) in rows:
        #check for the file
        fullFilePath = "{0}{1}/w1_slave".format(path,serial)
        outletState = -1
        success=False
        log=False
        sensorTemp=999999999
        if (os.path.isfile(fullFilePath)):
            with open(fullFilePath) as file:
                logging.debug("reading file {0}".format(fullFilePath))
                lines = file.readlines()
                if(crcPattern.match(lines[0])):
                    tempMatch = tempPattern.match(lines[1])
                if(tempMatch):
                    logging.debug("Successfully read temp")
                    sensorTemp = int(tempMatch.group(2))
                    logging.debug("Sensor {0} is at {1}".format(sensorId,sensorTemp))
                    if (sensorTemp>=setTemperature-500):
                        outletState=0
                    elif (sensorTemp<setTemperature-500):
                        outletState=1
                    success=True
                else:
                    logging.debug("failed to read sensor temp")
        else:
            #file does not exist
            logging.debug("File {0} does not exist, sending off code")
        if(success):
            logging.debug("Successfully read sensor data for {0}".format(sensorId))
            if(outletState==1):
                log=True
                sendCode(onCode)
            elif(outletState==0):
                log=True
                sendCode(offCode)
        else:
            logging.error("Failed to read sensor data for {0}".format(sensorId))
            sendCode(offCode)
        if(outletState==-1):
            outletState=0
        #we only want to log every 5 minutes
        minutes = datetime.datetime.now().minute
        if((minutes%5==0) or log):
            logging.debug("{0} is divisible by 5, logging".format(minutes))
            logSensor(cursor,conn,sensorId,sensorTemp,outletState,outletId)
        else:
            logging.debug("{0} is not divisible by 5, skipping logging".format(minutes))
    #for (sensorId,serial,setTemperature,outletId,onCode,offCode) in rows:
    #    #check for file
    #    logging.debug("checking for file: " + path+serial+"/w1_slave "+str(os.path.isfile(path+serial+"/w1_slave")))
    #    if (os.path.isfile(path+serial+"/w1_slave")):
    #        #read in the file
    #        with open(path+serial+"/w1_slave") as file:
    #            logging.debug("reading file {0}{1}/w1_slave".format(path,serial))
    #            lines = file.readlines()
    #            #if we have a good CRC
    #            if(crcPattern.match(lines[0])):
    #                tempMatch = tempPattern.match(lines[1])
    #            #if we have a temp
    #            if(tempMatch):
    #                sensorTemp = int(tempMatch.group(2))
    #                outletSetting = 0 #default to off
    #                logging.debug("Sensor {0} is at {1}".format(sensorId,sensorTemp))
    #                if (sensorTemp>=setTemperature):
    #                    outletSetting = 0
    #                    logging.debug("Sensor {0} reading is {1} set Temp is at {2}, sending Off Code".format(sensorId,sensorTemp,setTemperature))
    #                    procArgs = ("/home/pi/OutletController/codesend",offCode)
    #                    popen = subprocess.Popen(procArgs)
    #                    popen.wait()
    #                    logging.debug("Calling stored proc {0}".format(args))
    #                elif (sensorTemp<setTemperature-500):
    #                    outletSetting = 1
    #                    logging.debug("Sensor {0} reading is {1} set Temp is at {2}, sending On Code".format(sensorId,sensorTemp,setTemperature))
    #                    procArgs = ("/home/pi/OutletController/codesend",onCode)
    #                    popen = subprocess.Popen(procArgs)
    #                    popen.wait()
    #                logging.debug("Logging sensor {0}".format(args))
    #                args = [sensorId,sensorTemp,outletSetting,outletId]
    #                result_args = cursor.callproc("LogSensor",args)
    #                conn.commit()
    #    else:
    #        logging.debug("Path does not exist for {0}".format(serial))
    #        args = [sensorId,-1,outletSetting,outletId]
    #        result_args = cursor.callproc("LogSensor",args)
    #        logging.debug("Unable to locate sensor data, sending offCode")
    #        procArgs = ("/home/pi/OutletController/codesend",offCode)
    #        popen = subprocess.Popen(procArgs)
    #        popen.wait()
    #    logging.debug("Continuing on to next sensor")
except:
    logging.exception("Unknown exception")
    raise
finally:
    conn.commit()
    cursor.close()
    conn.close()

