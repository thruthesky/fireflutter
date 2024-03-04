# 신고

사용자는 글, 코멘트, 채팅, 사용자 등을 신고 할 수 있다.

신고를 하면 `/reports/<id>` 에 신고 정보가 저장된다. 참고로, 신고하는 코드는 `Report.create()` 을 보면 된다.

기본적으로 저장되는 필드는 `uid` 와 `createdAt` 이 있다. `uid` 는 신고자의 uid 이며, `createdAt` 은 신고된 시간이다.

신고하는 데이터를 저장 할 때, 필드에 따라서 신고 대상을 구분하는데,

- 다른 사용자를 신고하면, `otherUserUid` 필드에 신고 당하는 사용자 UID 값이 저장되고,
- 글을 신고하면, `postId` 필드에 해당 글 ID,
- 코멘트를 신고하면, `commentId` 에 해당 코멘트 ID,
- 채팅 방을 신고하면, `chatRoomId` 에 해당 채팅 방 ID 값이 저장된다.

신고는 중복을 할 수 있다. 즉, 하나의 코멘트를 여러번 신고 할 수 있다. 그리고 나의 프로필이나 글/코멘트 등을 신고 할 수 있다.

## 사용자 신고하기

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

## 채팅방 신고하기

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

## 글 신고하기

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

## 코멘트 신고하기

## 내가 신고한 내역

`ReportMyListView` 를 사용하면 된다.

## 관리자가 신고된 목록 검토
