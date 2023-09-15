import "mocha";

import "../firebase.init";
// import * as admin from "firebase-admin";

import { expect } from "chai";
import { HttpsError } from "firebase-functions/v1/auth";


import { Messaging } from "../../src/models/messaging.model";
// import { Ref } from "../../src/utils/ref";
// import { Ref } from "../../src/utils/ref";



// const userIdA = "mhwOLEX0YxZa1m2G3dvSu1zQMZz2"; // valid test user id
// const userIdB = "ZhiuNFzR4BNULdY2XvWSx5RaxGl1"; // valid test user id




describe("Send message by actions", () => {
    it("Send message by action", async () => {






        try {
            const data = {
                "uid": "ZhiuNFzR4BNULdY2XvWSx5RaxGl1",
                "text": "again", "isUserChanged": false,
                "createdAt": { "_seconds": 1694696702, "_nanoseconds": 636000000 },
                "roomId": "ZhiuNFzR4BNULdY2XvWSx5RaxGl1-mhwOLEX0YxZa1m2G3dvSu1zQMZz2",
                "type": "chat",
                "action": "chatCreate",
                "title": " send you a message.",
                "body": "again",
                "uids": ["mhwOLEX0YxZa1m2G3dvSu1zQMZz2"],
                "id": "ZhiuNFzR4BNULdY2XvWSx5RaxGl1-mhwOLEX0YxZa1m2G3dvSu1zQMZz2",
                "senderUid": "ZhiuNFzR4BNULdY2XvWSx5RaxGl1",
            };


            const res = await Messaging.sendMessage(data);
            console.log(res);
        } catch (e) {
            console.log((e as HttpsError).code, (e as HttpsError).message);
            expect.fail("Must success on sending a message to a token");
        }
    });
});
