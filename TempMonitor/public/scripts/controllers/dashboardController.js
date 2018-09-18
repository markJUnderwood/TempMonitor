"use strict";
const recip1000 = 0.001;
var dashboardController = function ($scope,$interval, tempMonitorData) {
    var refreshSensors = function () {
        tempMonitorData.sensors.recent(function (data) {
            $scope.sensors = data;
        });
    }
    var intervalPromise = $interval(refreshSensors, 5000);
    $scope.sensors = tempMonitorData.sensors.recent();
    $scope.toDate = function(timestamp) {
        return new Date(timestamp).toLocaleString();
    }
    $scope.toShortDate = function(timestamp) {
        return new Date(timestamp).toLocaleTimeString();
    }

    $scope.$on("$destroy", function() {
        if (angular.isDefined(intervalPromise)) {
            $interval.cancel(intervalPromise);
            intervalPromise = undefined;
        }
    });

    $scope.calculateTemperature = function(temp) {
        //temp = TempInC*1000
        //foo
        if (isNaN(temp))
            return "-";
        return (temp * recip1000 * 1.8 + 32).toFixed(2);
    };
}
TempMonitor.controller('dashboardController', dashboardController)