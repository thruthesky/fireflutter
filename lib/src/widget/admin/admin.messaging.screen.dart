import 'dart:developer';

import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

enum GuideView { minimize, maximize, close }

class AdminMessagingScreen extends StatefulWidget {
  const AdminMessagingScreen({super.key, this.spaceBetweenWidgetGroup});
  final double? spaceBetweenWidgetGroup;

  @override
  State<AdminMessagingScreen> createState() => _AdminMessagingScreenState();
}

class _AdminMessagingScreenState extends State<AdminMessagingScreen> {
  final title = TextEditingController(text: '');
  final body = TextEditingController(text: '');
  final landingPage = TextEditingController(text: '');
  final tokenString = TextEditingController(text: '');

  final channelId = TextEditingController(text: 'DEFAULT_CHANNEL');
  final sound = TextEditingController(text: 'default');
  List<String> tokens = [];
  Map<String, User> users = {};

  String sendTarget = NotificationTarget.platform.name;
  Map<String, String> targetMenuItem = {
    NotificationTarget.platform.name: 'Platform',
    NotificationTarget.users.name: 'Users',
    NotificationTarget.tokens.name: 'Tokens',
  };

  String platformTarget = NotificationPlatform.allUsers.name;
  Map<String, String> platformMenuItem = {
    NotificationPlatform.allUsers.name: 'All',
    NotificationPlatform.androidUsers.name: "Android",
    NotificationPlatform.iosUsers.name: "iOS",
    NotificationPlatform.webUsers.name: "Web",
  };

  String notificationType = NotificationType.post.name;
  Map<String, String> notificationTypeMenuItem = {
    NotificationType.post.name: 'Post',
    NotificationType.chat.name: 'Chat',
    NotificationType.user.name: 'User',
  };

  String topic = '';

  TextStyle textStyle = const TextStyle(fontSize: 10);

  Widget get spaceBetweenWidgetGroup => SizedBox(height: widget.spaceBetweenWidgetGroup ?? sizeLg);

  String guideView = GuideView.minimize.name;

  @override
  void initState() {
    super.initState();

    if (MessagingService.instance.customizeTopic != null) {
      targetMenuItem[NotificationTarget.topic.name] = 'Topic';
      topic = MessagingService.instance.customizeTopic!.first.topic;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('AdminPushNotificationBackButton'),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text("Push Notification"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: sizeSm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ...notificationGuide,
              ...chooseTarget,
              if (sendTarget == NotificationTarget.platform.name) ...notificationTargetPlatform,
              if (sendTarget == NotificationTarget.users.name) ...notificationTargetUsers,
              if (sendTarget == NotificationTarget.tokens.name) ...notificationTargetTokens,
              if (sendTarget == NotificationTarget.topic.name && MessagingService.instance.customizeTopic != null)
                ...notificationTargetCustomizeTopic,
              spaceBetweenWidgetGroup,
              ...selectNotificationType,
              spaceBetweenWidgetGroup,
              selectLandingPage,
              spaceBetweenWidgetGroup,
              ...notificationInputData,
              spaceBetweenWidgetGroup,
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (sendTarget == NotificationTarget.users.name && users.isEmpty) {
                      return warningSnackbar(context, 'Users list is empty.');
                    }
                    if (sendTarget == NotificationTarget.tokens.name && tokens.isEmpty && tokenString.text.isEmpty) {
                      return warningSnackbar(context, 'Tokens is empty.');
                    }

                    if (title.text.isEmpty && body.text.isEmpty) {
                      return warningSnackbar(context, 'Title and body cant be both empty');
                    }
                    if (landingPage.text.isEmpty) {
                      return warningSnackbar(context, '$notificationType id is missing');
                    }

                    await MessagingService.instance.queue(
                      title: title.text,
                      body: body.text,
                      uids: sendTarget == NotificationTarget.users.name ? users.keys.toList() : null,
                      tokens: sendTarget == NotificationTarget.tokens.name
                          ? [...tokens, ...(tokenString.text.split(","))]
                          : null,
                      topic: sendTarget == NotificationTarget.platform.name
                          ? platformTarget
                          : sendTarget == NotificationTarget.topic.name
                              ? MessagingService.instance.prefixCustomTopic + topic
                              : null,
                      type: notificationType,
                      id: landingPage.text,
                      channelId: channelId.text,
                      sound: sound.text,
                    );

                    toast(
                      title: 'Messaging',
                      message: 'Push notification was created.',
                      duration: const Duration(seconds: 5),
                    );
                  },
                  child: const Text('Send Push Message'),
                ),
              ),
              const SizedBox(
                height: 64,
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> get notificationGuide => [
        Row(
          children: [
            const Text(
              "Push notification guideline",
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                setState(() {
                  if (guideView == GuideView.minimize.name) {
                    guideView = GuideView.maximize.name;
                  } else if (guideView == GuideView.maximize.name) {
                    guideView = GuideView.close.name;
                  } else {
                    guideView = GuideView.minimize.name;
                  }
                });
              },
              icon: Icon(
                guideView == GuideView.minimize.name
                    ? Icons.keyboard_double_arrow_down_outlined
                    : guideView == GuideView.maximize.name
                        ? Icons.close_outlined
                        : Icons.keyboard_arrow_down_outlined,
              ),
            ),
          ],
        ),
        if (guideView != GuideView.close.name)
          Padding(
            padding: const EdgeInsets.only(bottom: sizeSm),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(sizeSm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Send push notification by user, post, token, platform, all",
                      style: textStyle,
                    ),
                    Text(
                      '1. Choose the target, `Users`, `Token` or `Platform` that you want to send message to.',
                      style: textStyle,
                    ),
                    if (guideView == GuideView.maximize.name)
                      Padding(
                        padding: const EdgeInsets.only(left: sizeSm),
                        child: Column(children: [
                          Text(
                            '1.1 For `Platform`, you can choose which platform will receive the notification or simply choose all to send to all users.',
                            style: textStyle,
                          ),
                          Text(
                            '1.2 For `Users`, `Token` you can search the user by clicking the search icon.',
                            style: textStyle,
                          ),
                          Text(
                            '1.3 For `Token` by clicking the + icon you can also input the tokens separated by comma',
                            style: textStyle,
                          ),
                        ]),
                      ),
                    Text(
                      "2. Choose notification type, `Post` or `Chat` or `User` this will determine the landing page. when the user tap the message.",
                      style: textStyle,
                    ),
                    if (guideView == GuideView.maximize.name) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: sizeSm),
                        child: Text(
                          "2.1 Input the corresponding PostId, RoomID or UserId. You can also click the search button to choose from the list of Post,Chat,User.",
                          style: textStyle,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: sizeSm),
                        child: Text(
                          "2.2 For post you can input the post id and click the load button to patch the title and content base from the post.",
                          style: textStyle,
                        ),
                      ),
                    ],
                    Text(
                      '3. Input/Modify body and title.',
                      style: textStyle,
                    ),
                    Text(
                      '4. For android you can input specific channel to trigger the push notification channel setup. Default value is `DEFAULT_CHANNEL`',
                      style: textStyle,
                    ),
                    Text(
                      '5. Input sound file name, must exist on the app. Default value is `default`',
                      style: textStyle,
                    ),
                    Text(
                      '6. Submit the push notification',
                      style: textStyle,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ];

  List<Widget> get chooseTarget => [
        Text(
          'Choose Target',
          style: textStyle,
        ),
        Wrap(
          children: [
            for (final target in targetMenuItem.keys)
              InkWell(
                onTap: () {
                  setState(() {
                    sendTarget = target;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio(
                      value: target,
                      groupValue: sendTarget,
                      onChanged: (String? value) {
                        log('value change $value');
                        if (value != null) {
                          setState(() {
                            sendTarget = value;
                          });
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: sizeSm),
                      child: Text(
                        targetMenuItem[target]!,
                        style: textStyle,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ];

  List<Widget> get notificationTargetPlatform => [
        spaceBetweenWidgetGroup,
        Text(
          'Select Platform',
          style: textStyle,
        ),
        Row(
          children: [
            for (final platform in platformMenuItem.keys)
              InkWell(
                onTap: () {
                  setState(() {
                    platformTarget = platform;
                  });
                },
                child: Row(
                  children: [
                    Radio(
                      value: platform,
                      groupValue: platformTarget,
                      onChanged: (String? value) {
                        log('value change $value');
                        if (value != null) {
                          setState(() {
                            platformTarget = value;
                          });
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: sizeSm),
                      child: Text(
                        platformMenuItem[platform]!,
                        style: textStyle,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ];

  List<Widget> get notificationTargetUsers => [
        Row(
          children: [
            Text(
              'Users list',
              style: textStyle,
            ),
            IconButton(
              onPressed: () {
                AdminService.instance.showUserSearchDialog(
                  context,
                  field: 'name',
                  onTap: (user) async {
                    users[user.uid] = user;
                    toast(
                      title: 'Users add',
                      message: "${user.showDisplayName} was added on the list",
                      duration: const Duration(seconds: 2),
                    );
                    setState(() {});
                  },
                  titleBuilder: (user) => Text(
                    user!.showDisplayName,
                  ),
                  subtitleBuilder: (user) => Text(
                    dateTimeShort(user!.createdAt),
                  ),
                );
              },
              icon: const Icon(Icons.search),
            ),
          ],
        ),
        if (users.isNotEmpty) ...[
          Container(
            constraints: const BoxConstraints(maxHeight: 100),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (String uid in users.keys)
                    Row(
                      children: [
                        Text(
                          users[uid]!.showDisplayName,
                          overflow: TextOverflow.ellipsis,
                          style: textStyle,
                        ),
                        const Spacer(),
                        InkWell(
                            onTap: () {
                              users.remove(uid);
                              setState(() {});
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: sizeXs, vertical: sizeXxs),
                              child: Icon(
                                Icons.delete_forever_outlined,
                              ),
                            ))
                      ],
                    ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: Divider(),
          ),
        ] else
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: InkWell(
              onTap: () {
                AdminService.instance.showUserSearchDialog(
                  context,
                  field: 'name',
                  onTap: (user) async {
                    users[user.uid] = user;
                    toast(
                      title: 'Users add',
                      message: "${user.showDisplayName} was added on the list",
                      duration: const Duration(seconds: 2),
                    );
                    setState(() {});
                  },
                );
              },
              child: Text(
                'Choose users to send push notification',
                style: textStyle,
              ),
            ),
          ),
      ];

  List<Widget> get notificationTargetTokens => [
        Row(
          children: [
            Text(
              'Tokens list',
              style: textStyle,
            ),
            IconButton(
              onPressed: () {
                AdminService.instance.showUserSearchDialog(
                  context,
                  field: 'name',
                  onTap: (user) async {
                    final querySnapshot = await tokensCol(user.uid).get();
                    toast(
                      title: 'Token added: ',
                      message: "added new token # ${querySnapshot.size}",
                      duration: const Duration(seconds: 2),
                    );
                    if (querySnapshot.size == 0) return;
                    tokens = ([...tokens, ...querySnapshot.docs.map((e) => e.id).toList()]).toSet().toList();
                    setState(() {});
                  },
                );
              },
              icon: const Icon(Icons.search),
            ),
            IconButton(
              onPressed: () async {
                final res = await prompt(
                  context: context,
                  title: "Input Token's",
                  message: "Multipule token must be separated by comma",
                );
                if (res == null || res.isEmpty) return;
                if (res.contains(',')) {
                  tokens = ([
                    ...tokens,
                    ...res.split(','),
                  ]).toSet().toList();
                } else {
                  tokens.add(res);
                }

                setState(() {});
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        if (tokens.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 100),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (String token in tokens)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            token,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle,
                          ),
                        ),
                        InkWell(
                            onTap: () {
                              tokens.remove(token);
                              setState(() {});
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: sizeXs,
                                vertical: sizeXxs,
                              ),
                              child: Icon(
                                Icons.delete_forever_outlined,
                              ),
                            ))
                      ],
                    ),
                ],
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: sizeXs),
            child: InkWell(
              onTap: () {
                AdminService.instance.showUserSearchDialog(
                  context,
                  field: 'name',
                  onTap: (user) async {
                    final querySnapshot = await tokensCol(user.uid).get();
                    toast(
                      title: 'Token added: ',
                      message: "added new token # ${querySnapshot.size}",
                      duration: const Duration(seconds: 2),
                    );
                    if (querySnapshot.size == 0) return;
                    tokens = ([...tokens, ...querySnapshot.docs.map((e) => e.id).toList()]).toSet().toList();
                    setState(() {});
                  },
                );
              },
              child: Text(
                'Choose users to get tokens and send push notification',
                style: textStyle,
              ),
            ),
          ),
      ];

  List<Widget> get notificationTargetCustomizeTopic => [
        spaceBetweenWidgetGroup,
        Text(
          'Select Topic',
          style: textStyle,
        ),
        Row(
          children: [
            for (final customTopic in MessagingService.instance.customizeTopic!)
              InkWell(
                onTap: () {
                  setState(() {
                    topic = customTopic.topic;
                  });
                },
                child: Row(
                  children: [
                    Radio(
                      value: customTopic.topic,
                      groupValue: topic,
                      onChanged: (String? value) {
                        log('value change $value');
                        if (value != null) {
                          setState(() {
                            topic = value;
                          });
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: sizeSm),
                      child: Text(
                        customTopic.title,
                        style: textStyle,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ];

  List<Widget> get selectNotificationType => [
        Text(
          'Select notification type',
          style: textStyle,
        ),
        Row(
          children: [
            for (final type in notificationTypeMenuItem.keys)
              InkWell(
                onTap: () {
                  setState(() {
                    notificationType = type;
                  });
                },
                child: Row(
                  children: [
                    Radio(
                      value: type,
                      groupValue: notificationType,
                      onChanged: (String? value) {
                        log('value change $value');
                        if (value != null) {
                          setState(() {
                            landingPage.text = '';
                            notificationType = value;
                          });
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: sizeSm),
                      child: Text(
                        notificationTypeMenuItem[type]!,
                        style: textStyle,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ];

  Widget get selectLandingPage => Stack(
        children: [
          TextField(
            controller: landingPage,
            style: textStyle,
            decoration: InputDecoration(
              label: Text(
                "Input $notificationType Id",
              ),
              hintText: 'Input $notificationType Id',
              helperText: notificationType == NotificationType.post.name
                  ? 'Click the load botton to patch the title and body base on the post id'
                  : null,
              helperMaxLines: 2,
              helperStyle: textStyle,
            ),
          ),
          Positioned(
            right: 0,
            top: 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (notificationType == NotificationType.post.name) ...[
                  IconButton(
                    onPressed: () async {
                      if (landingPage.text.isEmpty) {
                        return warningSnackbar(null, '$notificationType Id is not set');
                      }

                      Post post = await PostService.instance.get(landingPage.text);

                      showSnackBar(null, 'Post was loaded, title and body was patch');

                      title.text = post.title;
                      body.text = post.content;
                    },
                    icon: const Icon(Icons.refresh_outlined),
                  ),
                  IconButton(
                    onPressed: () async {
                      AdminService.instance.showChoosePostScreen(context, onTap: (post) async {
                        landingPage.text = post.id;
                        title.text = post.title;
                        body.text = post.content;

                        Navigator.of(context).pop();
                      });
                    },
                    icon: const Icon(Icons.search),
                  ),
                ],
                if (notificationType == NotificationType.chat.name)
                  IconButton(
                    onPressed: () {
                      AdminService.instance.showChooseChatRoomScreen(context, onTap: (room) async {
                        landingPage.text = room.roomId;
                        Navigator.of(context).pop();
                      });
                    },
                    icon: const Icon(Icons.search),
                  ),
                if (notificationType == NotificationType.user.name)
                  IconButton(
                    onPressed: () {
                      AdminService.instance.showUserSearchDialog(
                        context,
                        field: 'name',
                        onTap: (user) async {
                          landingPage.text = user.uid;
                          Navigator.of(context).pop();
                        },
                      );
                    },
                    icon: const Icon(Icons.search),
                  ),
              ],
            ),
          ),
        ],
      );

  List<Widget> get notificationInputData => [
        TextField(
          controller: title,
          style: textStyle,
          decoration: const InputDecoration(
            label: Text('Title'),
            hintText: 'Input the title text',
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
        ),
        spaceBetweenWidgetGroup,
        TextField(
          controller: body,
          style: textStyle,
          decoration: const InputDecoration(
            label: Text('Body'),
            hintText: 'Input the body text',
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
        ),
        spaceBetweenWidgetGroup,
        TextField(
          controller: channelId,
          style: textStyle,
          decoration: const InputDecoration(
            label: Text('Channel id (android only)'),
            hintText: 'Specify channel id(android only)',
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
        ),
        spaceBetweenWidgetGroup,
        TextField(
          controller: sound,
          style: textStyle,
          decoration: const InputDecoration(
            label: Text('Sound'),
            hintText: 'Input sound file name, must include ext. Sound file must be attached to the app.',
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
        ),
      ];
}
