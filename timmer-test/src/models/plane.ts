import { Config } from "./config";

export interface Plane {
  id: string;
  configs: Config[];
}

export class PlaneBuilder implements Plane {
  constructor(public id: string, public configs: Config[]) {}
}
