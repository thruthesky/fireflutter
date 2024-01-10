
export interface MessageNotification {
    title: string;
    body: string;
    image?: string;
}

export interface MessageRequest extends MessageNotification {
    tokens: Array<string>;
    data?: { [key: string]: string };
}
