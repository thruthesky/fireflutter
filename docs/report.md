# Report


Users can report another user, post, comment, chat room.

- To report a user
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

- To report a chat room

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

- To report a post

```dart
```