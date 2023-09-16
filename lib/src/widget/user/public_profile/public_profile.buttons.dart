import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PublicProfileButtons extends StatefulWidget {
  const PublicProfileButtons({super.key, required this.user});

  final User user;

  @override
  State<PublicProfileButtons> createState() => _PublicProfileButtonsState();
}

class _PublicProfileButtonsState extends State<PublicProfileButtons> {
  get user => widget.user;
  get buttonStyle => TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
      );

  get textStyle => TextStyle(
        color: Theme.of(context).colorScheme.onSecondary,
      );

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      children: [
        UserService.instance.customize.publicScreenLikeButton?.call(context, user) ??
            TextButton(
              style: buttonStyle,
              onPressed: () => like(user.uid),
              child: Database(
                path: 'likes/${user.uid}',
                builder: (value) => Text(
                  value == null ? tr.like : tr.likes.replaceAll('#no', value.length.toString()),
                ),
              ),
            ),
        UserService.instance.customize.publicScreenFavoriteButton?.call(context, user) ??
            FavoriteButton(
              otherUid: user.uid,
              builder: (re) => Text(
                re ? tr.unfavorite : tr.favorite,
                style: textStyle,
              ),
              onChanged: (re) => toast(
                title: re ? tr.favorite : tr.unfavorite,
                message: re ? tr.favoriteMessage : tr.unfavoriteMessage,
              ),
            ),
        UserService.instance.customize.publicScreenChatButton?.call(context, user) ??
            TextButton(
              onPressed: () {
                ChatService.instance.showChatRoom(
                  context: context,
                  user: user,
                );
              },
              style: buttonStyle,
              child: Text(tr.chat),
            ),
        UserService.instance.customize.publicScreenFollowButton?.call(context, user) ??
            UserDoc(
              live: true,
              user: user,
              builder: (user) => TextButton(
                onPressed: () async {
                  final re = await FeedService.instance.follow(user.uid);
                  toast(
                    title: re ? tr.follow : tr.unfollow,
                    message: re ? tr.followMessage : tr.unfollowMessage,
                  );
                },
                child: Text(
                  my.followings.contains(user.uid) ? tr.unfollow : tr.follow,
                  style: textStyle,
                ),
              ),
            ),
        UserService.instance.customize.publicScreenBlockButton?.call(context, user) ??
            TextButton(
              onPressed: () async {
                final blocked = await toggle(pathBlock(user.uid));
                toast(
                  title: blocked ? tr.block : tr.unblock,
                  message: blocked ? tr.blockMessage : tr.unblockMessage,
                );
              },
              style: buttonStyle,
              child: Database(
                path: pathBlock(user.uid),
                builder: (value) => Text(value == null ? tr.block : tr.unblock),
              ),
            ),
        UserService.instance.customize.publicScreenReportButton?.call(context, user) ??
            TextButton(
              onPressed: () {
                ReportService.instance.showReportDialog(
                  context: context,
                  otherUid: user.uid,
                  onExists: (id, type) => toast(
                    title: tr.alreadyReportedTitle,
                    message: tr.alreadyReportedMessage.replaceAll('#type', type),
                  ),
                );
              },
              style: buttonStyle,
              child: Text(tr.report),
            ),
        ...?UserService.instance.customize.publicScreenTrailingButtons?.call(context, user),
      ],
    );
  }
}
