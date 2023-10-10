import 'package:firebase_core/firebase_core.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:new_app/firebase_options.dart';
import 'package:new_app/home.screen/main.page.dart';
import 'package:new_app/login.widgets/login.form.dart';
import 'package:new_app/router/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const LoginPage());
}

class LoginPage extends StatefulWidget {
  static const String routeName = '/';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    // UserService.instance.get(myUid!);
    // UserService.instance.init(adminUid: myUid!);
    // UserService.instance.init(enableNoOfProfileView: true, adminUid: myUid!);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FireFlutterService.instance.init(context: router.routerDelegate.navigatorKey.currentContext!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      theme: ThemeData.light(),
    );
  }
}

class LoginPageBody extends StatelessWidget {
  const LoginPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthChange(
        builder: (user) => user == null
            ? const Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                ),
                child: Center(
                  child: LoginForm(),
                ),
              )
            : const MainPageBody(),
      ),
    );
  }
}
