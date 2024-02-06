# Install

Follow the instruction below to install Fireship into your app

## Install Fireship

### Install Fireship as a package

Simply add the latest version of fireship from pub.dev

### Install Fireship as a package developer

You may wish to develop your app while building(or updating) the Fireship package together.

- Fork the Fireship from `https://github.com/thruthesky/fireship`

- Then, clone it

- Then, create a branch in Fireship local repository

- Create `apps` folder under the root of Fireship folder and create your app inside `apps` folder.

```dart
mkdir apps
cd apps
flutter create your_project
```

- You need to add the path of the dependency as `../..`. Add the fireship dependency like below.

```yaml
dependencies:
  fireship:
    path: ../..
```

- If you have update any code in Fireship, consider to submit a `pull request`.

## Install Firebase Realtime Database Secuirty

Copy below and paste it into your firebase project.

```json
{
  "rules": {
    // Fireship admins
    "admins": {
      ".read": true,
      ".indexOn": ".value"
    },
    // Fireship users
    "users": {
      ".read": true,
      "$uid": {
        ".write": "$uid === auth.uid || root.child('admins').hasChild(auth.uid)",
        "isAdmin": {
          ".validate": "root.child('admins').hasChild(auth.uid)"
        }
      }
    },
      // Fireship - users who have profile photos. To display users who has profile photo.
    "user-profile-photos": {
      ".read": true,
      "$uid": {
        ".write": "$uid === auth.uid"
      },
      ".indexOn": ["updatedAt"]
    },
      // Fireship - device FCM tokens
    "user-fcm-tokens": {
      ".read": true,
        // Token may be deleted by other users if there is error on the token.
      ".write": true,
      ".indexOn": ["uid"]
    },
    // Fireship - device FCM tokens
    "user-fcm-tokens-test": {
      ".read": true,
        // Token may be deleted by other users if there is error on the token.
      ".write": true,
      ".indexOn": ["uid"]
    },
      // Fireship - user settings
    "user-settings": {
      ".read": true,
      "$uid": {
        ".write": "$uid === auth.uid"
      }
    },
      // Fireship - chat 2023-11-25 RTDB 로 채팅 제작
    "chat-messages": {
      
      "$room_id": {
          ".read": "root.child('chat-rooms').child($room_id).child('users').hasChild(auth.uid)",
          "$message_id": {
            // if login and if it's my data, and if I joined the room.
            ".write": "auth != null && (data.child('uid').val() === auth.uid || newData.child('uid').val() === auth.uid) && root.child('chat-rooms').child($room_id).child('users').hasChild(auth.uid)"
           },
          ".indexOn": ["order", "uid"]
      }
    },
    "chat-rooms": {
      ".read": true,
      "$roomId": {
        ".write": true,
        "users": {
          ".indexOn": ".value"
        }
      }
    },
    "chat-joins": {
      ".read": true,
      "$uid": {
        ".write": true
      }
    },
      // Fireship - reports
    "reports": {
      "$uid": {
        ".read": "$uid === auth.uid || root.child('admins').hasChild(auth.uid)",
        ".write": "$uid === auth.uid || root.child('admins').hasChild(auth.uid)"
      }
    },
      
      // Fireship - posts
    "posts": {
      ".read": true,
      "$category": {
        ".write": true,
        "title": {
          ".validate": "data.child('uid').val() === auth.uid"
        },
        "content": {
          ".validate": "data.child('uid').val() === auth.uid"
        },
          // 이것은 Fireflutter 에서 post 글을 볼 때, 자동 생성되는 것으로 Fireship 에서는 사용되지 않음.
        "seenBy": {
          ".validate": false
        }
      }
    },
      "posts-subscription": {
        ".read": true,
        "$category": {
          "$uid": {
            ".write": "$uid === auth.uid"
          }
        }
      },
      
    // Fireship - post summary
    "posts-summary": {
      ".read": true,
      ".write": true,
      "$category": {
        ".indexOn": ["order"]
      }
    },
      
    "posts-all-summary": {
      ".read": true
    }
  }
}
```



## Default app-environment entitlement

Add the following code into `info.plist`. These will be needed for access to camera and gallery.

```xml
<key>NSCameraUsageDescription</key>
<string>PhiLov app requires access to the camera to share the photo on profile, chat, forum.</string>
<key>NSMicrophoneUsageDescription</key>
<string>PhiLov app requires access to the microphone to share vioce with other users.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>PhiLov app requires access to the photo library to share the photo on profile, chat, forum.</string>
```



## Install Cloud Functions

Run the following command to install all the push notification cloud functions.

```sh
% cd firebase/function
% npm run deploy:message
```

And set the end point URL to `MessagingService.instance.init(sendPushNotificationsUrl: ..)`


Run the following command to install typesense related cloud functions.

```sh
% cd firebase/function
% npm run deploy:typesense
```


Run the following command to install a function that manages summarization of all posts under `/posts-all-summary`.
See the [Forum](forum.md) document for the details.

```sh
% cd firebase/function
% npm run deploy:managePostsAllSummary
```


## Initializing TextService

Fireship has some UI and you may want to show it in different languages.

And you can use the text translation funtionality in your app.

```dart

/// Call this somewhere while the app boots.
initTextService();

void initTextService() {
  print('--> AppService.initTextService()');

  TextService.instance.texts = {
    ...TextService.instance.texts,
    if ( languageCode == 'ko' ) ...{
      T.ok: '확인',
      T.no: '아니오',
      T.yes: '예',
      T.error: '에러',
      T.dismiss: '닫기',
      Code.profileUpdate: '프로필 수정',
      Code.recentLoginRequiredForResign:
          '회원 탈퇴는 본인 인증을 위해서, 로그아웃 후 다시 로그인 한 다음 탈퇴하셔야합니다.',
      Categories.qna: '질문',
      Categories.discussion: '토론',
      Categories.buyandsell: '장터',
      Categories.info: '정보/알림',
      T.notVerifiedMessage: '본인 인증을 하셔야 전체 기능을 이용 할 수 있습니다.',
      T.chatRoomNoMessageYet: '앗, 아직 메시지가 없습니다.\n채팅을 시작 해 보세요.',
    },
    if ( languageCode == 'en' ) ...{
      T.ok: 'Ok',
      // ...
    }
  };
}
```

## Initializing UserService






## Admin

- See [Admin Doc](admin.md)


## Unit tests

- There are many unit test codes. You can read other document of fireship on how to install and test the unit test codes.
