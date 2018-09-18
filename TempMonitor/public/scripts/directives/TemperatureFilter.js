TempMonitor.filter('temperature',function() {
    return function(input, outputScale, divisor, inputScale,decimalPlaces,$sce) {
        if (isNaN(input))
            return input;
        //No black holes!
        if (isNaN(divisor) || divisor === 0)
            divisor = 1;
        if (isNaN(decimalPlaces))
            decimalPlaces = 2;
        outputScale = outputScale.toUpperCase() || "C";
        inputScale = inputScale.toUpperCase() || "C";

        //Get the divisor out of the way so we can get to the conversions
        var returnValue = input / divisor;

        if (inputScale === "C")
            if (outputScale === "C")
                returnValue = returnValue.toFixed(decimalPlaces) + "\u2103";
            else if (outputScale === "F")
                return (returnValue * 1.8 + 32).toFixed(decimalPlaces) + "\u2109";
        else if (inputScale === "F") 
            if (outputScale === "C")
                returnValue = ((returnValue - 32) * recip18).toFixed(decimalPlaces) + "\u2103";
            else if (outputScale === "F")
                returnValue = returnValue.toFixed(decimalPlaces) + "\u2109";

        return returnValue;
    }
})