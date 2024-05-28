import 'dart:async';

import 'package:example/firebase_options.dart';
import 'package:example/router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

zoneErrorHandler(e, stackTrace) {
  dog("---> zoneErrorHandler; runtimeType: ${e.runtimeType}");
  if (e is FirebaseAuthException) {
    toast(
        context: globalContext,
        message: '로그인 관련 에러 :  ${e.code} - ${e.message}');
  } else if (e is FirebaseException) {
    dog("FirebaseException :  $e }");
  } else if (e is FireFlutterException) {
    dog("FireFlutterException: (${e.code}) - ${e.message}");
    error(context: globalContext, message: e.message);
  } else {
    dog("Unknown Error :  $e");
  }
  debugPrintStack(stackTrace: stackTrace);
}

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);

      runApp(const ChatApp());

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.dumpErrorToConsole(details);
      };
    },
    zoneErrorHandler,
  );
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
