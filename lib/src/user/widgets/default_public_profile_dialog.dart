import 'package:fireship/fireship.dart';
import 'package:flutter/widgets.dart';

class DefaultPublicProfileDialog extends StatelessWidget {
  const DefaultPublicProfileDialog({super.key, required this.uid});

  final String uid;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          UserData(
            uid: uid,
            field: Def.displayName,
            builder: (name) => Text(name),
          ),
        ],
      ),
    );
  }
}
