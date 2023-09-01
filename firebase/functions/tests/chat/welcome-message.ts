import "mocha";
import { expect } from "chai";
import { Chat } from "../../src/models/chat.model";

import "../firebase.init";
import { Setting } from "../../src/models/setting.model";

describe("Chat - welcome message", () => {
  it("Send welcome message", async () => {
    const re = await Chat.sendWelcomeMessage("fjsrDWnR8jZv3DMjLifKvAKJzgw2");
    expect(re).to.be.a("string");

    const room = await Chat.getRoom(re ?? "");
    expect(room).to.be.an("object");

    const system = await Setting.getSystemSettings();
    expect(system.welcomeMessage).equals(room.last_message);
  });
});
