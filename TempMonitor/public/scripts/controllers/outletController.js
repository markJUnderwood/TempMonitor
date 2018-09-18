"use strict";
var outletController = function ($scope, $stateParams, $state, tempMonitorData) {
    function deleteOutlet(outletIndex) {
        return function () {
            $scope.outlets.splice(outletIndex, 1);
        }
    }
    var id = $stateParams.id;
    var state = $state.current;
    switch (state.name) {
        case "home.outlets.view":
            $scope.outlet = tempMonitorData.outlets.get({ id: id });
            $scope.delete = function () {
                tempMonitorData.outlets.delete($scope.outlet).$promise.then(function () {
                    $state.go("^");
                });
            }
            break;
        default:
            $scope.outlets = tempMonitorData.outlets.query();
            $scope.delete = function (outletIndex) {
                var callback = deleteOutlet(outletIndex);
                tempMonitorData.outlets.delete($scope.outlets[outletIndex]).$promise.then(callback);
            }
    }
}
TempMonitor.controller('outletController', outletController)