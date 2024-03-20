// import 'dart:async';

// import 'package:example/firebase_options.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:fireflutter/fireflutter.dart';
// import 'package:flutter/material.dart';

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
// BuildContext get globalContext => navigatorKey.currentState!.overlay!.context;

// void main() async {
//   runZonedGuarded(
//     () async {
//       WidgetsFlutterBinding.ensureInitialized();
//       await Firebase.initializeApp(
//         options: DefaultFirebaseOptions.currentPlatform,
//       );

//       runApp(const MyApp());

//       FlutterError.onError = (FlutterErrorDetails details) {
//         FlutterError.dumpErrorToConsole(details);
//       };
//     },
//     zoneErrorHandler,
//   );
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     super.initState();
//     UserService.instance.init();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: defaultLightTheme(context: context),
//       navigatorKey: navigatorKey,
//       home: const MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: const Text('FireFlutter Quick Start App'),
//       ),
//       body: Column(
//         children: [
//           AuthReady(
//             builder: (uid) => Padding(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('UID: $uid'),
//                   const SizedBox(height: 24),
//                   const Text('User menu'),
//                   Wrap(
//                     spacing: 8,
//                     children: [
//                       ElevatedButton(
//                         onPressed: () => UserService.instance
//                             .showProfileUpdateScreen(context: context),
//                         child: const Text('Profile'),
//                       ),
//                       ElevatedButton(
//                         onPressed: () => UserService.instance.signOut(),
//                         child: const Text('Sign Out'),
//                       ),
//                       ElevatedButton(
//                         onPressed: () => UserService.instance.signOut(),
//                         child: const Text('Blocks'),
//                       ),
//                       ElevatedButton(
//                         onPressed: () => UserService.instance.signOut(),
//                         child: const Text('Reports'),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   Wrap(
//                     spacing: 8,
//                     children: [
//                       ElevatedButton(
//                         onPressed: () => UserService.instance
//                             .showProfileUpdateScreen(context: context),
//                         child: const Text('User Search'),
//                       ),
//                       ElevatedButton(
//                         onPressed: () => UserService.instance.signOut(),
//                         child: const Text('Sign Out'),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   const NewProfilePhotos(),
//                 ],
//               ),
//             ),
//             notLoginBuilder: () => Theme(
//               data: bigElevatedButtonTheme(context),
//               child: const SimpleEmailPasswordLoginForm(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// zoneErrorHandler(e, stackTrace) {
//   dog("----> runZoneGuarded() : Exceptions outside flutter framework.");
//   dog("--------------------------------------------------------------");
//   dog("---> runtimeType: ${e.runtimeType}");

//   if (e is FirebaseAuthException) {
//     String message = "${e.code} - ${e.message}";
//     if (e.code == 'invalid-email') {
//       message = '잘못된 이메일 주소입니다.';
//     } else if (e.code == 'weak-password') {
//       message = '비밀번호를 더 어렵게 해 주세요. 대소문자, 숫자 및 특수문자를 포함하여 6자 이상으로 입력해주세요.';
//     } else if (e.code == 'email-already-in-use') {
//       message = '메일 주소 또는 비밀번호를 잘못 입력하였습니다.';
//     }
//     toast(context: globalContext, message: '로그인 에러 :  $message');
//   } else if (e is FirebaseException) {
//     dog("FirebaseException :  ${e.code}, ${e.message}");
//     if (e.plugin == 'firebase_storage') {
//       if (e.code == 'unknown') {
//         error(
//             context: globalContext,
//             message: '파일 업로드 에러 :  ${e.message}\n\nStorage 서비스를 확인해주세요.');
//       } else {
//         error(context: globalContext, message: e.toString());
//       }
//     } else {
//       error(context: globalContext, message: e.toString());
//     }
//   } else if (e is FireFlutterException) {
//     dog("FireshipException: (${e.code}) - ${e.message}");
//     if (e.code == 'input-email') {
//       error(context: globalContext, message: '이메일 주소를 입력해주세요.');
//     } else if (e.code == 'input-password') {
//       error(context: globalContext, message: '비밀번호를 입력해주세요.');
//     } else {
//       error(context: globalContext, title: e.code, message: e.message);
//     }
//   } else {
//     dog("Unknown Error :  $e");
//     error(context: globalContext, message: e.toString());
//   }
//   debugPrintStack(stackTrace: stackTrace);
// }

// import 'package:example/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
      );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    UserService.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          AuthReady(
            builder: (uid) => Column(
              children: [
                Text('UID: $uid'),
                ElevatedButton(
                  onPressed: () => UserService.instance.signOut(),
                  child: const Text('로그아웃'),
                ),
              ],
            ),
            notLoginBuilder: () => const SimpleEmailPasswordLoginForm(),
          ),
        ],
      ),
    );
  }
}
