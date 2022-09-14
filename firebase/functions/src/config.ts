import { EventName } from "./event-name";

export class Config {
  static maximumCommentCreationPoint = 35;
  static pointEvent = {
    [EventName.postCreate]: {
      within: 60 * 60 * 2, // two hour
    },
    [EventName.commentCreate]: {
      within: 25 * 60, // 25 minutes
    },
  };
}
