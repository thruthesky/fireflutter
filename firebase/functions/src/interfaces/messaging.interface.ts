export interface SendMessage {
  id?: string; // / postId
  postId?: string; // postId from comment.
  uid?: string; // / added by 'auth' in flutter.
  users?: string[];
  tokens?: string;
  topic?: string;
  title?: string;
  body?: string; // message body
  content?: string; // this will be used as message body if message body is empty.
  type?: string;
  senderUid?: string; // / uid
  badge?: string;
  icon?: string; // imageUrl
  clickAction?: string; // customize web click action
}

export interface MessagePayload {
  topic?: string;
  token?: string;
  data: {
    id?: string;
    type?: string;
    senderUid?: string;
    badge?: string;
    [key: string]: any;
  };
  notification: {
    title: string;
    body: string;
  };
  webpush: {
    notification: {
      title: string;
      body: string;
      icon?: string;
      /* eslint-disable camelcase */
      click_action: string;
    };
    /* eslint-disable camelcase */
    fcm_options: {
      link: string;
    };
  };
  android: {
    notification: {
      /* eslint-disable camelcase */
      channel_id?: string;
      /* eslint-disable camelcase */
      click_action?: string;
      sound?: string;
    };
  };
  apns: {
    payload: {
      aps: {
        sound: string;
        badge?: number;
      };
    };
  };
}
