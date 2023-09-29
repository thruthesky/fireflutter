import * as admin from "firebase-admin";
export interface UserDocument {
  uid: string;
  display_name: string;
  name?: string;
  phone_number?: string;
  email?: string;
  created_time: admin.firestore.Timestamp;
  photo_url?: string;
  coverPhotoUrl?: string;
  gender: string;
  birth_date: admin.firestore.Timestamp;
  blockedUserList?: Array<string>;
  command?: "delete" | "disable";
}
export interface UserPublicDataDocument {
  uid: string;
  display_name: string;
  created_time: admin.firestore.Timestamp;
  photo_url: string;
  gender: string;
  birth_date: admin.firestore.Timestamp;
  blockedUserList?: Array<string>;
  command?: "delete" | "disable";
}

export interface UserSettingsDocument {
  action: string;
  category: string;
  type?: string;
  uid: string;

}
