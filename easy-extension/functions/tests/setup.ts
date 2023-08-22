import admin from "firebase-admin";
import { UserModel } from "../src/models/user.model";
// import serviceAccount from "../service-account.json";

/**
 * Initialize the Firebase Admin SDK
 * 
 * @returns admin
 */
export function initFirebaseAdminSDK() {
    if (admin.apps.length === 0) {
        admin.initializeApp(
            {
                databaseURL: 'https://withcenter-test-2-default-rtdb.asia-southeast1.firebasedatabase.app/',
            }
            // {
            // credential: admin.credential.cert(serviceAccount as admin.ServiceAccount),
            // databaseURL:
            //     "https://withcenter-test-2-default-rtdb.asia-southeast1.firebasedatabase.app",
            // }
        );
    }
    return admin;
}

/**
 * Create a test user
 * @param options optoins
 * @returns user
 */
export async function createTestUser(options?: { email?: string | null; password?: string | null, phoneNumber?: string | null, displayName?: string | null })
    : Promise<admin.auth.UserRecord> {
    if (!options) options = {};

    // generate a random email address if one is not provided
    if (!options?.email) {
        options.email = `${Math.random().toString(36).substring(7)}@test.com`;
    }

    const password = options.password || "t~12345a";

    // generate a random phone number if one is not provided
    if (!options?.phoneNumber) {
        // generate a random 8 digit number using Math.random
        const num = Math.floor(Math.random() * 90000000) + 10000000;
        options.phoneNumber = `+8210${num}}`;
    }

    const user = await admin
        .auth()
        .createUser({
            email: options.email, password, phoneNumber: options.phoneNumber,
            displayName: options.displayName,
        });

    //
    return user;
}



/**
 * Create a user document under /users collection in Firestore and return the user document as in JSON.
 */
export async function createTestUserDocument(options?: { email?: string | null; password?: string | null, phoneNumber?: string | null, displayName?: string | null })
    : Promise<Record<string, any>> {
    const user = await createTestUser(options);
    const data = {
        uid: user.uid,
        email: user.email ?? '',
        phoneNumber: user.phoneNumber ?? '',
        displayName: user.displayName ?? '',
        photoUrl: user.photoURL ?? '',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await admin.firestore().collection("users").doc(user.uid).set(data);

    return await UserModel.getDocument(user.uid) as Record<string, any>;
}