var express = require("express");

var router = express.Router();

var sensors = {};
var db = require("../../Database");

router.get("/:sensorId(\\d*)?/recent", function (req, res) {
    var id = -1;
    if (typeof req.params.sensorId != "undefined")
        id = req.params.sensorId;
    db.sensors.recent(id, function (err, results) {
        if (err) {
            res.status(500).send("Server Error");
            return;
        }
        res.status(200).send(results);
    });
});


router.get("/:sensorId(\\d*)?", function (req, res) {
    var id = -1;
    if (typeof req.params.sensorId != "undefined")
        id = req.params.sensorId;
    db.sensors.get(id, function (err, results) {
        if (err) {
            res.status(500).send( "Server Error");
            return;
        }
        res.status(200).send(results);
    });
});

router.post("/-?\\d*", function(req, res) {
    var sensor = req.body;
    db.sensors.insert(sensor, function(err, results) {
        if (err) {
            res.status(500);
            if (err.code === "ER_DUP_ENTRY")
                res.status(409);
            res.send(err.message);
            return;
        }
        sensor.id = results;
        res.location('/API/Sensors/' + results);
        res.status(201).send( sensor);
    });
});

router.put("/:sensorId", function (req, res) {
    var sensor = req.body;
    db.sensors.update(sensor, function(err, results) {
        if (err) {
            res.status(500).send( err.message);
            return;
        }
        res.location('/API/Sensors/' + sensor.id, sensor);
        res.status(200).send( sensor);
    });
});

router.patch("/:sensorId", function (req, res) {
    var sensor = req.body;
    if (isNaN(sensor.id))
        sensor.id = req.params.sensorId;
    db.sensors.toggle(sensor, function (err, results) {
        if (err) {
            res.status(500).send( err.message);
            return;
        }
        sensor.monitor = results;
        res.location('/API/Sensors/' + sensor.id, sensor);
        res.status(200).send( sensor);
    });
});

router.delete("/:sensorId", function(req, res) {
    db.sensors.delete(req.params.sensorId, function(err, results) {
        if (err) {
            res.status(50).send( err.message);
            return;
        }
        res.status(204).send();
    });
});

module.exports = router;