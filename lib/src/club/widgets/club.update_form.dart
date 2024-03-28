import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ClubUpdateForm extends StatefulWidget {
  const ClubUpdateForm({
    super.key,
    required this.reference,
  });

  final DocumentReference reference;

  @override
  State<ClubUpdateForm> createState() => _ClubUpdateFormState();
}

class _ClubUpdateFormState extends State<ClubUpdateForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.reference.get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final club = Club.fromSnapshot(snapshot.data as DocumentSnapshot);

          nameController.text = club.name;

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
              const Text("모임 설명"),
              TextField(
                controller: descriptionController,
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 8),
              const Text("모임 설명을 적어주세요."),
              const SizedBox(height: 24),
              if (nameController.text.trim().isNotEmpty)
                Align(
                  child: OutlinedButton(
                    onPressed: () async {
                      await widget.reference.update({
                        'name': nameController.text,
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text('모임 수정하기'),
                  ),
                ),
            ],
          );
        });
  }
}
