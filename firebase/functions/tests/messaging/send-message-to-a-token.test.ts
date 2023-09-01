import "mocha";

import "../firebase.init";

import { Messaging } from "../../src/models/messaging.model";
import { expect } from "chai";

const validToken = "fQCpkXq5TqG5_VPHJmJtPQ:APA91bEL114Rt1_hD4xlL5SShs-Nr0q06bT82bLK0cEPWt0GycudJnB0lEo0MOqoRUMCU8vs_ttGbu7r29jZ7mZ_bX0BqUNrDHSdYVyo9vQxKRgTFXZAz2D5km19C_OcKhOWptOmU8mH";

describe("Send message to token - invalid tokens", () => {
    it("Send a message with invalid tokens", async () => {
        const res = await Messaging.sendMessage({
            title: "From Node - cli",
            content: "Let's open the screen - with link !!",
            tokens: [
                "12345Xq5TqG5_VPHJmJtPQ:12345678904Rt1_hD4xlL5SShs-Nr0q06bT82bLK0cEPWt0GycudJnB0lEo0MOqoRUMCU8vs_ttGbu7r29jZ7mZ_bX0BqUNrDHSdYVyo9vQxKRgTFXZAz2D5km19C_OcKhOWptOmU8mH",
            ].join(","),
        });
        // console.log("--> sending via tokens", res);
        expect(res).to.be.an("object");
        expect(res['success']).to.be.equal(0);
        expect(res['error']).to.be.equal(1);
    })
});

describe("Send message to token - valid token", () => {
    /**
     * PROVIDE A VALID TOKENS
     */
    it("Send a message with valid tokens", async () => {
        const res = await Messaging.sendMessage({
            title: "From Node - cli",
            content: "Let's open the screen - with link !!",
            tokens: [
                validToken
            ].join(","),
        });
        // console.log("--> sending via tokens", res);
        expect(res).to.be.an("object");
        expect(res['success']).to.be.equal(1);
        expect(res['error']).to.be.equal(0);
    });
});

describe("Send message to token - both", () => {


    /**
 * PROVIDE A VALID TOKENS
 */
    it("Send a message with valid tokens", async () => {
        const res = await Messaging.sendMessage({
            title: "From Node - cli",
            content: "Let's open the screen - with link !!",
            tokens: [
                validToken,
                "12345Xq5TqG5_VPHJmJtPQ:12345678904Rt1_hD4xlL5SShs-Nr0q06b12345K0cEPWt0GycudJnB0lEo0MOqoRUMCU8vs_ttGbu7r29jZ7mZ_bX0BqUNrDHSdYVyo9vQxKRgTFXZAz2D5km19C_OcKhOWptOmU8mH",
            ].join(","),
        });
        // console.log("--> sending via tokens", res);
        expect(res).to.be.an("object");
        expect(res['success']).to.be.equal(1);
        expect(res['error']).to.be.equal(1);
    });


});
