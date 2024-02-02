import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class SimpleProfileUpdateForm extends StatefulWidget {
  const SimpleProfileUpdateForm({super.key});

  @override
  State<SimpleProfileUpdateForm> createState() =>
      _SimpleProfileUpdateFormState();
}

class _SimpleProfileUpdateFormState extends State<SimpleProfileUpdateForm> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Name"),
        TextField(
          controller: nameController,
        ),
        const Text("Email"),
        TextField(
          controller: emailController,
        ),
        const Text("Phone"),
        TextField(
          controller: phoneController,
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton(
            onPressed: () async {
              my!.update(
                name: "name",
              );
              my!.updatePrivate(
                email: emailController.text,
                phoneNumber: phoneController.text,
              );
            },
            child: const Text('UPDATE PROFILE'),
          ),
        ),
      ],
    );
  }
}
