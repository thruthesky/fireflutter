import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class BlockUnblock extends StatelessWidget {
  const BlockUnblock({
    super.key,
    required this.snapshot,
  });

  final AsyncSnapshot<User?> snapshot;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        textStyle: MaterialStateTextStyle.resolveWith(
          (states) => const TextStyle(fontWeight: FontWeight.bold, fontSize: sizeXs + 2),
        ),
        minimumSize: const MaterialStatePropertyAll(
          Size(sizeSm, sizeXs),
        ),
      ),
      onPressed: () async {
        final result = await toggle(
          pathBlock(snapshot.data!.uid),
        );
        toast(title: result ? 'Blocked' : 'Unblocked', message: "User has ${result ? 'Blocked' : 'Unblocked'}");
      },
      child: Database(
        path: pathBlock(snapshot.data!.uid),
        builder: (value, path) => Text(value == null ? 'Block' : 'Unblock'),
      ),
    );
  }
}
