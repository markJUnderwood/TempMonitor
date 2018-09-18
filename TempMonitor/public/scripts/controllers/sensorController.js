"use strict";
var sensorController = function ($scope, $stateParams, $state, tempMonitorData) {
    function toggleSensor(sensorIndex) {
        return function (resp) {
            $scope.sensors[sensorIndex] = resp;
        }
    }
    function deleteSensor(sensorIndex) {
        return function () {
            $scope.sensors.splice(sensorIndex, 1);
        }
    }
    var id = $stateParams.id;
    var state = $state.current;
    switch (state.name) {
        case "home.sensors.view":
            $scope.sensor = tempMonitorData.sensors.get({ id: id });
            $scope.delete = function () {

                tempMonitorData.sensors.delete($scope.sensor).$promise.then(function() {
                    $state.go("^");
                });
            }
            break;
        default:
            $scope.sensors = tempMonitorData.sensors.query();
            $scope.toggle = function (sensorIndex) {
                var callback = toggleSensor(sensorIndex);
                tempMonitorData.sensors.patch($scope.sensors[sensorIndex]).$promise.then(callback);
            }
            $scope.delete = function (sensorIndex) {
                var callback = deleteSensor(sensorIndex);
                tempMonitorData.sensors.delete($scope.sensors[sensorIndex]).$promise.then(callback);
            }
    }
    
}
TempMonitor.controller('sensorController', sensorController)