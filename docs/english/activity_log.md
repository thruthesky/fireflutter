# Activity Log

- Logs for whatever user does. Leaves a record of what activities the user did.
- It records activities such as writing posts, commenting, liking, and viewing profiles of logged-in users.
    - However, some activities such as sending chat messages and editing profiles may be excluded.
- In activity log, it is expected to log/record redundantly. For instance, if A likes B, a record is created, and even if A unlikes B, a record is still created, and immediately liking B again results in another record. If you do not want redundant recording, you can use the Action feature.

## Database

- `activity-logs/<uid>/user-profile-view` logs for viewing other users' public profiles.
- `activity-logs/<uid>/user-like` logs for user profile likes.
- `activity-logs/<uid>/post-create` logs for post creation.
- `activity-logs/<uid>/comment-create` logs for comment creation.
- `activity-logs/<uid>/chat-join` logs for entry into chat rooms. Each entry into the same chat room is recorded separately.

Each data has the following structure:

```json
{
  createdAt: ...server-timestamp...
  category: ...,
  postId: ...,
  commentId: ...,
  otherUserUid: ...,
  chatRoomId: ...,
}
```

As shown above:

- Posts, postId and category are stored together.
- Comments, commentId and postId are stored together.
- When viewing another user's profile, the otherUserUid is for the UID of the user being viewed.
- When joining a chat room, the chatRoomId is stored.

Note that profile updates are not being logged. The reason is:

- Profile updates can occur in various forms and from multiple locations. For example, they may happen during mandatory information input or when entering a name in a different UI. Additionally, profile updates can be performed on profile editing pages. Tracking profile updates could lead to confusion regarding where and how frequently they occur, as well as uncertainty about where to apply the corresponding code.

When Firestore is used, if user A likes user B, it's possible for user B to see a list of people who liked them. This functionality is inherent in Firestore's data structure and querying capabilities.

However, with Realtime Database, achieving the same functionality would require restructuring the data, so this feature is not implemented. Of course, it could be achievable by creating a separate data structure.

Furthermore, when A likes B, an activity log is created in the format `activity-logs/<A>/<push-id>/{ createdAt: ..., otherUserUid: B }`. Even if A unlikes and likes B again, a new activity log is created each time. In other words, each like or unlike action generates a new activity log for the user.

Additionally, logging in typically occurs once during registration, but it is not separately recorded. Meaning, when user signed up, it will be recorded as a login activity.

## How to Use

By configuring as follows, the corresponding logs will be recorded:

```dart
ActivityLogService.instance.init(
  userView: true,
  userLike: true,
  postCreate: true,
  commentCreate: true,
);
```

Please note that as of February 26, 2024, there is currently no widget available to display the logs.
