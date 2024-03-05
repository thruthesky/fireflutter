# Testing

## Test cloud functions locally

To run the cloud functions locally, you will need to export `GOOGLE_APPLICATION_CREDENTIALS` with the service account.

```sh
% export GOOGLE_APPLICATION_CREDENTIALS=../../apps/momcafe/tmp/service-account.json
```

Refer to the test code tests/user/phoneNumberRegister.spec.ts for writing test code.

Refer to the package.json file for running the test code.

## FCM tests

- For sending push notification locally, see `firebase/functions/src/test/send-message.ts`
