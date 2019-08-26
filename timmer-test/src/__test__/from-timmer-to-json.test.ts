/*
 * Copyright (c) AXA Shared Services Spain S.A.
 *
 * Licensed under the AXA Shared Services Spain S.A. License (the 'License'); you
 * may not use this file except in compliance with the License.
 * A copy of the License can be found in the LICENSE.TXT file distributed
 * together with this file.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
// eslint-disable-next-line no-unused-vars
import { fromTimmerToConfig } from "../to-usb";

const { seq } = require("./fixtures/timmer-sequence.json");

describe("Timmer test", () => {
  describe("From timmer to json", () => {
    test("should load the given sequence", () => {
      const expected = require("./fixtures/timmer-expected-json.json");
      const asArray = seq.split(" ");
      const config = fromTimmerToConfig(asArray);
      expect(config).toEqual(expected);
    });
  });
});
