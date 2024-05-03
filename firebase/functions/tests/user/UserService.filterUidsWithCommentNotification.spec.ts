import { describe, it } from "mocha";
import { firebaseWithcenterTest2OnlineInit } from "../firebase-withcenter-test-2-online.init";
import { createTestUser } from "../test-functions";
import { UserService } from "../../src/user/user.service";
import * as assert from "assert";

firebaseWithcenterTest2OnlineInit();


describe("UserService.filterUidsWithCommentNotification.spec.ts", () => {
    it("Create users with tokens and check with the new comment notification options", async () => {
        const a = await createTestUser();
        const b = await createTestUser({ commentNotification: true });
        const c = await createTestUser({ commentNotification: false });
        const d = await createTestUser({ commentNotification: true });
        const e = await createTestUser();
        const f = await createTestUser({ commentNotification: true });

        const uids = await UserService.filterUidsWithCommentNotification([a, b, c, d, e, f]);

        assert.ok(uids.length == 3 && uids.includes(b) && uids.includes(d) && uids.includes(f));
    });
});

