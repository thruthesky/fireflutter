import 'dart:developer';

import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class AdminMessagingScreen extends StatefulWidget {
  const AdminMessagingScreen({super.key, this.spaceBetweenWidgetGroup});
  final double? spaceBetweenWidgetGroup;

  @override
  State<AdminMessagingScreen> createState() => _AdminMessagingScreenState();
}

class _AdminMessagingScreenState extends State<AdminMessagingScreen> {
  final title = TextEditingController(text: 'post title ....');
  final body = TextEditingController(text: 'post content .....');
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

  TextStyle textStyle = const TextStyle(fontSize: 10);

  Widget get spaceBetweenWidgetGroup => SizedBox(height: widget.spaceBetweenWidgetGroup ?? 16);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Push Notification"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: sizeSm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: sizeSm),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(sizeSm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Send push notification by user, post, token, platform, all Guideline;",
                          style: textStyle,
                        ),
                        Text(
                          '1. Select the target, `Users`, `Token` or `Platform` that you want to send message to.',
                          style: textStyle,
                        ),
                        Text(
                          "2. Select notification type, `Post` or `Chat` this will determine the landing page. when the user tap the message.",
                          style: textStyle,
                        ),
                        Text(
                          '3. Input body and title.',
                          style: textStyle,
                        ),
                        Text(
                          '4. Submit the push notification',
                          style: textStyle,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Text(
                'Select Target',
                style: textStyle,
              ),
              Row(
                children: [
                  for (final target in targetMenuItem.keys)
                    InkWell(
                      onTap: () {
                        setState(() {
                          sendTarget = target;
                        });
                      },
                      child: Row(
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
              if (sendTarget == NotificationTarget.platform.name) ...[
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
              ],
              if (sendTarget == NotificationTarget.users.name) ...[
                Row(
                  children: [
                    Text(
                      'Users list',
                      style: textStyle,
                    ),
                    IconButton(
                      onPressed: () {
                        AdminService.instance.showUserSearchDialog(context, onTap: (user) async {
                          users[user.uid] = user;
                          toast(title: 'Users add', message: "${user.displayName} was added on the list");
                          setState(() {});
                        });
                      },
                      icon: const Icon(Icons.search),
                    ),
                  ],
                ),
                if (users.isNotEmpty) ...[
                  SizedBox(
                    height: 80,
                    child: ListView(
                      children: [
                        for (String uid in users.keys)
                          Row(
                            children: [
                              Text(
                                users[uid]!.displayName.isNotEmpty
                                    ? users[uid]!.displayName
                                    : users[uid]!.name.isNotEmpty
                                        ? users[uid]!.name
                                        : uid,
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
                  const Divider(),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: InkWell(
                      onTap: () {
                        AdminService.instance.showUserSearchDialog(context, onTap: (user) async {
                          users[user.uid] = user;
                          toast(title: 'Users add', message: "${user.displayName} was added on the list");
                          setState(() {});
                        });
                      },
                      child: Text(
                        'Choose users to send push notification',
                        style: textStyle,
                      ),
                    ),
                  ),
              ],
              if (sendTarget == NotificationTarget.tokens.name) ...[
                Row(
                  children: [
                    Text(
                      'Tokens list',
                      style: textStyle,
                    ),
                    IconButton(
                      onPressed: () {
                        AdminService.instance.showUserSearchDialog(context, onTap: (user) async {
                          final querySnapshot = await tokensCol(user.uid).get();
                          toast(title: 'Token added: ', message: "added new token # ${querySnapshot.size}");
                          if (querySnapshot.size == 0) return;
                          tokens = ([...tokens, ...querySnapshot.docs.map((e) => e.id).toList()]).toSet().toList();
                          setState(() {});
                        });
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
                  SizedBox(
                    height: 80,
                    child: SingleChildScrollView(
                      child: Column(
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
                        AdminService.instance.showUserSearchDialog(context, onTap: (user) async {
                          final querySnapshot = await tokensCol(user.uid).get();
                          toast(title: 'Token added: ', message: "added new token # ${querySnapshot.size}");
                          if (querySnapshot.size == 0) return;
                          tokens = ([...tokens, ...querySnapshot.docs.map((e) => e.id).toList()]).toSet().toList();
                          setState(() {});
                        });
                      },
                      child: Text(
                        'Choose users to get tokens and send push notification',
                        style: textStyle,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: sizeSm),
                  child: TextField(
                    controller: tokenString,
                    style: textStyle,
                    decoration: InputDecoration(
                      label: Text(
                        'Or Input tokens',
                        style: textStyle,
                      ),
                      hintText: 'Multiple token must be separated by comma',
                      hintStyle: textStyle,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                ),
              ],
              spaceBetweenWidgetGroup,
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
              spaceBetweenWidgetGroup,
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: landingPage,
                          style: textStyle,
                          decoration: InputDecoration(
                            label: Text(
                              "Landing $notificationType Id",
                              // style: textStyle,
                            ),
                            hintText: 'Input $notificationType Id',
                            helperText: notificationType == NotificationType.post.name
                                ? 'Click the load botton to patch the title and body base on the post id'
                                : null,
                            helperMaxLines: 2,
                            helperStyle: textStyle,
                          ),
                        ),
                      ),
                      if (notificationType == NotificationType.post.name) ...[
                        IconButton(
                          // visualDensity: const VisualDensity(vertical: sizeXxs),
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
                          // visualDensity: const VisualDensity(vertical: sizeXxs),
                          onPressed: () async {
                            // PostService.instance.showPostListDialog(context, '');
                            AdminService.instance.showPostListDialog(context, onTap: (post) async {
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
                            AdminService.instance.showChatRoomListDialog(context, onTap: (room) async {
                              landingPage.text = room.roomId;
                              Navigator.of(context).pop();
                              // setState(() {});
                            });
                          },
                          icon: const Icon(Icons.search),
                        ),
                      if (notificationType == NotificationType.user.name)
                        IconButton(
                          onPressed: () {
                            AdminService.instance.showUserSearchDialog(context, onTap: (user) async {
                              landingPage.text = user.uid;
                              Navigator.of(context).pop();
                              // setState(() {});
                            });
                          },
                          icon: const Icon(Icons.search),
                        ),
                    ],
                  ),
                  spaceBetweenWidgetGroup,
                  TextField(
                    controller: title,
                    style: textStyle,
                    decoration: const InputDecoration(
                      label: Text('Title'),
                      hintText: 'Input the title text',
                    ),
                  ),
                  spaceBetweenWidgetGroup,
                  TextField(
                    controller: body,
                    style: textStyle,
                    decoration: const InputDecoration(
                      label: Text('Body'),
                      hintText: 'Input the body text',
                    ),
                  ),
                  spaceBetweenWidgetGroup,
                  TextField(
                    controller: channelId,
                    style: textStyle,
                    decoration: const InputDecoration(
                      label: Text('Channel id (android only)'),
                      hintText: 'Specify channel id(android only)',
                    ),
                  ),
                  spaceBetweenWidgetGroup,
                  TextField(
                    controller: sound,
                    style: textStyle,
                    decoration: const InputDecoration(
                      label: Text('Sound'),
                      hintText: 'Input sound file name, must include ext. Sound file must be attached to the app.',
                    ),
                  ),
                  spaceBetweenWidgetGroup,
                  ElevatedButton(
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
                        return warningSnackbar(context, 'Landing id is missing');
                      }

                      await MessagingService.instance.queue(
                        title: title.text,
                        body: body.text,
                        uids: sendTarget == NotificationTarget.users.name ? users.keys.toList() : null,
                        tokens: sendTarget == NotificationTarget.tokens.name
                            ? [...tokens, ...(tokenString.text.split(","))]
                            : null,
                        topic: sendTarget == NotificationTarget.platform.name ? platformTarget : null,
                        type: notificationType,
                        id: landingPage.text,
                        channelId: channelId.text,
                        sound: sound.text,
                      );

                      toast(
                        title: 'Messaging',
                        message: 'Push notification was created.',
                      );
                    },
                    child: const Text('Send Push Message'),
                  ),
                  const SizedBox(
                    height: 64,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
