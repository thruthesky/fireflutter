import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ProfileNoOfViewButton extends StatelessWidget {
  const ProfileNoOfViewButton({
    super.key,
    required this.uid,
    this.itemBuilder,
  });

  final String uid;
  final Widget Function(User)? itemBuilder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: profileViewHistoryCol.where('uid', isEqualTo: uid).count().get().asStream(),
        builder: (context, snapshot) {
          return TextButton(
            onPressed: () {
              UserService.instance.showViewersScreen(
                context: context,
                itemBuilder: itemBuilder,
              );
            },
            style: const ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: MaterialStatePropertyAll(EdgeInsets.zero),
              minimumSize: MaterialStatePropertyAll(Size(50, double.minPositive)),
            ),
            child: Row(
              children: [
                Text(' ${snapshot.data?.count ?? 0} '),
                const Icon(
                  Icons.remove_red_eye,
                  size: sizeSm,
                ),
              ],
            ),
          );
        });
  }
}