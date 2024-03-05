# Reporting

Users can report posts, comments, chats, and other users.

When a report is made, the report information is stored in `/reports/<id>`. For reference, you can check the `Report.create()` code to see how reporting is implemented.

By default, the stored fields include `uid` and `createdAt`. `uid` represents the UID of the reporter, while `createdAt` indicates the time of the report.

When storing the reported data, it is distinguished based on the fields:

- When reporting another user, the UID of the reported user is stored in the `otherUserUid` field.
- When reporting a post, the corresponding post ID is stored in the `postId` field.
- When reporting a comment, the ID of the comment is stored in the `commentId` field.
- When reporting a chat room, the ID of the chat room is stored in the `chatRoomId` field.

Multiple reports can be made for the same item. In other words, a single comment can be reported multiple times. Additionally, users can report their own profiles, posts, comments, etc.

## Reporting Users

- To report a user

```dart
final re = await input(
    context: context,
    title: T.reportInputTitle.tr,
    subtitle: T.reportInputMessage.tr,
    hintText: T.reportInputHint.tr,
);
if (re == null || re == '') return;
await ReportService.instance.report(otherUserUid: user.uid, reason: re);
```

## Reporting a Chat Room

```dart
final re = await input(
    context: context,
    title: T.reportInputTitle.tr,
    subtitle: T.reportInputMessage.tr,
    hintText: T.reportInputHint.tr,
);
if (re == null || re == '') return;
await ReportService.instance.report(chatRoomId: chat.room.id, reason: re);
```

## Reporting a Post

```dart
TextButton(
    onPressed: () async {
        final re = await input(
        context: context,
        title: T.reportInputTitle.tr,
        subtitle: T.reportInputMessage.tr,
        hintText: T.reportInputHint.tr,
        );
        if (re == null || re == '') return;
        await ReportService.instance.report(
        postId: post.id,
        category: post.category,
        reason: re,
        );
    },
    child: const Text('신고'),
),
```

## Reporting a Comment

Check this example:

```dart
ElevatedButton(
    onPressed: () async {
        // Ask user the reason why he reports.
        final re = await input(
            context: context,
            title: T.reportInputTitle.tr,
            subtitle: T.reportInputMessage.tr,
            hintText: T.reportInputHint.tr,
        );
        // If the user submits
        if (re == null || re == '') return;
        await ReportService.instance.report(
            commentId: widget.comment.id,
            reason: re,
        );
        if (mounted) {
            toast(context: context, message: 'You have reported this comment.');
        }
    },
    child: Text(T.report.tr),
),
```

## My Reported History

You can use `ReportMyListView` for this.

## Reviewing Reported Lists by Administrators
