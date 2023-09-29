export class EventName {
  static postCreate = "postCreate";
  static commentCreate = "commentCreate";
  static chatCreate = "chatCreate";
  static chatDisabled = "chatDisabled";
  static userCreate = "userCreate";
  static reportCreate = "reportCreate";
}

export class EventType {
  static post = "post";
  static chat = "chat";
  static user = "user";
  static report = "report";
}


export class AdminNotificationOptions {
  static notifyOnNewUser = "notifyOnNewUser";
  static notifyOnNewReport = "notifyOnNewReport";
}
