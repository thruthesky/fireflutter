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

