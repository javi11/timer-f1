"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var ServoBuilder = /** @class */ (function () {
    function ServoBuilder(id, minRotation, maxRotation, timeStep) {
        if (minRotation === void 0) { minRotation = 30; }
        if (maxRotation === void 0) { maxRotation = 150; }
        if (timeStep === void 0) { timeStep = 0.1; }
        this.id = id;
        this.minRotation = minRotation;
        this.maxRotation = maxRotation;
        this.timeStep = timeStep;
        this.steps = [];
        this.initialPosition = 0;
        this.RDT = 0;
    }
    ServoBuilder.prototype.initServo = function (initialPosition, RDT) {
        this.initialPosition = initialPosition;
        this.RDT = RDT;
    };
    return ServoBuilder;
}());
exports.ServoBuilder = ServoBuilder;
