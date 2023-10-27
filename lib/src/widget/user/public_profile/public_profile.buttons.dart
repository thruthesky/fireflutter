import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PublicProfileButtons extends StatelessWidget {
  const PublicProfileButtons({super.key, required this.user});

  final User user;

  buttonStyle(context) => TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
      );

  textStyle(context) => TextStyle(
        color: Theme.of(context).colorScheme.onSecondary,
      );

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      children: [
        if (user.uid != myUid) ...[
          UserService.instance.customize.publicScreenLikeButton?.call(context, user) ??
              TextButton(
                key: const Key('PublicProfileLikeButton'),
                style: buttonStyle(context),
                onPressed: () => user.like(user.uid),
                child: Database(
                  path: 'likes/${user.uid}',
                  builder: (value, p) => Text(
                    value == null ? tr.like : tr.likes.replaceAll('#no', value.length.toString()),
                  ),
                ),
              ),
          UserService.instance.customize.publicScreenFavoriteButton?.call(context, user) ??
              FavoriteButton(
                otherUid: user.uid,
                builder: (re) => Text(
                  re ? tr.unfavorite : tr.favorite,
                  style: textStyle(context),
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
                style: buttonStyle(context),
                child: Text(tr.chat),
              ),
          UserService.instance.customize.publicScreenFollowButton?.call(context, user) ??
              MyDoc(
                builder: (my) => TextButton(
                  onPressed: () async {
                    await FeedService.instance.follow(user.uid);
                  },
                  child: Text(
                    my.followings.contains(user.uid) ? tr.unfollow : tr.follow,
                    style: textStyle(context),
                  ),
                ),
              ),
          UserService.instance.customize.publicScreenBlockButton?.call(context, user) ??
              UserBlocked(
                otherUser: user,
                blockedBuilder: (context) {
                  return TextButton(
                    onPressed: () async {
                      await my!.unblock(user.uid);
                      toast(
                        title: tr.unblock,
                        message: tr.unblockMessage,
                      );
                    },
                    style: buttonStyle(context),
                    child: Text(tr.unblock),
                  );
                },
                notBlockedBuilder: (context) {
                  return TextButton(
                    onPressed: () async {
                      await my!.block(user.uid);
                      toast(
                        title: tr.block,
                        message: tr.blockMessage,
                      );
                    },
                    style: buttonStyle(context),
                    child: Text(tr.block),
                  );
                },
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
                style: buttonStyle(context),
                child: Text(tr.report),
              ),
          if (isAdmin)
            UserDoc(
              uid: user.uid,
              builder: (u) => u.isDisabled
                  ? TextButton(
                      style: buttonStyle(context),
                      onPressed: () async {
                        await user.enable();
                      },
                      child: const Text(
                        'Enable',
                      ),
                    )
                  : TextButton(
                      style: buttonStyle(context),
                      onPressed: () async {
                        await user.disable();
                      },
                      child: const Text(
                        'Disable',
                      ),
                    ),
            ),
        ],
        ...?UserService.instance.customize.publicScreenTrailingButtons?.call(context, user),
      ],
    );
  }
}
