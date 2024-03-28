import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ClubCreateForm extends StatefulWidget {
  const ClubCreateForm({
    super.key,
    required this.onCreate,
  });

  final void Function(DocumentReference ref) onCreate;

  @override
  State<ClubCreateForm> createState() => _ClubCreateFormState();
}

class _ClubCreateFormState extends State<ClubCreateForm> {
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("모임 이름"),
        TextField(
          controller: nameController,
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 8),
        const Text("모임 이름을 적어주세요."),
        const SizedBox(height: 24),
        if (nameController.text.trim().isNotEmpty)
          Align(
            child: OutlinedButton(
              onPressed: () async {
                final ref = await Club.create(name: nameController.text);
                widget.onCreate(ref);
              },
              child: const Text('모임 만들기'),
            ),
          ),
      ],
    );
  }
}
