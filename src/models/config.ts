import { Step } from './step';

export interface Config {
  id: string;
  ledOff: boolean;
  steps: Step[];
}
