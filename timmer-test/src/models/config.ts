import { Servo, ServoBuilder } from "./servo";
import hyperid = require("hyperid");

const instance = hyperid();

export interface Config {
  id: string;
  ledOff: boolean;
  servos: Servo[];
}

export class ConfigBuilder implements Config {
  public id: string = instance();
  public ledOff: boolean = true;
  public servos: Servo[] = [];

  constructor() {
    this.servos.push(new ServoBuilder("Engine"));
    this.servos.push(new ServoBuilder("Flap"));
    this.servos.push(new ServoBuilder("Stabilo"));
    this.servos.push(new ServoBuilder("Rudder"));
    this.servos.push(new ServoBuilder("Folder"));
  }
}
