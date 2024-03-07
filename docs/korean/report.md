# 신고

사용자는 글, 코멘트, 채팅, 사용자 등을 신고 할 수 있습니다.

신고를 하면 `/reports/<id>` 에 신고 정보가 저장됩니다. 참고로, 신고하는 코드는 `Report.create()` 을 보면 됩니다.

`uid` 와 `createdAt` 필드는 모든 신고에서 기본적으로 저장되는 필드입니다.  `uid` 는 신고자의 uid 이며, `createdAt` 은 신고된 시간입니다.

신고하는 데이터를 저장 할 때, 필드에 따라서 신고 대상을 구분하는데,

- 다른 사용자를 신고하면, `otherUserUid` 필드에 신고 당하는 사용자 UID 값이 저장되고,
- 글을 신고하면, `postId` 필드에 해당 글 ID,
- 코멘트를 신고하면, `commentId` 에 해당 코멘트 ID,
- 채팅 방을 신고하면, `chatRoomId` 에 해당 채팅 방 ID 값이 저장됩니다.

신고는 중복을 할 수 있습니다. 즉, 하나의 코멘트를 여러번 신고 할 수 있으며 본인이 직접 쓴 글이나 코멘트 또는 본인의 프로필을 신고 할 수도 있습니다.


## 사용자 신고하기

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

`ReportMyListView` 를 사용하면 됩니다.


## 관리자가 신고된 목록 검토

사용자가 신고를 하면 관리자는 그 신고 내용을 보고, 해당 신고에 대해서 검토 및 적절한 조치를 취해야 합니다.


`ReportAdminListView` 를 사용해서 신고된 목록을 표시하며 기본적으로 신고 반려, 신고 조치를 둘 중 하나를 할 수 있습니다.

신고 반려를 하기 위해서는 reject 버튼을 클릭하고, 신고 조치를 위해서는 accept 를 클릭하면 됩니다.

단, accept 후에 아무런 추가 조치를 취하지 않을 수도 있으며, 해당 사용자의 계정을 정지 할 수도 있습니다.

사용자 계정 정지에 관해서는 [사용자 문서](./user.md)를 읽어 보세요.
