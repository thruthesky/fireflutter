"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.createTestUser = exports.initFirebaseAdminSDK = void 0;
const firebase_admin_1 = __importDefault(require("firebase-admin"));
// import serviceAccount from "../service-account.json";
/**
 * Initialize the Firebase Admin SDK
 *
 * @returns admin
 */
function initFirebaseAdminSDK() {
    if (firebase_admin_1.default.apps.length === 0) {
        firebase_admin_1.default.initializeApp(
        // {
        // credential: admin.credential.cert(serviceAccount as admin.ServiceAccount),
        // databaseURL:
        //     "https://withcenter-test-2-default-rtdb.asia-southeast1.firebasedatabase.app",
        // }
        );
    }
    return firebase_admin_1.default;
}
exports.initFirebaseAdminSDK = initFirebaseAdminSDK;
/**
 * Create a test user
 * @param options optoins
 * @returns user
 */
async function createTestUser(options) {
    if (!options)
        options = {};
    // generate a random email address if one is not provided
    if (!(options === null || options === void 0 ? void 0 : options.email)) {
        options.email = `${Math.random().toString(36).substring(7)}@test.com`;
    }
    const password = options.password || "t~12345a";
    // generate a random phone number if one is not provided
    if (!(options === null || options === void 0 ? void 0 : options.phoneNumber)) {
        // generate a random 8 digit number using Math.random
        const num = Math.floor(Math.random() * 90000000) + 10000000;
        options.phoneNumber = `+8210${num}}`;
    }
    const user = await firebase_admin_1.default
        .auth()
        .createUser({ email: options.email, password, phoneNumber: options.phoneNumber });
    //
    return user;
}
exports.createTestUser = createTestUser;
//# sourceMappingURL=setup.js.map