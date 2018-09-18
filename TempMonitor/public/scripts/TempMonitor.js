var TempMonitor = angular.module('TempMonitor', ['ngResource', 'ui.bootstrap', 'ui.router']);
var configFunction = function($stateProvider, $locationProvider, $urlRouterProvider) {

    $locationProvider.html5Mode(true).hashPrefix('!');
    $stateProvider.state("home", {
        abstract: true,
        //  /
        url: "/",
        views: {
            "navContainer": {
                templateUrl: "/templates/navbar.html"
            },
            "content": {
                templateUrl: "/templates/content.html"
            },
            "monitorView": {
                templateUrl: "/templates/monitor.html",
                controller: dashboardController
            }
        }
    }).state("home.dashboard", {
        // /
        url: "",
        views: {
            "mainView@home": {
                templateUrl: "/templates/home/dashboard.html",
                controller: dashboardController
            }
        }
    }).state("home.sensors", {
        // /sensors/
        url: "sensors",
        views: {
            "mainView@home": {
                templateUrl: "/templates/sensors/index.html",
                controller: sensorController
            }
        }
    }).state("home.sensors.view", {
        // /sensors/1
        url: "/:id",
        views: {
            "mainView@home": {
                templateUrl: "/templates/sensors/view.html",
                controller: sensorController
            }
        }
    })
    .state("home.sensors.view.edit", {
        // /sensors/1/edit
        url: "/edit",
        views: {
            "mainView@home": {
                templateUrl: "/templates/sensors/edit.html",
                controller: sensorEditController
            }
        }
    })
    .state("home.outlets", {
        // /outlets/
        url: "outlets",
        views: {
            "mainView@home": {
                templateUrl: "/templates/outlets/index.html",
                controller: outletController
            }
        }
    }).state("home.outlets.view", {
        // /outlets/1
        url: "/:id",
        views: {
            "mainView@home": {
                templateUrl: "/templates/outlets/view.html",
                controller: outletController
            }
        }
    }).state("home.outlets.view.edit", {
        // /outlets/1/edit
        url: "/edit",
        views: {
            "mainView@home": {
                templateUrl: "/templates/outlets/edit.html",
                controller: outletEditController
            }
        }
    });
};
TempMonitor.config(configFunction);