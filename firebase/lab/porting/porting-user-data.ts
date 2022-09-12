import * as admin from "firebase-admin";
import { InitializeFirebaseTestProject } from "../initialize-firebase-test-project";

new InitializeFirebaseTestProject();

port_user_data().then(() => {
  process.exit();
});

async function port_user_data() {
  const snapshot = await admin.database().ref("users").get();
  console.log(snapshot.val());
}
