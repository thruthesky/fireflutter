export interface User {
    uid: string;
    displayName: string;
    photoUrl: string;
    isVerified: boolean;
    createdAt: number;
}


/**
 *
 */
export interface UserCreateWithPhoneNumber {
    phoneNumber: string;
}


export interface DeleteAccountResponse {
    code: string;
    message?: string;
    uid: string;
}
