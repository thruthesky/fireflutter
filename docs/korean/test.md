# 테스트

## 함수를 로컬 컴퓨터에서 실행하는 방법

`GOOGLE_APPLICATION_CREDENTIALS` 환경 변수에 service account 저장해야 한다.

예제

```sh
% export GOOGLE_APPLICATION_CREDENTIALS=../../apps/momcafe/tmp/service-account.json
```

테스트 코드 작성은 `tests/user/phoneNumberRegister.spec.ts` 테스트 코드를 참고한다.

테스트 코드 실행은 `package.json` 파일을 참고한다.

## FCM 테스트

- 로컬에서 push notification 테스트 하려면,
  - 먼저, GOOGLE_APPLICATION_CREDENTIALS 에 키를 설정합니다.
    - `export GOOGLE_APPLICATION_CREDENTIALS=~/Documents/Keys/Firebase-Service-Accounts/xxxx.json`
    - 그리고, `firebase/functions/src/test/send-a-message.ts` 를 통해서 메시지를 보냅니다.


### Token 아이디로 푸시 메시지 전송


- `firebase/functions/tests/message/send--amessage.spec.ts` 에 테스트 코드가 있다. 이 안의 `tokens` 배열에 토큰을 추가하고, `% npm run test:send-a-message` 를 호출하면 된다. 그러면 해당 token 의 디바이스로 메시지가 와야 한다.
  - 참고로 실행을 할 때에는 위의 `GOOGLE_APPLICATION_CREDENTIALS` 에 적절한 키 값을 지정해야 한다.




## 클라우드 함수 테스트 코드 작성 방법

- 다음은 테스트 코드 예제이다.
- GOOGLE_APPLICATION_CREDENTIALS 를 지정하고, 아래 코드를 실행하면 된다.
- 테스트 할 때에는 `package.json` 에 테스트 스크립트를 추가해서 편하게 테스트 코드 실행하면 된다.


```ts
/**
 *
 * To test, run the following command:
 * ```
 * npm run test:userDeleteAccount
 * ```
 */
import * as admin from "firebase-admin";
import { describe, it } from "mocha";
import assert = require("assert");
import { UserService } from "../../src/user/user.service";
import { Config } from "../../src/config";


if (admin.apps.length === 0) {
    admin.initializeApp({
        databaseURL: "https://xxxxxxx-default-rtdb.firebaseio.com", /// <-- 수정 필요
    });
}

describe("user delete account test", () => {
    it("delete with wrong user uid -> auth/user-not-found", async () => {
        const uid = "wrong-user-uid";
        const db = admin.database();
        try {
            await UserService.deleteAccount(uid);
            const snapshot = await db.ref(`${Config.commands}/${uid}`).get();
            console.log("snapshot.val()", snapshot.val());
            assert.ok(snapshot.val()["deleteAccountResult"] === false, "...");
        } catch (e) {
            // console.error(e);
            assert.ok((e as any).code === "auth/user-not-found", "...");
        }
    });

    it("delete with real user uid", async () => {
        // 1. Create user account with email/password in Firebase Auth
        const auth = admin.auth();
        const userRecord = await auth.createUser({
            email: "test" + (new Date).getTime() + "@email.com",
            password: "password12345a,*",
        });

        const db = admin.database();
        try {
            await UserService.deleteAccount(userRecord.uid);
            const snapshot = await db.ref(`${Config.commands}/${userRecord.uid}`).get();
            assert.ok(snapshot.val()["deleteAccountResult"] === true, "...");
        } catch (e) {
            // console.error(e);
            assert.ok((e as any).code === "----", "...");
        }
    });
});


```