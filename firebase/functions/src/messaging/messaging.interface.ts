
export interface MessageNotification {
    title: string;
    body: string;
    image?: string;
}

/**
 *
 */
export interface MessageRequest extends MessageNotification {
    tokens: Array<string>;
    data?: { [key: string]: string };
}

/**
 * Inteface for sendNotificationToUids
 */
export interface NotificationToUids {
    uids: Array<string>;
    chunkSize: number;
    title: string;
    body: string;
    image?: string;
    data: { [key: string]: string };
}



export interface SendEachMessage {
    notification: MessageNotification;
    data: {
        [key: string]: string;
    };
    token: string;
    success?: boolean;
    code?: string;
}


export interface PostCreateMessage {
    id: string;
    category: string;
    title: string;
    body: string;
    uid: string;
    image: string;
}

export interface UserLikeEvent {
    uid: string;
    otherUid: string;
}
