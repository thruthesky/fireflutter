export interface ReportDocument {
    uid: string;
    type: string;
    reason: string;
    createdAt: string;
    commentId?: string;
    postId?: string;
    otherUid?: string;
}
