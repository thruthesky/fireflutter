# Realtime Database Chat

## TODO

For group chat,

- when a user enters the group chat, (done)

  - update room info under /chat-rooms/my-uid/group-chat-id
  - update /chat-rooms/group-chat-id/users/{my-uid: true}

- when a user leaves, (done)

  - delete room /chat-rooms/my-uid/group-chat-id
  - delete /chat-rooms/group-chat-id/users/{my-uid}

- when a chat message is sent, (done)

  - save a message under /chat-messages/group-chat-id
  - update the last message to all the chat room member's /chat-room/uid/group-chat-id and do the following works (like incrementing new message, sending push notifications)
  - but don't save the last message under /chat-rooms/group-chat-id/uid

- When a group is being created, (in progress)

  - Update room under /chat-rooms/my-uid/groupd-id
  - Update a document under /chat-rooms/group-id
    - save my uid in /chat-rooms/group-id/users/{my-uid: true}
    - save isGroupChat to true
    - save isOpenGroupChat to true or false.
    - save room name
    - save createdAt

- Fix sorting in chat room list (in progress)

  - sort by last message's createdAt?

