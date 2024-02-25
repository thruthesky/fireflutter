import { describe, it } from "mocha";
import assert = require("assert");
import { UserService } from "../../src/user/user.service";


describe("phone number register", () => {
    it("empty phone number", async () => {
        const res = await UserService.createAccountWithPhoneNumber({ phoneNumber: "" });
        assert.ok(res.code === "auth/invalid-phone-number", "...");
    });
    it("invalid phone number - 123", async () => {
        const res = await UserService.createAccountWithPhoneNumber({ phoneNumber: "123" });
        assert.ok(res.code === "auth/invalid-phone-number", "...");
    });
    it("invalid phone number - 010-8693-1111", async () => {
        const res = await UserService.createAccountWithPhoneNumber({ phoneNumber: "010-8693-1111" });
        assert.ok(res.code === "auth/invalid-phone-number", "...");
    });
    it("existing phone number - +1-1111-111-111", async () => {
        const res = await UserService.createAccountWithPhoneNumber({ phoneNumber: "+1-1111-111-111" });
        assert.ok(res.code === "auth/phone-number-already-exists", "...");
    });
    it("Real phone number - +1-9999-001-001", async () => {
        const res = await UserService.createAccountWithPhoneNumber({ phoneNumber: "+1-9999-001-001" });
        console.log("res:", res);
        assert.ok(res.code === "auth/phone-number-already-exists", "...");
    });
});

