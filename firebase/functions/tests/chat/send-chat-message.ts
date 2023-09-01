// import "mocha";
// import { expect } from "chai";

// import * as admin from "firebase-admin";
// import "../firebase.init";

// import { ChatMessageDocument } from "../../src/interfaces/chat.interface";
// import { Ref } from "../../src/utils/ref";
// import { Messaging } from "../../src/models/messaging.model";

// describe("Chat - send a message", () => {
//   it("Send a message to a user", async () => {
//     const data: ChatMessageDocument = {
//       chatRoomDocumentReference: admin
//         .firestore()
//         .collection("chat_rooms")
//         .doc("OUY5ByTFqjZ2g6RKgzNan8awPKq2-pk1DqDieXngeahx0OwqqawCI0Gq2"),
//       senderUserDocumentReference: Ref.userDoc("OUY5ByTFqjZ2g6RKgzNan8awPKq2"),
//       text: "Hello, got a message?",
//       timestamp: admin.firestore.Timestamp.now(),
//     };

//     // const WriteResult = await admin
//     //   .firestore()
//     //   .collection("chat_room_messages")
//     //   .add(data);

//     // expect(WriteResult).to.be.an("object");

//     await Messaging.sendChatNotificationToOtherUsers(data);

//     expect(true).to.be.true;
//   });
// });
