{
  "rules": {
    "test": {
      ".read": true,
      ".write": true
    },
    // Settings
    "settings": {
      "chat-rooms": {
        "$chatRoomId": {
          // 방장(master)만 채팅방 설정을 읽고/수정 할 수 있도록 한다.
          ".read": "root.child('chat-rooms').child($chatRoomId).child('master').val() === auth.uid",
          ".write": "root.child('chat-rooms').child($chatRoomId).child('master').val() === auth.uid"
        }
      }
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


    // Friends
    "friends": {
      ".read": true,
      "$myUid": {
        "$friendUid": {
          ".write": "$myUid == auth.uid || $friendUid == auth.uid"
        }
      }
    },
    "friends-sent": {
      ".read": true,
      "$senderUid": {
        "$receiverUid": {
          ".write": "$senderUid == auth.uid || $receiverUid == auth.uid"
        }
      }
    },
    "friends-received": {
      ".read": true,
      "$receiverUid": {
        "$senderUid": {
          ".write": "$senderUid == auth.uid || $receiverUid == auth.uid"
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
    // 채팅 메시지
    "chat-messages": {
      "$room_id": {
          // 채팅 메시지 읽기 조건 - 채팅방에 들어가 있고, 블럭(차단)되지 않은 사용자 일 것.
          ".read": "root.child('chat-rooms').child($room_id).child('users').hasChild(auth.uid) && root.child('chat-rooms').child($room_id).child('blockedUsers').hasChild(auth.uid) === false",
          "$message_id": {
            // User must signed in &&
            //   if it's my data AND if I joined the room AND I am not blocked.
            //   OR
            //   if I am admin
            //   OR
            //   if I am the master of the chat room.
            ".write": "
            auth != null
            &&
              (
              (( data.child('uid').val() === auth.uid || newData.child('uid').val() === auth.uid ) && root.child('chat-rooms').child($room_id).child('users').hasChild(auth.uid) && root.child('chat-rooms').child($room_id).child('blockedUsers').hasChild(auth.uid) === false )
               || 
               root.child('admins').hasChild(auth.uid)
               || 
               root.child('chat-rooms').child($room_id).child('master').val() == auth.uid
              )"
           },
          // ".indexOn": ["order", "uid"]
      }
    },
    "chat-rooms": {
      ".read": true,
      "$room_id": {
        ".write": true,
        "users": {
          // 비밀번호가 없으면, 입장 가능. 비밀번호가 있거나/없거나 상관없이 퇴장 가능.
          ".validate": "
              (
                root.child('settings').child('chat-rooms').child($room_id).child('password').exists() === false
                ||
                root.child('settings').child('chat-rooms').child($room_id).child('password').val() === ''
              )
              ||
              (
                data.hasChild(auth.uid)
                &&
                newData.hasChild(auth.uid) === false
              )
          ",
          ".indexOn": ".value"
        },
        // admins and master can update "blockedUsers"
        "blockedUsers": {
          ".validate": "root.child('admins').hasChild(auth.uid) || root.child('chat-rooms').child($room_id).child('master').val() == auth.uid"
        },
        // Only master can update "name", "description". If there is no master yet(especially when it is being created), allow name/description to be updated.
        "name": {
          ".validate": "
            root.child('chat-rooms').child($room_id).child('master').val() === null
            ||
            root.child('chat-rooms').child($room_id).child('master').val() == auth.uid
          "
        },
        "description": {
          ".validate": "
            root.child('chat-rooms').child($room_id).child('master').val() === null
            ||
            root.child('chat-rooms').child($room_id).child('master').val() == auth.uid
          "
        },
      }
    },
    "chat-joins": {
      ".read": true,
      "$uid": {
        ".write": true,
        ".indexOn": "order"
      },
    },
    // posts
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
        ".indexOn": ["order", "createdAt", "group_order"]
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
      ".indexOn": ["order", "createdAt", "group_order"]
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