var mysql = require("mysql");
var config = require("./Config");
var pool = mysql.createPool(config.sql);
function doSql(sql, params, callback) {
    pool.getConnection(function (err, connection) {
        if (err) {
            console.log(err.message);
            callback(err);
            return;
        }
        connection.query(sql, params,function(err, results) {
            connection.release();
            if (err) {
                console.log(err.message);
                callback(err);
                return;
            }
            callback(err, results);
        });
    });
    
}

exports.sensors = {
    get: function(sensorId, callback) {
        var sensorValue = sensorId === -1 ? null : sensorId;
        var sql = "CALL GetSensor(?)";
        doSql(sql, [sensorValue], function(err, rowsets) {
            if (err) {
                return;
            }
            //Build Sensors first
            var rows = rowsets[0];
            var length = rows.length;
            var i;
            var row;
            var buildSensors = new Array();
            for (i = 0; i < length; i++) {
                row = rows[i];
                buildSensors[row["Serial"]] = {
                    id: row["Id"],
                    serial: row["Serial"],
                    name: row["Name"],
                    monitor: (row["Monitor"] === 1),
                    setTemperature: row["SetTemperature"],
                    outlet: {
                        id: row["OutletId"],
                        name: row["OutletName"],
                        onCode: row["OnCode"],
                        offCode: row["OffCode"]
                    },
                    logs: []
                }
            }

            //Sensors are built, now add in the log data for the sensors
            rows = rowsets[1];
            length = rows.length;
            for (i = 0; i < length; i++) {
                row = rows[i];
                var log = {
                    id: row["Id"],
                    timeStamp: row["TimeStamp"],
                    temperature: row["Temperature"],
                    outlet: {
                        id: row["OutletId"],
                        state: row["OutletState"],
                        name: row["OutletName"],
                        onCode: row["OnCode"],
                        offCode: row["OffCode"]
                    }
                }
                buildSensors[row["Serial"]].logs.push(log);
            }
            var sensors = [];
            for (var sensor in buildSensors) {
                if (buildSensors.hasOwnProperty(sensor)) {
                    sensors.push(buildSensors[sensor]);
                }
            }
            if (sensorId > 0 && sensors.length > 0)
                callback(err, sensors[0]);
            else
                callback(err, sensors);
        });
    },
    recent: function (sensorId, callback) {
        var sql;
        if (sensorId > 0)
            sql = "SELECT * FROM TempMonitor.CurrentSensorStates WHERE SensorId = ?;";
        else
            sql = "SELECT * FROM TempMonitor.CurrentSensorStates;";
        doSql(sql, [sensorId], function(err, rows) {
            if (err) {
                callback(err);
                return;
            }
            var length = rows.length;
            var i;
            var recentSensors = [];
            for (i = 0; i < length; i++) {
                recentSensors.push({
                    id: rows[i]["SensorId"],
                    name: rows[i]["SensorName"],
                    serial: rows[i]["SensorSerial"],
                    monitor: rows[i]["Monitor"],
                    setTemperature: rows[i]["SetTemperature"],
                    temperature: rows[i]["Temperature"],
                    outlet: {
                        name: rows[i]["OutletName"],
                        state: rows[i]["OutletState"]
                    },
                    timestamp: rows[i]["Timestamp"]
                });
            }
            if (sensorId > 0 && recentSensors.length > 0)
                callback(err, recentSensors[0]);
            else
                callback(err, recentSensors);
        });
    },
    insert: function(sensor, callback) {
        var sql = "SET @newId = 0; CALL AddSensor(?,?,?,?,?,@newId);SELECT @newId;";
        //must be true or false
        if (isNaN(sensor.monitor))
            sensor.monitor = (sensor.monitor.toLowerCase() === "true" || sensor.monitor.toLowerCase() === "1") ? 1 : 0;
        var sensorArray = [
            sensor.name,
            sensor.serial,
            sensor.monitor,
            (sensor.outlet==null?null:sensor.outlet.id),
            sensor.setTemperature
        ];
        doSql(sql, sensorArray, function(err, rows) {
            if (err) {
                callback(err);
                return;
            }
            if (typeof rows === "undefined" || typeof rows[0] === "undefined") {
                console.log("No Rows Returned from call");
                callback(true);
                return;
            }
            callback(false, rows[2][0]['@newId']);
        });
    },
    update: function(sensor, callback) {
        var sql = "CALL UpdateSensor(?,?,?,?,?,?)";
        if (isNaN(sensor.monitor))
            sensor.monitor = (sensor.monitor.toLowerCase() === "true" || sensor.monitor.toLowerCase() === "1") ? 1 : 0;
        var sensorArray = [
            sensor.id,
            sensor.name,
            sensor.serial,
            sensor.monitor,
            (sensor.outlet == null?null:sensor.outlet.id),
            sensor.setTemperature
        ];
        doSql(sql, sensorArray, function(err) {
            if (err) {
                callback(err);
                return;
            }
            callback(err);
        });
    },
    toggle: function(sensor, callback) {
        var sql = "";
        if (isNaN(sensor.monitor))
            sensor.monitor = (sensor.monitor.toLowerCase() === "true" || sensor.monitor.toLowerCase() === "1") ? 1 : 0;
        var returnVal = false;
        if (sensor.monitor > 0) {
            sql = "CALL DeactivateSensor(?)";
        } else {
            sql = "CALL ActivateSensor(?)";
            returnVal = true;
        }
        doSql(sql, [sensor.id], function(err) {
            if (err) {
                callback(err);
                return;
            }
            callback(err, returnVal);
        });
    },
    delete: function(sensorId, callback) {
        var sql = "CALL DeleteSensor(?)";
        doSql(sql, [sensorId], function(err, results) {
            if (err) {
                callback(err);
                return;
            }
            callback(err, results);
        });
    }
};

exports.outlets = {
    get: function (outletId, callback) {
        var outletValue = outletId === -1 ? null : outletId;
        var sql = "CALL GetOutlet(?)";
        doSql(sql, [outletValue], function (err, rowsets) {
            if (err) {
                return;
            }
            var length;
            var i;
            var row;
            //Build Outlets first
            var buildOutlets = new Array();
            var rows = rowsets[0];
            length = rows.length;
            for (i = 0; i < length; i++) {
                row = rows[i];
                buildOutlets[row["OnCode"]] = {
                    id: row["Id"],
                    name: row["Name"],
                    onCode: row["OnCode"],
                    offCode: row["OffCode"],
                    logs: []
                }
            }
            
            //Outlets are built, now add in the log data for the outlets
            rows = rowsets[1];
            length = rows.length;
            for (i = 0; i < length; i++) {
                row = rows[i];
                var log = {
                    id: row["Id"],
                    timeStamp: row["TimeStamp"],
                    temperature: row["Temperature"],
                    state: row["OutletState"],
                    sensor: {
                        id: row["SensorId"],
                        name: row["SensorName"],
                        serial: row["SensorSerial"],
                        monitor: (row["Monitor"]===1),
                        setTemperature: row["SetTemperature"]
                    }
                }
                buildOutlets[row["OnCode"]].logs.push(log);
            }
            var outlets = [];
            for (var outlet in buildOutlets) {
                if (buildOutlets.hasOwnProperty(outlet)) {
                    outlets.push(buildOutlets[outlet]);
                }
            }
            if (outletId > 0 && outlets.length > 0)
                callback(err, outlets[0]);
            else
                callback(err, outlets);
        });
    },
    available: function(callback) {
        var sql = "SELECT * FROM AvailableOutlets;";
        doSql(sql, [], function(err, rows) {
            if (err)
                return;
            var buildOutlets = new Array();
            var length = rows.length;
            for (var i = 0; i < length; i++) {
                var row = rows[i];
                buildOutlets.push({
                    id: row["Id"],
                    name: row["Name"],
                    onCode: row["OnCode"],
                    offCode: row["OffCode"],
                    logs: []
                });
            }
            callback(err, buildOutlets);
        });
    },
    insert: function (outlet, callback) {
        var sql = "SET @newId = 0; CALL AddOutlet(?,?,?,@newId);SELECT @newId;";
        var outletArray = [
            outlet.name,
            outlet.onCode,
            outlet.offCode
        ];
        doSql(sql, outletArray, function (err, rows) {
            if (err) {
                callback(err);
                return;
            }
            if (typeof rows === "undefined" || typeof rows[0] === "undefined") {
                console.log("No Rows Returned from call");
                callback(true);
                return;
            }
            callback(false, rows[2][0]['@newId']);
        });
    },
    update: function (outlet, callback) {
        var sql = "CALL UpdateOutlet(?,?,?,?)";
        var outletArray = [
            outlet.id,
            outlet.name,
            outlet.onCode,
            outlet.offCode
        ];
        doSql(sql, outletArray, function (err) {
            if (err) {
                callback(err);
                return;
            }
            callback(err);
        });
    },
    delete: function (outletId, callback) {
        var sql = "CALL DeleteOutlet(?)";
        doSql(sql, [outletId], function (err, results) {
            if (err) {
                callback(err);
                return;
            }
            callback(err, results);
        });
    }
};
