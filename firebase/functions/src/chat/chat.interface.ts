/**
 * ChatCreateEvent
 *
 * 채팅 메시지가 작성되었을 때 발생하는 이벤트 데이터
 */
export interface ChatCreateEvent {
    createdAt: number;
    id: string;
    order: number;
    roomId: string;
    text?: string;
    url?: string;
    // 채팅 메시지를 보낸 사용자의 uid
    uid: string;
}
