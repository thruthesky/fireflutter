// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:example/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

final globalNavigatorKey = GlobalKey<NavigatorState>();

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

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    FireFlutter.instance.init(context: globalNavigatorKey.currentContext!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FireFlutter Demo'),
      ),
      body: Padding(
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
                      TextField(
                        controller: TextEditingController(text: u.firstName),
                        decoration:
                            InputDecoration(labelText: 'Input your first name'),
                        onChanged: (v) =>
                            UserService.instance.update({'firstName': v}),
                      ),
                      TextField(
                        controller: TextEditingController(text: u.lastName),
                        decoration:
                            InputDecoration(labelText: 'Input your last name'),
                        onChanged: (v) =>
                            UserService.instance.update({'lastName': v}),
                      ),
                    ],
                  );
                },
              ),
            ),
            Divider(),
            Text('Post Create', style: caption),
            TextField(
              decoration: InputDecoration(labelText: 'Input title'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Input content'),
            ),
            Divider(),
            Text('Post List', style: caption),
            Wrap(
              spacing: 4,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text('QnA'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Discussion'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Buy & Sell'),
                ),
              ],
            )
          ],
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
