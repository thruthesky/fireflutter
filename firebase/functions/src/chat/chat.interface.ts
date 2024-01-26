
export interface ChatCreateEvent {
    createdAt: number;
    id: string;
    order: number;
    roomId: string;
    text?: string;
    url?: string;
    uid: string;
}