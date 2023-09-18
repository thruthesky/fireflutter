import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class TotalNoOfNewMessage extends StatelessWidget {
  const TotalNoOfNewMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: ChatService.instance.totalNoOfNewMessageChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator.adaptive();
        }

        if (snapshot.hasData) {
          if (snapshot.data == 0) return const SizedBox.shrink();
          return Badge(
            label: Text('${snapshot.data}'),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
