import 'package:example/firebase_options.dart';
import 'package:example/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ExampleApp());
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({
    super.key,
  });

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
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
