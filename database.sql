-- MySQL Script generated by MySQL Workbench
-- 06/15/16 23:02:19
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema TempMonitor
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `TempMonitor` ;

-- -----------------------------------------------------
-- Schema TempMonitor
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `TempMonitor` DEFAULT CHARACTER SET utf8 ;
USE `TempMonitor` ;

-- -----------------------------------------------------
-- Table `TempMonitor`.`Outlets`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `TempMonitor`.`Outlets` ;

CREATE TABLE IF NOT EXISTS `TempMonitor`.`Outlets` (
  `Id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `Name` VARCHAR(255) NOT NULL,
  `OnCode` CHAR(6) NOT NULL,
  `OffCode` CHAR(6) NOT NULL,
  `Active` BIT(1) NULL DEFAULT b'1',
  PRIMARY KEY (`Id`),
  UNIQUE INDEX `OnCode_UNIQUE` (`OnCode` ASC, `Active` ASC),
  UNIQUE INDEX `OffCode_UNIQUE` (`OffCode` ASC, `Active` ASC))
ENGINE = InnoDB
AUTO_INCREMENT = 7
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `TempMonitor`.`Sensors`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `TempMonitor`.`Sensors` ;

CREATE TABLE IF NOT EXISTS `TempMonitor`.`Sensors` (
  `Id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `Name` VARCHAR(255) NOT NULL,
  `Serial` CHAR(15) NOT NULL,
  `Monitor` BIT(1) NOT NULL,
  `OutletId` INT(10) UNSIGNED NULL DEFAULT NULL,
  `SetTemperature` FLOAT NULL DEFAULT NULL,
  `Active` BIT(1) NULL DEFAULT b'1',
  PRIMARY KEY (`Id`),
  UNIQUE INDEX `SensorSerial_UNIQUE` (`Serial` ASC, `Active` ASC),
  UNIQUE INDEX `OutletId_UNIQUE` (`OutletId` ASC, `Active` ASC),
  INDEX `SensorName_INDEX` (`Name` ASC),
  INDEX `fk_Sensors_Outlets_idx` (`OutletId` ASC),
  CONSTRAINT `fk_Sensors_Outlets`
    FOREIGN KEY (`OutletId`)
    REFERENCES `TempMonitor`.`Outlets` (`Id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 6
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `TempMonitor`.`SensorLogs`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `TempMonitor`.`SensorLogs` ;

CREATE TABLE IF NOT EXISTS `TempMonitor`.`SensorLogs` (
  `Id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `TimeStamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Temperature` INT(11) NOT NULL,
  `SensorId` INT(10) UNSIGNED NOT NULL,
  `OutletState` BIT(1) NULL DEFAULT NULL,
  `OutletId` INT(10) UNSIGNED NULL DEFAULT NULL,
  PRIMARY KEY (`Id`),
  INDEX `SensorLogs_TimeStamp` (`TimeStamp` ASC),
  INDEX `fk_SensorLogs_Sensors_idx` (`SensorId` ASC),
  INDEX `fk_SensorLogs_Outlets_idx` (`OutletId` ASC),
  CONSTRAINT `fk_SensorLogs_Outlets`
    FOREIGN KEY (`OutletId`)
    REFERENCES `TempMonitor`.`Outlets` (`Id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_SensorLogs_Sensors`
    FOREIGN KEY (`SensorId`)
    REFERENCES `TempMonitor`.`Sensors` (`Id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 352361
DEFAULT CHARACTER SET = utf8;

USE `TempMonitor` ;

-- -----------------------------------------------------
-- Placeholder table for view `TempMonitor`.`AvailableOutlets`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `TempMonitor`.`AvailableOutlets` (`Id` INT, `Name` INT, `OnCode` INT);

-- -----------------------------------------------------
-- Placeholder table for view `TempMonitor`.`CurrentSensorStates`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `TempMonitor`.`CurrentSensorStates` (`SensorId` INT, `SensorName` INT, `SensorSerial` INT, `Monitor` INT, `OutletId` INT, `OutletName` INT, `OnCode` INT, `OffCode` INT, `SetTemperature` INT, `Temperature` INT, `OutletState` INT, `Timestamp` INT);

-- -----------------------------------------------------
-- Placeholder table for view `TempMonitor`.`RecentSensorReadings`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `TempMonitor`.`RecentSensorReadings` (`SensorId` INT, `Id` INT);

-- -----------------------------------------------------
-- Placeholder table for view `TempMonitor`.`SensorHistorys`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `TempMonitor`.`SensorHistorys` (`Name` INT, `Serial` INT, `Deleted` INT, `TimeStamp` INT, `Temperature` INT, `OutletName` INT, `OutletState` INT);

-- -----------------------------------------------------
-- Placeholder table for view `TempMonitor`.`UsedOutlets`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `TempMonitor`.`UsedOutlets` (`OutletId` INT);

-- -----------------------------------------------------
-- procedure ActivateSensor
-- -----------------------------------------------------

USE `TempMonitor`;
DROP procedure IF EXISTS `TempMonitor`.`ActivateSensor`;

DELIMITER $$
USE `TempMonitor`$$
CREATE DEFINER=`pi`@`%` PROCEDURE `ActivateSensor`(in _sensorId int unsigned)
BEGIN
		UPDATE Sensors
		SET Monitor=1
		WHERE (Sensors.Id=_sensorId);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure AddOutlet
-- -----------------------------------------------------

USE `TempMonitor`;
DROP procedure IF EXISTS `TempMonitor`.`AddOutlet`;

DELIMITER $$
USE `TempMonitor`$$
CREATE DEFINER=`pi`@`%` PROCEDURE `AddOutlet`(in _name varchar(255),in _onCode char(6),in _offCode char(6),out _id int)
BEGIN
	INSERT INTO Outlets (Name,OnCode,OffCode)
    VALUES (_name,_onCode,_offCode);
    SET _id = LAST_INSERT_ID();
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure AddSensor
-- -----------------------------------------------------

USE `TempMonitor`;
DROP procedure IF EXISTS `TempMonitor`.`AddSensor`;

DELIMITER $$
USE `TempMonitor`$$
CREATE DEFINER=`pi`@`%` PROCEDURE `AddSensor`(in _name VARCHAR(255),in _serial CHAR(15),in _monitor bit,in _outletsId int unsigned,in _setTemperature float,out _id int)
BEGIN
	INSERT INTO Sensors (Name,Serial,Monitor,OutletId,SetTemperature)
    VALUES (_name,_serial,_monitor,_outletsId,_setTemperature);
    SET _id = LAST_INSERT_ID();
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure DeactivateSensor
-- -----------------------------------------------------

USE `TempMonitor`;
DROP procedure IF EXISTS `TempMonitor`.`DeactivateSensor`;

DELIMITER $$
USE `TempMonitor`$$
CREATE DEFINER=`pi`@`%` PROCEDURE `DeactivateSensor`(in _sensorId int unsigned)
BEGIN
		UPDATE Sensors
		SET Monitor=0
		WHERE (Sensors.Id=_sensorId);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure DeleteOutlet
-- -----------------------------------------------------

USE `TempMonitor`;
DROP procedure IF EXISTS `TempMonitor`.`DeleteOutlet`;

DELIMITER $$
USE `TempMonitor`$$
CREATE DEFINER=`pi`@`%` PROCEDURE `DeleteOutlet`(in _outletId smallint unsigned)
BEGIN
    UPDATE Sensors
    SET OutletId=NULL
    WHERE 
		(OutletId=_outletId);
	UPDATE Outlets 
    SET Active = NULL
	WHERE
		Id = _outletId;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure DeleteSensor
-- -----------------------------------------------------

USE `TempMonitor`;
DROP procedure IF EXISTS `TempMonitor`.`DeleteSensor`;

DELIMITER $$
USE `TempMonitor`$$
CREATE DEFINER=`pi`@`%` PROCEDURE `DeleteSensor`(in _sensorId int unsigned)
BEGIN
		UPDATE Sensors
        SET Active=NULL
        WHERE (Id=_sensorID);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GetOutlet
-- -----------------------------------------------------

USE `TempMonitor`;
DROP procedure IF EXISTS `TempMonitor`.`GetOutlet`;

DELIMITER $$
USE `TempMonitor`$$
CREATE DEFINER=`pi`@`%` PROCEDURE `GetOutlet`(in _outletId smallint unsigned)
BEGIN
	SELECT 
	Outlets.Id,
	Outlets.Name,
	Outlets.OnCode,
	Outlets.OffCode
FROM 
	Outlets
WHERE 
    Id = IFNULL(_outletId,Id) AND Active=1;
    
SELECT 
    Outlets.OnCode,
    SensorLogs.Id,
    SensorLogs.TimeStamp,
    (CASE SensorLogs.OutletState
        WHEN 1 THEN 'ON'
        ELSE 'OFF'
    END) AS OutletState,
    SensorLogs.Temperature,
    Sensors.Id AS SensorId,
    Sensors.Serial AS SensorSerial,
    Sensors.Name AS SensorName,
    (CASE Sensors.Monitor WHEN 1 THEN TRUE ELSE FALSE END) as Monitor,
    Sensors.SetTemperature
FROM
    SensorLogs
        LEFT JOIN
    Sensors ON Sensors.Id = SensorLogs.SensorId
        JOIN
    Outlets ON Outlets.Id = SensorLogs.OutletId
WHERE
    SensorLogs.OutletId = IFNULL(_outletId, SensorLogs.OutletId)
        AND Outlets.Active = 1
ORDER BY Timestamp;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GetSensor
-- -----------------------------------------------------

USE `TempMonitor`;
DROP procedure IF EXISTS `TempMonitor`.`GetSensor`;

DELIMITER $$
USE `TempMonitor`$$
CREATE DEFINER=`pi`@`%` PROCEDURE `GetSensor`(in _sensorId int unsigned)
BEGIN
	SELECT 
    Sensors.Id,
    Sensors.Serial,
    Sensors.Name,
    (CASE Sensors.Monitor WHEN 1 THEN TRUE ELSE FALSE END) as Monitor,
    Sensors.SetTemperature,
    Outlets.Id AS OutletId,
    Outlets.Name as OutletName,
    Outlets.OnCode,
    Outlets.OffCode
FROM
    Sensors
        LEFT OUTER JOIN
    Outlets ON Sensors.OutletId = Outlets.Id
WHERE Sensors.Id = IFNULL(_sensorId,Sensors.Id) AND Sensors.Active=1;

SELECT 
    SensorLogs.Id,
    SensorLogs.TimeStamp,
    (CASE SensorLogs.OutletState WHEN 1 THEN "ON" ELSE "OFF" END) as OutletState,
    SensorLogs.Temperature,
    Sensors.Serial,
    Outlets.Id AS OutletId,
    Outlets.Name,
    Outlets.OnCode,
    Outlets.OffCode
FROM
    SensorLogs
        JOIN
    Sensors ON Sensors.Id = SensorLogs.SensorId
        LEFT OUTER JOIN
    Outlets ON Outlets.Id = SensorLogs.OutletId
WHERE
    SensorLogs.SensorId = IFNULL(_sensorId,SensorLogs.SensorId) AND Sensors.Active = 1
ORDER BY Timestamp;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure LogSensor
-- -----------------------------------------------------

USE `TempMonitor`;
DROP procedure IF EXISTS `TempMonitor`.`LogSensor`;

DELIMITER $$
USE `TempMonitor`$$
CREATE DEFINER=`pi`@`%` PROCEDURE `LogSensor`(in _sensorId int unsigned,in _temperature int,in _outletState bit,in _outletId int unsigned)
BEGIN
	INSERT INTO SensorLogs (Temperature,OutletState,SensorId,OutletId)
    VALUES (_temperature,_outletState,_sensorId,_outletId);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure RemoveSensorOutlet
-- -----------------------------------------------------

USE `TempMonitor`;
DROP procedure IF EXISTS `TempMonitor`.`RemoveSensorOutlet`;

DELIMITER $$
USE `TempMonitor`$$
CREATE DEFINER=`pi`@`%` PROCEDURE `RemoveSensorOutlet`(in _sensorId int unsigned)
BEGIN
		UPDATE Sensors
		SET OutletId=NULL
		WHERE (Sensors.Id=_sensorId);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure UpdateOutlet
-- -----------------------------------------------------

USE `TempMonitor`;
DROP procedure IF EXISTS `TempMonitor`.`UpdateOutlet`;

DELIMITER $$
USE `TempMonitor`$$
CREATE DEFINER=`pi`@`%` PROCEDURE `UpdateOutlet`(in _outletId smallint unsigned,in _name varchar(255),in _onCode char(6),in _offCode char(6))
BEGIN
	UPDATE Outlets
    SET Name=IFNULL(_name,Name)
		,OnCode=IFNULL(_onCode,OnCode)
		,OffCode=IFNULL(_offCode,OffCode)
    WHERE (Id=_outletId);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure UpdateSensor
-- -----------------------------------------------------

USE `TempMonitor`;
DROP procedure IF EXISTS `TempMonitor`.`UpdateSensor`;

DELIMITER $$
USE `TempMonitor`$$
CREATE DEFINER=`pi`@`%` PROCEDURE `UpdateSensor`(in _sensorId int unsigned,in _name VARCHAR(255),in _serial CHAR(15),
in _monitor bit,in _outletId int unsigned,in _setTemperature float)
BEGIN
		UPDATE Sensors
		SET 
			Name = IFNULL(_name,Name)
			,Serial = IFNULL(_serial,Serial)
			,Monitor = IFNULL(_monitor,Monitor)
			,OutletId = IFNULL(_outletId,OutletId)
            ,SetTemperature = IFNULL(_setTemperature,SetTemperature)
		WHERE (Sensors.Id=_sensorId);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- View `TempMonitor`.`AvailableOutlets`
-- -----------------------------------------------------
DROP VIEW IF EXISTS `TempMonitor`.`AvailableOutlets` ;
DROP TABLE IF EXISTS `TempMonitor`.`AvailableOutlets`;
USE `TempMonitor`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`pi`@`%` SQL SECURITY DEFINER VIEW `TempMonitor`.`AvailableOutlets` AS select `TempMonitor`.`Outlets`.`Id` AS `Id`,`TempMonitor`.`Outlets`.`Name` AS `Name`,`TempMonitor`.`Outlets`.`OnCode` AS `OnCode` from `TempMonitor`.`Outlets` where (not(`TempMonitor`.`Outlets`.`Id` in (select `UsedOutlets`.`OutletId` from `TempMonitor`.`UsedOutlets`)));

-- -----------------------------------------------------
-- View `TempMonitor`.`CurrentSensorStates`
-- -----------------------------------------------------
DROP VIEW IF EXISTS `TempMonitor`.`CurrentSensorStates` ;
DROP TABLE IF EXISTS `TempMonitor`.`CurrentSensorStates`;
USE `TempMonitor`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`pi`@`%` SQL SECURITY DEFINER VIEW `TempMonitor`.`CurrentSensorStates` AS select `TempMonitor`.`Sensors`.`Id` AS `SensorId`,`TempMonitor`.`Sensors`.`Name` AS `SensorName`,`TempMonitor`.`Sensors`.`Serial` AS `SensorSerial`,(`TempMonitor`.`Sensors`.`Monitor` = 1) AS `Monitor`,`TempMonitor`.`Outlets`.`Id` AS `OutletId`,`TempMonitor`.`Outlets`.`Name` AS `OutletName`,`TempMonitor`.`Outlets`.`OnCode` AS `OnCode`,`TempMonitor`.`Outlets`.`OffCode` AS `OffCode`,`TempMonitor`.`Sensors`.`SetTemperature` AS `SetTemperature`,ifnull(`TempMonitor`.`SensorLogs`.`Temperature`,'UNKNOWN') AS `Temperature`,(case `TempMonitor`.`SensorLogs`.`OutletState` when 1 then 'ON' when 0 then 'OFF' else 'UNKNOWN' end) AS `OutletState`,ifnull(`TempMonitor`.`SensorLogs`.`TimeStamp`,'No Data') AS `Timestamp` from (((`TempMonitor`.`RecentSensorReadings` join `TempMonitor`.`Sensors` on((`TempMonitor`.`Sensors`.`Id` = `RecentSensorReadings`.`SensorId`))) left join `TempMonitor`.`SensorLogs` on((`TempMonitor`.`SensorLogs`.`Id` = `RecentSensorReadings`.`Id`))) left join `TempMonitor`.`Outlets` on((`TempMonitor`.`Outlets`.`Id` = `TempMonitor`.`SensorLogs`.`OutletId`))) where (`TempMonitor`.`Sensors`.`Active` = 1);

-- -----------------------------------------------------
-- View `TempMonitor`.`RecentSensorReadings`
-- -----------------------------------------------------
DROP VIEW IF EXISTS `TempMonitor`.`RecentSensorReadings` ;
DROP TABLE IF EXISTS `TempMonitor`.`RecentSensorReadings`;
USE `TempMonitor`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`pi`@`%` SQL SECURITY DEFINER VIEW `TempMonitor`.`RecentSensorReadings` AS select `TempMonitor`.`Sensors`.`Id` AS `SensorId`,max(`TempMonitor`.`SensorLogs`.`Id`) AS `Id` from (`TempMonitor`.`Sensors` left join `TempMonitor`.`SensorLogs` on((`TempMonitor`.`SensorLogs`.`SensorId` = `TempMonitor`.`Sensors`.`Id`))) group by `TempMonitor`.`Sensors`.`Id`;

-- -----------------------------------------------------
-- View `TempMonitor`.`SensorHistorys`
-- -----------------------------------------------------
DROP VIEW IF EXISTS `TempMonitor`.`SensorHistorys` ;
DROP TABLE IF EXISTS `TempMonitor`.`SensorHistorys`;
USE `TempMonitor`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`pi`@`%` SQL SECURITY DEFINER VIEW `TempMonitor`.`SensorHistorys` AS select `TempMonitor`.`Sensors`.`Name` AS `Name`,`TempMonitor`.`Sensors`.`Serial` AS `Serial`,isnull(`TempMonitor`.`Sensors`.`Active`) AS `Deleted`,`TempMonitor`.`SensorLogs`.`TimeStamp` AS `TimeStamp`,`TempMonitor`.`SensorLogs`.`Temperature` AS `Temperature`,`TempMonitor`.`Outlets`.`Name` AS `OutletName`,`TempMonitor`.`SensorLogs`.`OutletState` AS `OutletState` from ((`TempMonitor`.`SensorLogs` join `TempMonitor`.`Sensors` on((`TempMonitor`.`Sensors`.`Id` = `TempMonitor`.`SensorLogs`.`SensorId`))) join `TempMonitor`.`Outlets` on((`TempMonitor`.`Outlets`.`Id` = `TempMonitor`.`SensorLogs`.`OutletId`)));

-- -----------------------------------------------------
-- View `TempMonitor`.`UsedOutlets`
-- -----------------------------------------------------
DROP VIEW IF EXISTS `TempMonitor`.`UsedOutlets` ;
DROP TABLE IF EXISTS `TempMonitor`.`UsedOutlets`;
USE `TempMonitor`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`pi`@`%` SQL SECURITY DEFINER VIEW `TempMonitor`.`UsedOutlets` AS select `TempMonitor`.`Sensors`.`OutletId` AS `OutletId` from `TempMonitor`.`Sensors` where ((`TempMonitor`.`Sensors`.`Active` is not null) and (`TempMonitor`.`Sensors`.`OutletId` is not null));

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
