# Report


Users can report another user, post, comment, chat room.

- To report a user
```dart
ElevatedButton(
    onPressed: () async {
        final re = await input(
            context: context,
            title: T.reportInputTitle.tr,
            subtitle: T.reportInputMessage.tr,
            hintText: T.reportInputHint.tr,
        );
        if (re == null || re == '') return;
        await ReportService.instance.report(otherUserUid: uid, reason: re);
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