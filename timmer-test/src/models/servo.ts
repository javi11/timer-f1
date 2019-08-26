import { Step } from "./step";

export interface Servo {
  minRotation: number;
  maxRotation: number;
  timeStep: number;
  id: string;
  steps: Step[];
  initialPosition: number;
  RDT: number;
  initServo(initialPosition: number, RDT: number): void;
}

export class ServoBuilder implements Servo {
  public steps: Step[] = [];
  public initialPosition: number = 0;
  public RDT: number = 0;

  constructor(
    public id: string,
    public minRotation: number = 30,
    public maxRotation: number = 150,
    public timeStep: number = 0.1
  ) {}

  initServo(initialPosition: number, RDT: number) {
    this.initialPosition = initialPosition;
    this.RDT = RDT;
  }
}
