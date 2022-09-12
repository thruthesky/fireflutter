// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, curly_braces_in_flow_control_structures

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final globalNavigatorKey = GlobalKey<NavigatorState>();

Future<void> onTerminatedMessage(message) async {
  //
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: globalNavigatorKey,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with ForumMixin {
  @override
  void initState() {
    super.initState();

    FireFlutterService.instance.init(
      context: globalNavigatorKey.currentContext!,
      alert: (t, c) {
        return showDialog<bool?>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('AlertDialog: $t'),
            content: Text('AlertDialog: $c'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Ok'),
              )
            ],
          ),
        );
      },
    );

    initFirebaseCloudMessaging();
  }

  initFirebaseCloudMessaging() async {
    ///
    MessagingService.instance.init(
      // while the app is close and notification arrive you can use this to do small work
      // example are changing the badge count or informing backend.
      onBackgroundMessage: onTerminatedMessage,

      ///
      onForegroundMessage: (RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        debugPrint('Message data: ${message.data}');

        if (message.notification != null) {
          debugPrint(
              'Message also contained a notification: ${message.notification}');
          ffAlert(
            message.notification?.title ?? 'No title',
            message.notification?.body ?? 'No body',
          );
        }
      },
      onMessageOpenedFromTermiated: (message) {
        // this will triggered when the notification on tray was tap while the app is closed
        // if you change screen right after the app is open it display only white screen.
        WidgetsBinding.instance.addPostFrameCallback((duration) {
          log(message.toString());
        });
      },
      // this will triggered when the notification on tray was tap while the app is open but in background state.
      onMessageOpenedFromBackground: (message) {
        log(message.toString());
      },
      onNotificationPermissionDenied: () {
        // debugPrint('onNotificationPermissionDenied()');
      },
      onNotificationPermissionNotDetermined: () {
        // debugPrint('onNotificationPermissionNotDetermined()');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FireFlutter Demo'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text('User Profile', style: caption),
              MyDoc(
                builder: (my) =>
                    my.signedIn ? Text(my.toString()) : Text('Please, sign-in'),
              ),
              Divider(),
              Text('Sign In', style: caption),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  signInAs('User-A'),
                  signInAs('User-B'),
                  signInAs('User-C'),
                  signInAs('User-D'),
                  signInAs('User-E'),
                  signInAs('User-F'),
                  signInAs('User-G'),
                  signOut(),
                ],
              ),
              Divider(),
              Text('Global navigator context', style: caption),
              Wrap(
                spacing: 4,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final re = await ffAlert('title', 'content');
                      ffAlert("Chose of alert box", "Choise: $re");
                    },
                    child: Text('Alert'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final re = await ffConfirm('title', 'content');
                      ffAlert("Chose of confirm box", "Choise: $re");
                    },
                    child: Text('Confirm'),
                  ),
                ],
              ),
              Divider(),
              MyDoc(
                builder: (my) => Text(
                  'Profile Update Form ${my.email}',
                  style: caption,
                ),
              ),
              StreamBuilder(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (_, __) => UserDoc(
                  key: ValueKey(UserService.instance.uid),
                  uid: UserService.instance.uid,
                  builder: (u) {
                    if (u.signedOut) return Text('Please, signin');
                    return Column(
                      children: [
                        FileUploadButton(
                          type: UploadType.userProfilePhoto,
                          onUploaded: (url) {
                            debugPrint('uploaded url: $url');
                          },
                          onProgress: (p) {
                            debugPrint('progress: $p');
                          },
                          child: Stack(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                ),
                                child: MyDoc(builder: (my) {
                                  if (my.photoUrl == '') {
                                    return Icon(Icons.person, size: 64);
                                  } else {
                                    return ClipOval(
                                      child: SizedBox(
                                          width: 64,
                                          height: 64,
                                          child: Image.network(
                                            my.photoUrl,
                                            fit: BoxFit.cover,
                                          )),
                                    );
                                  }
                                }),
                              ),
                              Positioned(
                                left: 0,
                                bottom: 0,
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.blue,
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    Storage.delete(
                                      UserService.instance.user.photoUrl,
                                      type: UploadType.userProfilePhoto,
                                    );
                                  },
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextField(
                          controller: TextEditingController(text: u.firstName),
                          decoration: InputDecoration(
                              labelText: 'Input your first name'),
                          onChanged: (v) =>
                              UserService.instance.update({'firstName': v}),
                        ),
                        TextField(
                          controller: TextEditingController(text: u.lastName),
                          decoration: InputDecoration(
                              labelText: 'Input your last name'),
                          onChanged: (v) =>
                              UserService.instance.update({'lastName': v}),
                        ),
                        MyDoc(
                            builder: (my) => Text('Birthday: ${my.birthday}')),
                        ElevatedButton(
                          onPressed: () async {
                            final dt = await showDatePicker(
                              context: context,
                              initialDate: DateTime(1960),
                              firstDate: DateTime(1960),
                              lastDate: DateTime.now(),
                            );
                            if (dt != null) {
                              UserService.instance.update({
                                'birthday':
                                    toInt(DateFormat('yyyyMMdd').format(dt)),
                              });
                            }
                          },
                          child: Text('Choose Birthday'),
                        ),
                        TextField(
                          controller: TextEditingController(text: u.gender),
                          decoration: InputDecoration(
                              labelText: 'Input your gender. M or F.'),
                          onChanged: (v) => UserService.instance.update(
                            {'gender': v},
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Divider(),
              Text('Push notification', style: caption),
              ElevatedButton(
                onPressed: () {
                  MessagingService.instance.send(
                    token: MessagingService.instance.token!,
                    title: 'Message title to myself!',
                    body: 'Message body',
                  );
                },
                child: Text('Send a message'),
              ),
              Divider(),
              Text('Post Create', style: caption),
              StatefulBuilder(
                builder: (ctx, setState) {
                  final category = TextEditingController();
                  final title = TextEditingController();
                  final content = TextEditingController();
                  return Column(
                    children: [
                      TextField(
                        controller: category,
                        decoration: InputDecoration(
                            labelText: 'Input category. i.e) qna, discussion'),
                      ),
                      TextField(
                        controller: title,
                        decoration: InputDecoration(labelText: 'Input title'),
                      ),
                      TextField(
                        controller: content,
                        decoration: InputDecoration(labelText: 'Input content'),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.camera_alt),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              assert(category.text == 'qna' ||
                                  category.text == 'discussion');
                              try {
                                await PostModel().create(
                                  category: category.text,
                                  title: title.text,
                                  content: content.text,
                                );
                              } catch (e) {
                                ffError(e);
                                rethrow;
                              }
                            },
                            child: Text('Create'),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              Divider(),
              Text('Post List', style: caption),
              Builder(
                builder: (context) {
                  String? postListCategory;
                  return StatefulBuilder(
                    builder: (ctx, statefulBuilderSetState) {
                      Query postListQuery =
                          FirebaseFirestore.instance.collection('posts');
                      if (postListCategory != null) {
                        postListQuery = postListQuery.where('category',
                            isEqualTo: postListCategory);
                      }

                      postListQuery = postListQuery
                          .limit(5)
                          .orderBy('createdAt', descending: true);

                      return Column(
                        children: [
                          Wrap(
                            spacing: 4,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  statefulBuilderSetState(() {
                                    postListCategory = 'qna';
                                  });
                                },
                                child: Text('QnA'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  statefulBuilderSetState(() {
                                    postListCategory = 'discussion';
                                  });
                                },
                                child: Text('Discussion'),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 200,
                            child: StreamBuilder<QuerySnapshot>(
                              stream: postListQuery.snapshots(),
                              builder: (_, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting)
                                  return CircularProgressIndicator.adaptive();
                                if (snapshot.hasError)
                                  return Text(snapshot.error.toString());
                                final querySnapshot = snapshot.data!;
                                return ListView(
                                  children: querySnapshot.docs.map(
                                    (e) {
                                      final p = PostModel.fromSnapshot(e);
                                      return ListTile(
                                        contentPadding: EdgeInsets.all(0),
                                        title:
                                            Text("${p.category} - ${p.title}"),
                                        onTap: () {
                                          onPostEdit(post: p);
                                        },
                                      );
                                    },
                                  ).toList(),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 64),
            ],
          ),
        ),
      ),
    );
  }
}

Widget signInAs(String uid) {
  return ElevatedButton(
    onPressed: () async {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: "$uid@test.com",
          password: 'p,*~$uid,O,',
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          FirebaseAuth.instance.signInWithEmailAndPassword(
            email: "$uid@test.com",
            password: 'p,*~$uid,O,',
          );
        } else {
          rethrow;
        }
      }
    },
    child: Text(uid),
  );
}

Widget signOut() {
  return ElevatedButton(
    onPressed: () => FirebaseAuth.instance.signOut(),
    style: ElevatedButton.styleFrom(
      backgroundColor: Color.fromARGB(255, 108, 108, 108),
    ),
    child: Text('Sign Out'),
  );
}

TextStyle get caption => TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );
