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

- 로컬에서 push notification 테스트 하려면, `firebase/functions/src/test/send-message.ts` 를 참고한다.
