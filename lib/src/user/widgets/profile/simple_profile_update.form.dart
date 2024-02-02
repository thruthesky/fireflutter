import 'package:fireship/fireship.dart';
import 'package:fireship/src/user/user.private.model.dart';
import 'package:flutter/material.dart';

class SimpleProfileUpdateForm extends StatefulWidget {
  const SimpleProfileUpdateForm({super.key, this.onUpdate});

  final void Function()? onUpdate;

  @override
  State<SimpleProfileUpdateForm> createState() =>
      _SimpleProfileUpdateFormState();
}

class _SimpleProfileUpdateFormState extends State<SimpleProfileUpdateForm> {
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();

    displayNameController.text = my?.displayName ?? '';

    UserPrivateModel.get().then((priv) {
      emailController.text = priv.email ?? '';
      phoneController.text = priv.phoneNumber ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Name"),
        TextField(
          controller: displayNameController,
        ),
        const Text("Email"),
        TextField(
          controller: emailController,
        ),
        const Text("Phone Number"),
        TextField(
          controller: phoneController,
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton(
            onPressed: () async {
              await Future.wait([
                my!.update(
                  displayName: displayNameController.text,
                ),
                UserPrivateModel.update(
                  email: emailController.text,
                  phoneNumber: phoneController.text,
                )
              ]);
              if (widget.onUpdate != null) {
                widget.onUpdate!();
              }
            },
            child: const Text('UPDATE PROFILE'),
          ),
        ),
      ],
    );
  }
}
