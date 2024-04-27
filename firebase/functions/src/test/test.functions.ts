
import { onValueCreated } from "firebase-functions/v2/database";
import { onRequest } from "firebase-functions/v2/https";

/**
 * 
 */
export const testEvent = onValueCreated(
    "test/{id}",
    async (event) => {
        // Grab the current value of what was written to the Realtime Database.
        const data = event.data.val() as any;
        console.log(data);


        event.data.ref.set({ response: "Hello, World!" });
    });



/**
* 토큰을 입력받아서 메시지를 전송한다.
*/
export const hello = onRequest(async (request, response) => {

    console.log("request query params: ", request.query);
    response.send({ response: "Hello, World! How are you?" });

});
