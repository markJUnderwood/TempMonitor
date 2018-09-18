const recip18 = 0.55555555555555555555555555555556;
TempMonitor.directive("temperature", function() {
    return {
        restrict: "A",
        require: 'ngModel',
        link: function(scope, element, attr, ngModel) {
            function fromUser(value) {
                return Math.ceil(((value - 32) * recip18) * 1000);
            }
            
            function toUser(value) {
                value = value * 0.001;
                value = (value * 1.8 + 32);
                return +(Math.round(value + "e+2") + "e-2");
            }
            ngModel.$parsers.push(fromUser);
            ngModel.$formatters.push(toUser);
        }
    }
})
