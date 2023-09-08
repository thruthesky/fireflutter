import "mocha";

import "../firebase.init";
// import * as admin from "firebase-admin";

import { expect } from "chai";
import { HttpsError } from "firebase-functions/v1/auth";

// import { User } from "../../src/models/user.model";
// import { Test } from "../test";
import { Messaging } from "../../src/models/messaging.model";
import { SendMessage } from "../../src/interfaces/messaging.interface";
import { EventType } from "../../src/utils/event-name";
// import { Ref } from "../../src/utils/ref";
// import { Ref } from "../../src/utils/ref";






describe("Send message by topic", () => {
    it("Send message by action", async () => {
        try {
            const data: SendMessage = {
                topic: 'allUsers',
                title: 'sending message via topic',
                body: 'send via topic',
                categoryId: 'qna',
                postId: '64mwMdbcHB6nwMCUumuo',
                type: EventType.post
            };

            const result = await Messaging
                .sendMessage(data);
            expect(result).to.be.an("object");
            expect(result['messageId']).to.be.include('projects/');
            console.log("result::", result);
        } catch (e) {
            console.log((e as HttpsError).code, (e as HttpsError).message);
            expect.fail("Must success on sending a message to a topic");
        }
    });
});
