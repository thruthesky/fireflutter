# Realtime Database Chat

## TODO

For group chat,

- when a user enters the group chat,

  - update room info under /chat-rooms/my-uid/group-chat-id
  - update /chat-rooms/group-chat-id/users/{my-uid: true}

- when a user leaves,

  - delete room /chat-rooms/my-uid/group-chat-id
  - delete /chat-rooms/group-chat-id/users/{my-uid}

- when a chat message is sent,

  - save a message under /chat-messages/group-chat-id
  - update the last message to all the chat room member's /chat-room/uid/group-chat-id and do the following works (like incrementing new message, sending push notifications)
  - but don't save the last message under /chat-rooms/group-chat-id/uid

- When a group is being created,
  - Update room under /chat-rooms/my-uid/groupd-id
  - Update a document under /chat-rooms/group-id
    - save my uid in /chat-rooms/group-id/users/{my-uid: true}
    - save isGroupChat to true
    - save isOpenGroupChat to true or false.
    - save room name
    - save createdAt

## Structure

The TODO above is not implemented yet. The current structure may be changed.

The chat-rooms is used for the rooms for individual users. The structure is like this: `/chat-rooms/${uid}/${chatRoomId}`.

For the messages in a chat room: `/chat-room-details/${chatRoomId}/messeges/`.

For room details, we put it `/chat-room-details/${chatRoomId}/`.

Example record will be:

```json
chat-rooms: {
    uid-1: {
        chatRoomId-1: {
            isGroupChat: false,
            newMessageCount: 0,
            order: -1,
            text: 'Hello',
            updateAt: 123456789,
        },
    },
},
chat-room-details: {
    chatRoomId-1: {
        createdAt: 123456789,
        isGroupChat: false,
        isOpenGroupChat: false,
        text: 'Hello',
        updateAt: 123456789,
        name: 'John',
        users: {
            uid-1: true,
            uid-2: true,
        },
        messages: {
            messageId-1: {
            createdAt: 123456789,
            text: 'Hello',
            uid: 'uid-1',
            },
        },
    },
}

```
