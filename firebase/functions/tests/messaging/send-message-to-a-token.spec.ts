import "mocha";

import "../firebase.init";

import { Messaging } from "../../src/models/messaging.model";
import { expect } from "chai";
import { Ref } from "../../src/utils/ref";

describe("Send message to token - link", () => {
  it("Send a message with tokens", async () => {
    const res = await Messaging.sendMessage({
      title: "From Node - cli",
      content: "Let's open the screen - with link !!",
      tokens: [
        "eKPVLrXRQsmtVus-BLIPcg:APA91bH62HbpJIvr7BehwWkPmtM9Ij4uOgpdfGuioeWsCWpz232CNse6CcewortmAJ0gpcv90Pv92DegoFPNY5-EcrcW1QvV3wnTeZ188SpsuBkgLb1PE1AvadE-Ny9B-ixgor0eqlf5",
      ].join(","),
      chatRoomDocumentReference: Ref.chatRoomDoc(
        "hKLeEL4OykYHUi5XrYA56oryWYQ2-z38rRl8IqJhe0qW8tqh95i0L2HI2"
      ),
    });
    console.log("--> sending via tokens", res);
    expect(res).to.be.an("object");
  });
});
