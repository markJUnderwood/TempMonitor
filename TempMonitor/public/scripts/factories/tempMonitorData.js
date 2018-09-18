TempMonitor.factory("tempMonitorData", function($resource) {
    return {
        sensors: $resource("/API/sensors/:id", { id: "@id" }, {
            recent: {
                method: "GET",
                url: "/API/sensors/:id/recent",
                isArray: true
            },
            post: {
                method: "POST",
                url:"/API/sensors/"
            },
            update: {
                method: "PUT"
            },
            patch: {
                method:"PATCH"
            }
        }),
        outlets: $resource("/API/outlets/:id", { id: "@id" }, {
            available: {
                method: "GET",
                url: "/API/outlets/available",
                isArray: true
            },
            update: {
                method: "PUT"
            }
        })
    }
});