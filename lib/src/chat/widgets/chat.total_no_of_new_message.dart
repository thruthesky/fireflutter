import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Display total no of new message
///
///
class ChatTotalNoOfNewMessage extends StatelessWidget {
  const ChatTotalNoOfNewMessage({
    super.key,
    this.builder,
  });

  final Widget Function(
    BuildContext context,
    int no,
    Widget child,
  )? builder;

  @override
  Widget build(BuildContext context) {
    return Login(
      yes: (uid) => StreamBuilder(
        stream: ChatService.instance.joinsRef.child(myUid!).onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.hasData == false) {
            return const SizedBox.shrink();
          }
          final DatabaseEvent? data = snapshot.data;

          if (data == null) return const SizedBox.shrink();

          final value = data.snapshot.value as Map?;

          if (value == null) return const SizedBox.shrink();

          int no = 0;
          for (final key in value.keys) {
            final room = ChatRoom.fromJson(value[key] as Map, key: key);
            no += room.newMessage ?? 0;
          }

          final child = Container(
            width: no > 9 ? 20 : 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.orange.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$no',
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          );

          if (builder == null) {
            if (no == 0) return const SizedBox.shrink();
            return child;
          } else {
            return builder!(context, no, child);
          }
        },
      ),
      no: () =>
          builder?.call(context, 0, const SizedBox.shrink()) ??
          const SizedBox.shrink(),
    );
  }
}
