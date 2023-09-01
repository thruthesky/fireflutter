import "mocha";
import { expect } from "chai";

import * as admin from "firebase-admin";
import "../firebase.init";

import { ChatMessageDocument } from "../../src/interfaces/chat.interface";
import { Ref } from "../../src/utils/ref";
import { Chat } from "../../src/models/chat.model";

describe("Chat - getOtherUserUidsFromChatMessageDocument", () => {
  it("getOtherUserUidsFromChatMessageDocument() test", async () => {
    const data: ChatMessageDocument = {
      chatRoomDocumentReference: admin
        .firestore()
        .collection("chat_rooms")
        .doc("hKLeEL4OykYHUi5XrYA56oryWYQ2-z38rRl8IqJhe0qW8tqh95i0L2HI2"),
      senderUserDocumentReference: Ref.userDoc("hKLeEL4OykYHUi5XrYA56oryWYQ2"),
      text: "Hello, who is there?",
      timestamp: admin.firestore.Timestamp.now(),
    };

    const re = await Chat.getOtherUserUidsFromChatMessageDocument(data);

    expect(re).to.be.an("string");
    expect(re.split(",").length).to.be.equal(1);
    expect(re).equals("z38rRl8IqJhe0qW8tqh95i0L2HI2");
  });
});
