import 'package:flutter/material.dart';
import 'package:badges/badges.dart';

/// See README.md for details.
class ChatBadge extends StatefulWidget {
  const ChatBadge({Key? key, this.builder}) : super(key: key);

  final Function(Widget? badge)? builder;

  @override
  State<ChatBadge> createState() => _ChatBadgeState();
}

class _ChatBadgeState extends State<ChatBadge> {
  int no = 0;
  @override
  void initState() {
    super.initState();

    /// TODO newMessages controller
    // Controller.of.newMessages.listen((value) {
    //   if (mounted)
    //     setState(() {
    //       no = value;
    //     });
    // });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.builder == null) {
      if (no == 0) {
        return SizedBox.shrink();
      } else {
        return badge;
      }
    } else {
      return widget.builder!(no == 0 ? null : badge);
    }
  }

  Widget get badge {
    return Badge(
      toAnimate: false,
      shape: BadgeShape.circle,
      badgeColor: Colors.red,
      elevation: 0,
      padding: EdgeInsets.all(3.0),
      badgeContent: Text(
        no.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
