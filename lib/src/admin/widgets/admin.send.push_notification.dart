import 'package:cloud_functions/cloud_functions.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class AdminSendPushNotification extends StatefulWidget {
  const AdminSendPushNotification({super.key});

  @override
  State<AdminSendPushNotification> createState() => _AdminSendPushNotificationState();
}

class _AdminSendPushNotificationState extends State<AdminSendPushNotification> {
  final tokens = TextEditingController();
  final uids = TextEditingController();
  final postId = TextEditingController();
  final title = TextEditingController();
  final body = TextEditingController();

  String sendOption = 'tokens';
  Map<String, String> dropdownItem = {
    'tokens': 'Tokens',
    'uids': 'Uids',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          subtitle: Text('Select receiver'),
          title: DropdownButton(
            isExpanded: true,
            value: sendOption,
            items: dropdownItem.keys.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  dropdownItem[value]!,
                  style: TextStyle(),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                sendOption = newValue!;
              });
            },
          ),
        ),
        if (sendOption == 'tokens')
          ListTile(
            leading: Text('Tokens'),
            title: TextField(
              controller: tokens,
            ),
          ),
        if (sendOption == 'uids')
          ListTile(
            leading: Text('User Ids'),
            title: TextField(
              controller: uids,
            ),
          ),
        ListTile(
          leading: Text('postId'),
          title: TextField(
            controller: postId,
          ),
          trailing: TextButton(
            onPressed: () => loadPost(),
            child: Text('Load'),
          ),
        ),
        ListTile(
          leading: Text('Title'),
          title: TextField(
            controller: title,
          ),
        ),
        ListTile(
          leading: Text('Body'),
          title: TextField(
            controller: body,
          ),
        ),
        Center(
          child: ElevatedButton(
            onPressed: () => sendMessage(context),
            child: Text('Send Push Notification'),
          ),
        )
      ],
    );
  }

  loadPost() async {
    if (postId.text.isEmpty) return;
    PostModel? post = await PostService.instance.load(postId.text);
    if (post == null) return ffAlert('Loading post failed', 'Post not found');
    title.text = post.title;
    body.text = post.content;
  }

  sendMessage(context) async {
    Map<String, dynamic> req = {
      'title': title.text,
      'body': body.text,
    };
    if (postId.text.isNotEmpty) {
      req['id'] = postId.text;
      req['type'] = 'post';
    }

    HttpsCallableResult<dynamic>? res;
    if (sendOption == 'tokens') {
      req['tokens'] = tokens.text;
      res = await FirebaseFunctions.instanceFor(region: 'asia-northeast3').httpsCallable('sendMessage').call(req);
    } else if (sendOption == 'uids') {
      req['uids'] = uids.text;
      res = await FirebaseFunctions.instanceFor(region: 'asia-northeast3').httpsCallable('sendMessage').call(req);
    }

    Map<String, dynamic> data = res!.data;
    String msg = '';
    int s = data['success'];
    int f = data['error'];
    msg = "Send count $s Success, $f Fail.";

    ffAlert('Sending Push Message', msg);
  }
}
