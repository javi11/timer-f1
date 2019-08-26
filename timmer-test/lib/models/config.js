"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var servo_1 = require("./servo");
var hyperid = require("hyperid");
var instance = hyperid();
var ConfigBuilder = /** @class */ (function () {
    function ConfigBuilder() {
        this.id = instance();
        this.ledOff = true;
        this.servos = [];
        this.servos.push(new servo_1.ServoBuilder("Engine"));
        this.servos.push(new servo_1.ServoBuilder("Flap"));
        this.servos.push(new servo_1.ServoBuilder("Stabilo"));
        this.servos.push(new servo_1.ServoBuilder("Rudder"));
        this.servos.push(new servo_1.ServoBuilder("Folder"));
    }
    return ConfigBuilder;
}());
exports.ConfigBuilder = ConfigBuilder;
