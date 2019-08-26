import SerialPort from "serialport";
import { Config, ConfigBuilder } from "./models/config";
import { StepBuilder } from "./models/step";

const timeTypes: { [key: string]: number } = {
  "0": 100,
  "1": 1000,
  "2": 60000
};
const SERVO_CONFIG_LENGTH = 220;
const LED_BYTE = 222;
const MAX_LENGTH = 254;

const Readline = SerialPort.parsers.Readline;
const parser = new Readline({ delimiter: "\n" });

export function fromTimmerToConfig(data: string[]): Config {
  const config = new ConfigBuilder();
  let counter = 0;
  config.servos[0].initServo(Number(data[0]), Number(data[5]));
  config.servos[1].initServo(Number(data[1]), Number(data[6]));
  config.servos[2].initServo(Number(data[2]), Number(data[7]));
  config.servos[3].initServo(Number(data[3]), Number(data[8]));
  config.servos[4].initServo(Number(data[4]), Number(data[9]));

  for (let i = 10; i <= SERVO_CONFIG_LENGTH; i += 4) {
    // If the servo is 0 means that are 0 to fill
    if (Number(data[i + 2]) === 0) {
      continue;
    }
    let timeOffset = timeTypes[data[i + 1]];
    let timeInMs = timeOffset * Number(data[i]);
    let step = new StepBuilder(Number(data[i + 3]), timeInMs);
    config.servos[Number(data[i + 2]) - 1].steps.push(step);
  }

  if (Number(data[LED_BYTE])) {
    config.ledOff = false;
  } else {
    config.ledOff = true;
  }

  let configId = "";
  for (let i = SERVO_CONFIG_LENGTH; i <= MAX_LENGTH; i += 1) {
    configId += String(data[i]);
  }

  config.id = configId;

  return config;
}

export function loadFromUSB(): Promise<Config> {
  let port = new SerialPort("/dev/ttyACM0", {
    baudRate: 9600,
    dataBits: 8,
    parity: "none",
    stopBits: 1
  });
  port.pipe(parser);

  return new Promise((resolve, reject) =>
    port.on("open", function() {
      let readed = 0;
      let data: string[] = [];
      port.on("data", (incomming: string) => {
        data.push(incomming);
        if (readed === MAX_LENGTH) {
          const parsed: Config = fromTimmerToConfig(data);
          resolve(parsed);
        }
        readed += 1;
      });
      port.on("error", reject);
      port.write(Buffer.from("L"));
    })
  );
}

export function uploadToUSB() {}
