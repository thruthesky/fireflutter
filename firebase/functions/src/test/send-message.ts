import { initializeApp } from "firebase-admin/app";
import { MessagingService } from "../messaging/messaging.service";


/// initialize firebase app
initializeApp();

console.log('Nothing shows up?');

(async () => {
    await MessagingService.sendNotificationToTokens([
        /// iPhone11ProMax
        "fVWDxKs1kEzxhtV9ElWh-5:APA91bE_rN_OBQF3KwAdqd6Ves18AnSrCovj3UQyoLHvRwp0--1BRyo9af8EDEWXEuzBneknEFFuWZ7Lq2VS-_MBRY9vbRrdXHEIAOtQ0GEkJgnaJqPYt7TQnXtci3s0hxn34MBOhwSK",
        ///
        "",
    ], "Hello, from test", "How are you?");
})();