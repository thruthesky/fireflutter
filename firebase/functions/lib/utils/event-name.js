"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AdminNotificationOptions = exports.EventType = exports.EventName = void 0;
class EventName {
}
exports.EventName = EventName;
EventName.postCreate = "postCreate";
EventName.commentCreate = "commentCreate";
EventName.chatCreate = "chatCreate";
EventName.chatDisabled = "chatDisabled";
EventName.userCreate = "userCreate";
EventName.reportCreate = "reportCreate";
class EventType {
}
exports.EventType = EventType;
EventType.post = "post";
EventType.chat = "chat";
EventType.user = "user";
EventType.report = "report";
class AdminNotificationOptions {
}
exports.AdminNotificationOptions = AdminNotificationOptions;
AdminNotificationOptions.notifyOnNewUser = "notifyOnNewUser";
AdminNotificationOptions.notifyOnNewReport = "notifyOnNewReport";
//# sourceMappingURL=event-name.js.map