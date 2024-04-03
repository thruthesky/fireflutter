# 신고

사용자는 글, 코멘트, 채팅, 사용자 등을 신고 할 수 있습니다.

`/reports/unviewed/<id>` - 모든 신고 정보가 저장됩니다. 참고로, 신고하는 코드는 `Report.create()` 을 보면 됩니다.
`/reports/rejected/<id>` - 관리자가 확인을 하고, 아무런 조치를 하지 않을 예정이면, 즉 거짓 신고이거나 조치 사항이 아니면 이곳으로 신고가 이동됩니다.
`/reports/accepted/<id>` - 관리자가 확인을 하고, 조치를 하는 경우 이곳에 저장됩니다. 조치를 할 때 사유만 적거나, 계정 정지를 할 수 있습니다.




`uid` 와 `createdAt` 필드는 모든 신고에서 기본적으로 저장되는 필드입니다.  `uid` 는 신고자의 uid 이며, `createdAt` 은 신고된 시간입니다.

신고하는 데이터를 저장 할 때, 필드에 따라서 신고 대상을 구분하는데,

- 다른 사용자를 신고하면, `otherUserUid` 필드에 신고 당하는 사용자 UID 값이 저장되고,
- 글을 신고하면, `postId` 필드에 해당 글 ID,
- 코멘트를 신고하면, `commentId` 에 해당 코멘트 ID,
- 채팅 방을 신고하면, `chatRoomId` 에 해당 채팅 방 ID 값이 저장됩니다.


신고는 중복을 할 수 있습니다. 즉, 하나의 코멘트를 여러번 신고 할 수 있으며 본인이 직접 쓴 글이나 코멘트 또는 본인의 프로필을 신고 할 수도 있습니다.

사용자가 처음 신고를 하면 `/reports/unviewed` 에 신고 데이터가 저장되며,
관리자가 확인 후, 신고 내용을 거절하면 `/reports/rejected` 에 저장되고,
신고 내용을 승인하면 `/reports/accepted` 에 저장됩니다.

이 때, 신고 내용을 승인 했다고 해서 자동으로 신고된 사용자에게 제제가 가해지는 것은 아닙니다. 관리자가 별도로 사용자의 계정을 disable 해야 합니다.




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





## UI 커스터마이징


기본 UI 가 마음에 들지 않는다면, 아래와 같이 직접 모든 것을 디자인 할 수 있다.

UI 커스텀 디자인 예제

```dart
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:roha/font_awesome/lib/font_awesome_flutter.dart';
import 'package:roha/global.dart';
import 'package:roha/screens/block/widget/roha_block_tile.dart';
import 'package:roha/widgets/empty_display.dart';

class ReportScreen extends StatelessWidget {
  static const String routeName = "/RerportScreen";
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(T.report.tr),
      ),
      body: ReportMyListView(
        emptyBuilder: (context) => EmptyDisplay(
          text: 'emptyReportList'.tr,
        ),
        chatBuilder: (report, func) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: md, vertical: 12),
            padding: const EdgeInsets.symmetric(
              horizontal: md,
            ),
            height: 82,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: context.onBackground.withAlpha(10)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.reason,
                        style: context.titleMedium.copyWith(
                            fontSize: 21, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Text(
                            '[CHAT] ',
                            style: context.labelSmall,
                          ),
                          Expanded(
                              child: UserDisplayName(
                            uid: report.otherUserUid,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.labelSmall,
                          )),
                          Text(
                            ' ${report.createdAt.toShortDate}',
                            style: context.labelSmall,
                          )
                        ],
                      )
                    ],
                  ),
                ),
                spaceSm,
                SizedBox(
                  width: 37,
                  height: 37,
                  child: IconButton.outlined(
                    onPressed: func,
                    icon: const FaIcon(
                      FontAwesomeIcons.lightTrash,
                      size: 17,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        userBuilder: (report, func) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: md, vertical: fsSm),
          child: RohaBlockTile(
            userUid: report.otherUserUid,
            title: Text(
              report.reason,
              style: context.titleMedium
                  .copyWith(fontSize: 21, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Row(
              children: [
                UserDisplayName(
                  uid: report.otherUserUid!,
                  style: context.labelSmall,
                ),
                Text(
                  ' ${report.createdAt.toShortDate}',
                  style: context.labelSmall,
                ),
              ],
            ),
            trailing: SizedBox(
              width: 37,
              height: 37,
              child: IconButton.outlined(
                onPressed: func,
                icon: const FaIcon(
                  FontAwesomeIcons.lightTrash,
                  size: 17,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```