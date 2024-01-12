# Test

## Test cloud functions locally

To run the cloud functions locally, you will need to export `GOOGLE_APPLICATION_CREDENTIALS` with the service account.

```sh
% export GOOGLE_APPLICATION_CREDENTIALS=../../apps/momcafe/tmp/service-account.json
```

## FCM tests

- For sending push notification locally, see `firebase/functions/src/test/send-message.ts`
