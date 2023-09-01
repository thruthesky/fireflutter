// import "mocha";
// import "../firebase.init";

// import { Messaging } from "../../src/models/messaging.model";

// import { Test } from "../test";
// import { User } from "../../src/models/user.model";

// import { expect } from "chai";
// import * as admin from "firebase-admin";

// describe("Messaging", () => {
//     it("Remove tokens", async () => {
//         /// Clear existing tokens to test.
//         await Messaging.removeTokens(["token-a-1", "token-a-2", "token-b-1", "token-b-2"]);

//         const uidA = "user-a-" + Test.id();
//         await User.create(uidA, {});
//         await User.setToken({
//             fcm_token: "token-a-1",
//             device_type: "android",
//             uid: uidA,
//         });
//         await User.setToken({
//             fcm_token: "token-a-2",
//             device_type: "android",
//             uid: uidA,
//         });

//         const uidB = "user-b-" + Test.id();
//         await User.create(uidB, {});
//         await User.setToken({
//             fcm_token: "token-b-1",
//             device_type: "android",
//             uid: uidB,
//         });
//         await User.setToken({
//             fcm_token: "token-b-2",
//             device_type: "android",
//             uid: uidB,
//         });

//         await Messaging.removeTokens(["token-a-1", "token-b-2"]);

//         let snapshot = await admin
//             .firestore()
//             .collectionGroup("fcm_tokens")
//             .where("fcm_token", "==", "token-a-1")
//             .get();
//         expect(snapshot.docs.length).equals(0);
//         snapshot = await admin
//             .firestore()
//             .collectionGroup("fcm_tokens")
//             .where("fcm_token", "==", "token-a-2")
//             .get();
//         expect(snapshot.docs.length).equals(1);
//         snapshot = await admin
//             .firestore()
//             .collectionGroup("fcm_tokens")
//             .where("fcm_token", "==", "token-b-1")
//             .get();
//         expect(snapshot.docs.length).equals(1);
//         snapshot = await admin
//             .firestore()
//             .collectionGroup("fcm_tokens")
//             .where("fcm_token", "==", "token-b-2")
//             .get();
//         expect(snapshot.docs.length).equals(0);
//     });
// });