import { expect } from "chai";
import { describe, it } from "mocha";

describe("Mocha Chai", () => {
    describe("Equal test", () => {
        it("1 equals 1 ..", () => {
            expect(1).equal(1);
        });
    });
});
