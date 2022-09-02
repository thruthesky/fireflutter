// import 'package:flutter/material.dart';

// import 'package:fireflutter/fireflutter.dart';

// class JobListPushNotificationIcon extends StatefulWidget {
//   JobListPushNotificationIcon({
//     Key? key,
//     required this.topic,
//     required this.onError,
//     required this.onSigninRequired,
//     required this.onChanged,
//     this.size,
//   }) : super(key: key);

//   final String topic;
//   final double? size;
//   final Function onError;
//   final Function onSigninRequired;
//   final Function(bool) onChanged;

//   @override
//   State<JobListPushNotificationIcon> createState() =>
//       _JobListPushNotificationIconState();
// }

// class _JobListPushNotificationIconState
//     extends State<JobListPushNotificationIcon> {
//   bool get hasSubscription {
//     return UserService.instance.user.settings
//         .hasSubscription(NotificationOptions.jobs(widget.topic));
//   }

//   @override
//   Widget build(BuildContext context) {
//     // if (widget.topic == '') return SizedBox.shrink();
//     return UserSettingDoc(builder: (settings) {
//       return IconButton(
//         onPressed: () => onNotificationSelected,
//         icon: Icon(
//           hasSubscription ? Icons.notifications_on : Icons.notifications_off,
//         ),
//         color: hasSubscription
//             ? Color.fromARGB(255, 74, 74, 74)
//             : Color.fromARGB(255, 177, 177, 177),
//         iconSize: widget.size,
//       );
//     });
//   }

//   onNotificationSelected() async {
//     if (UserService.instance.user.signedOut) {
//       widget.onSigninRequired();
//       return;
//     }

//     if (widget.topic.isEmpty) {
//       widget.onError("ERROR_SELECT_LOCATION_AND_CITY_FIRST");
//       return;
//     }

//     String topic = NotificationOptions.jobs(widget.topic);

//     try {
//       await MessagingService.instance.toggleSubscription(topic);
//     } catch (e) {
//       widget.onError(e);
//     }

//     return widget.onChanged(
//       UserService.instance.user.settings.hasSubscription(topic),
//     );
//   }
// }
