import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class MeetupCreateButton extends StatelessWidget {
  const MeetupCreateButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add),
      onPressed: () {
        MeetupService.instance.showCreateScreen(context: context);
      },
    );
  }
}
