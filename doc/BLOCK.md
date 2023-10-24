# Block

A user can block another user. When A blocks B, the app should not show any content from B to A.

For instance, B commented C1 under a post P1 and A blocked B.

When A open P1, how the C1 should be displayed to A?

- B's profile photo should be hidden
- B's name should be hidden
- C1's upload should be hidden
- C1's comment should be hidden
- C1's buttons should hidden.

The design must be consistent. So, when the developer list he comments under post view screen or post list screen or even if the developer does his own custom design, the behavior must be consistent.

To make this one, you need to use widgets to display the parts of comment and the widgets have already the logic of visibility for the block users.

The widgets are

- `UserAvatar`
- `UserDisplayName`
- `PostTitle`
- `PostContent`
- `CommentContent`
- `DisplayUploadedFiles` - to display the media(photos, files, etc..) of the url. You can use it for displaying post, comment, and whatever As long as you pass the list of url, it will work. It will also dispay the gallery if the media is being tapped.

When you use these widgets, you don't have to worry about the visibilities for the contents from blocked users.

## Block feature

So what will happen to the blocked user?

- You wont received any notification from the blocked user.
- You wont see any content from the blocked user. (they will appear blocked)
- You wont see any comment from the blocked user. (they will appear blocked)
- You wont see any post from the blocked user. (they will appear blocked)

## User Model feature

Block feature is implemented in the user model. So, you can use the feature by calling the methods of the user model.

### Block a user

For user to block:

```dart
await user.block(otherUserUid);
```

### Unblock a user

```dart
await user.unblock(otherUserUid);
```

### Check if user blocked the other user

```dart
user.hasBlocked(otherUserUid);
```

or

```dart
user.haveBlocked(otherUserUid);
```

## Firestore rule

There are no default firestore rules for blocking since it is not a critical security rule.

## Widgets

### UserBlock

UserBlock is a widget that provides a builder if blocked and provides a builder if not blocked. See the example code below.

```dart
UserBlock(
  uid: user.uid,
  builder: (context, isBlocked) {
    if (isBlocked) {
      return Text('You blocked this user.');
    } else {
      return Text('You did not block this user.');
    }
  },
);
```
