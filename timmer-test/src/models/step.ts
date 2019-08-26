export interface Step {
  position: number;
  delay: number;
}

export class StepBuilder implements Step {
  constructor(public position: number, public delay: number) {}
}
