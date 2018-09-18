var express = require("express");

var router = express.Router();
var outlets = {};
var db = require("../../Database");

router.get("/available", function (req, res) {
    db.outlets.available(function (err, results) {
        if (err) {
            res.status(500).send(err.message);
        }
        res.send(results);
    });
});

router.get("/:outletId?", function (req, res) {
    var id = -1;
    if (typeof req.params.outletId != "undefined")
        id = req.params.outletId;
    db.outlets.get(id, function (err, results) {
        if (err) {
            res.status(500).send("Server Error");
            return;
        }
        res.status(200).send(results);
    });
});

router.post("/-?\\d*", function (req, res) {
    var outlet = {
        name: req.body.name,
        onCode: req.body.onCode,
        offCode: req.body.offCode
    };
    db.outlets.insert(outlet, function (err, results) {
        if (err) {
            res.status(500);
            if (err.code === "ER_DUP_ENTRY")
                res.status(409);
            res.send(err.message);
            return;
        }
        outlet.id = results;
        res.location('/API/Outlets/' + results);
        res.status(201).send(outlet);
    });
});

router.put("/:outletId", function (req, res) {
    var outlet = {
        name: req.body.name,
        onCode: req.body.onCode,
        offCode: req.body.offCode,
        id: req.params.outletId
    };
    db.outlets.update(outlet, function (err, results) {
        if (err) {
            res.status(500).send(err.message);
            return;
        }
        res.location('/API/Outlets/' + outlet.id, outlet);
        res.status(200).send(outlet);
    });
});

router.delete("/:outletId", function (req, res) {
    db.outlets.delete(req.params.outletId, function (err, results) {
        if (err) {
            res.status(500).send(err.message);
            return;
        }
        res.status(204).send();
    });
});



module.exports = router;