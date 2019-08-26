"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
var serialport_1 = __importDefault(require("serialport"));
var config_1 = require("./models/config");
var step_1 = require("./models/step");
var timeTypes = {
    "0": 100,
    "1": 1000,
    "2": 60000
};
var SERVO_CONFIG_LENGTH = 145;
var LED_BYTE = 222;
var MAX_LENGTH = 254;
var Readline = serialport_1.default.parsers.Readline;
var parser = new Readline({ delimiter: "\n" });
function fromTimmerToConfig(data) {
    var config = new config_1.ConfigBuilder();
    var counter = 0;
    config.servos[0].initServo(Number(data[0]), Number(data[5]));
    config.servos[1].initServo(Number(data[1]), Number(data[6]));
    config.servos[2].initServo(Number(data[2]), Number(data[7]));
    config.servos[3].initServo(Number(data[3]), Number(data[8]));
    config.servos[4].initServo(Number(data[4]), Number(data[9]));
    for (var i = 10; i <= SERVO_CONFIG_LENGTH; i += 4) {
        var timeOffset = timeTypes[data[i + 1]];
        var timeInMs = timeOffset * Number(data[i]);
        var step = new step_1.StepBuilder(Number(data[i + 3]), timeInMs);
        config.servos[Number(data[i + 2]) - 1].steps.push(step);
    }
    if (Number(data[LED_BYTE])) {
        config.ledOff = false;
    }
    else {
        config.ledOff = true;
    }
    var configId = "";
    for (var i = 223; i <= MAX_LENGTH; i += 1) {
        configId += data[i];
    }
    config.id = configId;
    return config;
}
function loadFromUSB() {
    var port = new serialport_1.default("/dev/ttyACM0", {
        baudRate: 9600,
        dataBits: 8,
        parity: "none",
        stopBits: 1
    });
    port.pipe(parser);
    return new Promise(function (resolve, reject) {
        return port.on("open", function () {
            var readed = 0;
            var data = [];
            port.on("data", function (incomming) {
                data.push(incomming);
                if (readed === MAX_LENGTH) {
                    var parsed = fromTimmerToConfig(data);
                    resolve(parsed);
                }
                readed += 1;
            });
            port.on("error", reject);
            port.write(Buffer.from("L"));
        });
    });
}
function uploadToUSB() { }
function test() {
    var toSend = "0 0 0 0 0 150 150 150 150 150 40 1 1 80 40 1 1 70 40 1 1 60 40 1 1 50 40 1 2 80 40 1 2 70 40 1 2 60 40 1 2 50 40 1 3 80 40 1 3 70 40 1 3 60 40 1 3 50 40 1 4 80 40 1 4 70 40 1 4 60 40 1 4 50 40 1 5 80 40 1 5 70 40 1 5 60 40 1 5 50 40 1 5 60 40 1 5 120 40 1 5 10 40 1 5 5 40 1 5 39 40 1 5 60 40 1 5 55 40 1 5 11 40 1 5 12 40 1 5 13 40 1 5 14 40 1 5 115 40 1 5 114 3 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0";
    var asArray = toSend.split(" ");
    var config = fromTimmerToConfig(asArray);
    console.log(JSON.stringify(config));
}
test();
