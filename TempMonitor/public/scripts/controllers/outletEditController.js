"use strict";
var outletEditController = function($scope, $stateParams, $state, tempMonitorData) {
    var id = $stateParams.id;
    if (id < 1) {
        $scope.verb = "Add";
        $scope.outlet = new tempMonitorData.outlets({
            id: -1,
            name: "New Outlet",
            onCode: "",
            offCode:""
        });
    } else {
        $scope.verb = "Edit";
        $scope.outlet = tempMonitorData.outlets.get({ id: id });
    }

    $scope.close = function () {
        if ($scope.outlet.id == -1)
            tempMonitorData.outlets.save($scope.outlet).$promise.then(
                //success
                function (resp) {
                    $scope.saving = false;
                    if (resp.id != -1)
                        $state.go("^", { id: resp.id });
                });
        else
            tempMonitorData.outlets.update($scope.outlet).$promise.then(function (resp) {
                $scope.saving = false;
                if (resp.id != -1)
                    $state.go("^", { id: resp.id });
            });
        $scope.saving = true;
    }
};

TempMonitor.controller("outletEditController", outletEditController);