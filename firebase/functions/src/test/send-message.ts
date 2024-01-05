import { initializeApp } from "firebase-admin/app";
import { MessagingService } from "../messaging/messaging.service";


/// initialize firebase app
initializeApp();

console.log('Nothing shows up?');

(async () => {
    const res = await MessagingService.sendNotificationToTokens([
        /// iPhone11ProMax
        // "fVWDxKs1kEzxhtV9ElWh-5:APA91bE_rN_OBQF3KwAdqd6Ves18AnSrCovj3UQyoLHvRwp0--1BRyo9af8EDEWXEuzBneknEFFuWZ7Lq2VS-_MBRY9vbRrdXHEIAOtQ0GEkJgnaJqPYt7TQnXtci3s0hxn34MBOhwSK",
        /// andriod with initail uid of W7a
        "c9OPdjOoRtqCOXVG7HLpSI:APA91bFJ9VshAvx-mQ4JsIpFmkljnA4XZtE8LDw6JYtIWSJwSxnuJsHt0XtlHKy4wuRcttIzqPQckfAwX_baurPfiJuFFNS6ioD50X9ks5eeyi5Pl40vMWmCpNpgCVxg92CjRe5S51Ja",
        // TEST empty token
        "",
        // TEST invalid token
        "This-is-invalid-token"
    ], "Hello, from test",
        "How are you?",
       {
        score: '30',
        time: "10:24",
        title: 'score on test'
       }
    );
    
    console.log('res', res);
})();