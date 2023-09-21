import "mocha";

import "../firebase.init";

import { expect } from "chai";
import { HttpsError } from "firebase-functions/v1/auth";

// import { User } from "../../src/models/user.model";
import { SendMessage } from "../../src/interfaces/messaging.interface";
import { Messaging } from "../../src/models/messaging.model";
// import { User } from "../../src/models/user.model";






describe("send message on queue", () => {
    it("send message via allUsers topic", async () => {
        const data: SendMessage = {
            title: 'dev3 withcenter visit your profile',
            body: 'Someone visit your profile',
            id: '2ItnEzERcwO4DQ9wxLsWEOan9OU2',
            type: 'user',
            uids: ['GuVDmHEC8xXnEGFwHg95S8bNZuG2'],
            senderUid: '2ItnEzERcwO4DQ9wxLsWEOan9OU2',
        }

        try {
            const result = await Messaging
                .sendMessage(data as SendMessage);
            console.log("result::", result);
            expect(result.success).to.be.equal(1); // have a valid token to be success
            expect(result.error).to.be.equal(0);
        } catch (e) {
            console.log((e as HttpsError).code, (e as HttpsError).message);
            expect.fail("Must success on sending a message to a token");
        }
    });
});
