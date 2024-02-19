import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

/// A simple email and password login form.
///
/// This widget is used to collect an email and password from the user and
/// then call the [onLogin] callback with the provided credentials.
///
/// There is only one button, "Login", which will call the [onLogin] callback
/// or the [onRegister] callback if provided.
///
/// If the [onRegister] callback is provided, [onLogin] will not be called when
/// the user registered.
///
class SimpleEmailPasswordLoginForm extends StatefulWidget {
  const SimpleEmailPasswordLoginForm({
    super.key,
    required this.onLogin,
    this.onRegister,
  });

  final void Function() onLogin;
  final void Function()? onRegister;

  @override
  State<SimpleEmailPasswordLoginForm> createState() =>
      _SimpleEmailPasswordLoginFormState();
}

class _SimpleEmailPasswordLoginFormState
    extends State<SimpleEmailPasswordLoginForm> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelField(
          label: T.email.tr,
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        LabelField(
          label: T.password.tr,
          controller: passwordController,
          obscureText: true,
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton(
            onPressed: () async {
              dog("Email: ${emailController.text}");
              dog("Password: ${passwordController.text}");

              if (emailController.text.trim().isEmpty) {
                throw FireshipException('input-email', 'Input email to login');
              } else if (passwordController.text.trim().isEmpty) {
                throw FireshipException(
                    'input-password', 'Input password to login');
              }

              final re = await loginOrRegister(
                email: emailController.text,
                password: passwordController.text,
              );
              if (widget.onRegister != null) {
                if (re.register) {
                  widget.onRegister!();
                } else {
                  widget.onLogin();
                }
              } else {
                widget.onLogin();
              }
            },
            child: Text(T.login.tr),
          ),
        ),
      ],
    );
  }
}
