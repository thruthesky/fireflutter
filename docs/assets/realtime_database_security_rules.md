```json
{
  "rules": {
    "test": {
      ".read": true,
      ".write": true
    },
    // Action
    "action-logs": {
      "chat-join": {
        ".read": true,
        ".write": true
      },
      "comment-create": {
        "$uid": {
          ".read": "$uid === auth.uid",
          ".write": "$uid === auth.uid"
        }
      },
      "post-create": {
        "$uid": {
          "$category": {
            ".read": "$uid === auth.uid",
            ".write": "$uid === auth.uid"
          }
        }
      },
      "user-profile-view": {
        "$uid": {
          ".read": "$uid === auth.uid",
          ".write": "$uid === auth.uid"
        }
      }
    },
      
    // Activity
    "activity-logs": {
      "$uid": {
        "$activityName": {
          "$dataDockey": {
            ".read": "$uid === auth.uid",
            ".write": "$uid === auth.uid || newData.child('otherUserUid').val() === auth.uid"
          }
        }
      }
    },
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
        "isDisabled": {
          ".validate": "root.child('admins').hasChild(auth.uid)"
        }
      },
      ".indexOn": ["gender","nationality","region", "birthYear"]
    },
    "who-like-me": {
      ".read": true,
      ".write": true
    },
    "who-i-like": {
      ".read": true,
      ".write": true
    },
   "mutual-like":{
     ".read": true,
       "$uid": {
         ".write": true
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
    "user-private": {
      "$uid": {
        ".read": "$uid === auth.uid || root.child('admins').hasChild(auth.uid)",
        ".write": "$uid === auth.uid"
      }
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
          // ".indexOn": ["order", "uid"]
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
        ".write": true,
        ".indexOn": "order"
      },
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
        "uid": {
          ".validate": "data.child('uid').val() === auth.uid"
        },
        "urls": {
          ".validate": "data.child('uid').val() === auth.uid"
        },
          // 이것은 Fireflutter 에서 post 글을 볼 때, 자동 생성되는 것으로 Fireship 에서는 사용되지 않음.
        "seenBy": {
          ".validate": false
        }
      }
    },
    "post-subscriptions": {
        ".read": true,
        "$category": {
          "$uid": {
            ".write": "$uid === auth.uid"
          }
        }
      },
      
    // Fireship - post summary
    "post-summaries": {
      ".read": true,
      ".write": true,
      "$category": {
        ".indexOn": ["order", "createdAt"]
      }
    },
    // for testing only
    "post-summaries-test": {
      ".read": true,
      ".write": true,
      "$category": {
        ".indexOn": ["order", "createdAt", "sort"]
      }
    },
      
    "post-all-summaries": {
      ".read": true,
      ".indexOn": ["order", "createdAt"]
    },
      
    "comments": {
      "$postId": {
        ".read": true,
        "$commentId": {
          // Condition:
          // Create and Update must be done by anyone. noOfLikes field and other fields.
          // Delete must be done by owner.
          ".write": "(newData.exists() && auth.uid !== null) || (!newData.exists() && data.child('uid').val() === auth.uid)",
          "content": {
            // Anyone can create or owner can update/delete.
            ".validate": "!data.exists() || data.parent().child('uid').val() === auth.uid"
          },
          "uid": {
            ".validate": "!data.exists() || data.val() === auth.uid"
          },
          "urls": {
            // 
            ".validate": "!data.exists() || data.parent().child('uid').val() === auth.uid"
          }
        },
        ".indexOn" : ["order"]  
      }
    },
    "bookmarks": {
      "$uid": {
        ".read": "$uid == auth.uid",
        ".write": "$uid == auth.uid"
      }
    },
    // Fireship - reports
    "reports": {
      "$category": {
        ".read": "root.child('admins').hasChild(auth.uid) || (query.orderByChild === 'uid' && query.equalTo === auth.uid)",
        "$dataKey": {
          ".write": "(newData.child('uid').val() === auth.uid || data.child('uid').val() === auth.uid) || root.child('admins').hasChild(auth.uid)",
          ".indexOn": ["uid"]
        }
      }
    }
  }
}
```