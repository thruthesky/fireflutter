import 'package:example/firebase_options.dart';
import 'package:example/router.chat.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ChatApp());
}

class ChatApp extends StatefulWidget {
  const ChatApp({
    super.key,
  });

  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  @override
  void initState() {
    super.initState();

    //
    UserService.instance.init();
    AdminService.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    dog('chat admin uid: ${AdminService.instance.chatAdminUid}');
    return MaterialApp.router(
      routerConfig: router,
    );
  }
}
