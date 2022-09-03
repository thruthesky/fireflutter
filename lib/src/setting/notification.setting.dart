import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';

class NotificationSetting extends StatefulWidget {
  const NotificationSetting({
    Key? key,
  }) : super(key: key);

  @override
  State<NotificationSetting> createState() => _NotificationSettingState();
}

class _NotificationSettingState extends State<NotificationSetting> {
  final commentNotification = "newCommentUnderMyPostOrComment";

  List<Category>? categories;

  bool loadingAllNotification = false;

  @override
  void initState() {
    super.initState();
    // CategoryService.instance.getCategories().then((v) => setState(() {}));
    CategoryService.instance
        .loadCategories(categoryGroup: 'community')
        .then((value) => setState(() => categories = value));
  }

  @override
  Widget build(BuildContext context) {
    // if (loading) return Center(child: CircularProgressIndicator.adaptive());
    return UserSettingDoc(
      builder: (m) {
        // if (snapshot.hasError) return Text('Error');
        // if (snapshot.connectionState == ConnectionState.waiting) return SizedBox.shrink();
        // if (snapshot.hasData == false) return SizedBox.shrink();
        // print(UserSettingService.instance.settings.topics);

        if (categories == null) return Center(child: CircularProgressIndicator.adaptive());
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              value: User.instance.settings?.value(commentNotification) ?? false,
              onChanged: (b) async {
                try {
                  await User.instance.settings?.update({commentNotification: b});
                  ffAlert(context, "Comment notification",
                      (b == true ? 'Subscribed' : 'Unsubscribed') + " success");
                } catch (e) {
                  rethrow;
                }
              },
              title: Text('Comment notifications'),
              subtitle: Text('Receive notifications of new comments under my posts and comments'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            SizedBox(
              height: 64,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24),
              child: Text(
                'You can enable or disable notifications for new posts or new comments under each forum category. Or you can enable or disable all of them by one button press.',
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            if (loadingAllNotification == true) ...[
              SizedBox(
                height: 16,
              ),
              Center(
                child: CircularProgressIndicator.adaptive(),
              )
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () async {
                      try {
                        setState(() {
                          loadingAllNotification = true;
                        });
                        await enableOrDisableAllNotification(true);
                        setState(() {
                          loadingAllNotification = false;
                        });
                      } catch (e) {
                        setState(() {
                          loadingAllNotification = false;
                        });
                        rethrow;
                      }
                    },
                    child: Text('Enable all notification'),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (loadingAllNotification) return;
                      try {
                        setState(() {
                          loadingAllNotification = true;
                        });
                        await enableOrDisableAllNotification(false);
                        setState(() {
                          loadingAllNotification = false;
                        });
                      } catch (e) {
                        setState(() {
                          loadingAllNotification = false;
                        });
                        rethrow;
                      }
                    },
                    child: Text('Disable all notification'),
                  ),
                ],
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.only(
                  left: 24,
                ),
                child: Text(
                  'Post notifications',
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              for (Category cat in categories!) PostNotificationCheckBoxListItem(cat: cat),
              Divider(),
              Padding(
                padding: const EdgeInsets.only(
                  left: 24,
                ),
                child: Text(
                  'Comment notifications',
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              for (Category cat in categories!) CommentNotificationCheckBoxListItem(cat: cat),
            ],
          ],
        );
      },
    );
  }

  Future enableOrDisableAllNotification([bool enable = true]) async {
    String content = "";
    if (enable) {
      await UserSettingsModel.enableAllNotification();
      content = "Enabled all notification success.";
    } else {
      await UserSettingsModel.disableAllNotification();
      content = "Disabled all notification success.";
    }

    ffAlert(
      context,
      'Enable Notification',
      content,
    );
  }
}

class CommentNotificationCheckBoxListItem extends StatefulWidget {
  const CommentNotificationCheckBoxListItem({
    Key? key,
    required this.cat,
  }) : super(key: key);

  final Category cat;

  @override
  State<CommentNotificationCheckBoxListItem> createState() =>
      _CommentNotificationCheckBoxListItemState();
}

class _CommentNotificationCheckBoxListItemState extends State<CommentNotificationCheckBoxListItem> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: User.instance.settings?.hasSubscription('comments_${widget.cat.id}', 'forum'),
      onChanged: (b) async {
        if (loading == true) return;
        try {
          setState(() {
            loading = true;
          });
          await User.instance.settings
              ?.updateSubscription('comments_${widget.cat.id}', 'forum', b ?? false);

          final reason = b == true ? 'subscribed' : 'unsubscribed';
          ffAlert(context, "Comment notification", widget.cat.title + " comment $reason success.");
          setState(() {
            loading = false;
          });
        } catch (e) {
          setState(() {
            loading = false;
          });
          rethrow;
        }
      },
      title: loading == true
          ? Wrap(children: [CircularProgressIndicator.adaptive()])
          : Text(widget.cat.title),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

class PostNotificationCheckBoxListItem extends StatefulWidget {
  PostNotificationCheckBoxListItem({
    Key? key,
    required this.cat,
  }) : super(key: key);

  final Category cat;

  @override
  State<PostNotificationCheckBoxListItem> createState() => _PostNotificationCheckBoxListItemState();
}

class _PostNotificationCheckBoxListItemState extends State<PostNotificationCheckBoxListItem> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: User.instance.settings?.hasSubscription('posts_${widget.cat.id}', 'forum'),
      onChanged: (b) async {
        if (loading == true) return;
        try {
          setState(() {
            loading = true;
          });
          await User.instance.settings
              ?.updateSubscription('posts_${widget.cat.id}', 'forum', b ?? false);
          final reason = b == true ? 'subscribed' : 'unsubscribed';
          ffAlert(context, "Post notification", widget.cat.title + " post $reason success.");
          setState(() {
            loading = false;
          });
        } catch (e) {
          setState(() {
            loading = false;
          });
          rethrow;
        }
      },
      title: loading == true
          ? Wrap(children: [CircularProgressIndicator.adaptive()])
          : Text(widget.cat.title),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
