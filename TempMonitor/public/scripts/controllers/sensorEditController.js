"use strict";
var sensorEditController = function($scope, $stateParams, $state, tempMonitorData) {
    var id = $stateParams.id;
    $scope.outlets = tempMonitorData.outlets.available();
    if (id < 1) {
        $scope.verb = "Add";
        $scope.sensor = new tempMonitorData.sensors({
            id: -1,
            name: "New Sensor",
            serial: "",
            monitor: true,
            outlet: null,
            setTemperature: 266667
        });
    } else {
        $scope.verb = "Edit";
        $scope.sensor = tempMonitorData.sensors.get({ id: id });
    }
    $scope.close = function () {
        if ($scope.sensor.id == -1)
            tempMonitorData.sensors.save($scope.sensor).$promise.then(
                //success
                function(resp) {
                    $scope.saving = false;
                    if (resp.id != -1)
                        $state.go("^", { id: resp.id });
                });
        else
            tempMonitorData.sensors.update($scope.sensor).$promise.then(function(resp) {
                $scope.saving = false;
                if (resp.id != -1)
                    $state.go("^", { id: resp.id });
            });
        $scope.saving = true;
    }
};
TempMonitor.controller("sensorEditController", sensorEditController);