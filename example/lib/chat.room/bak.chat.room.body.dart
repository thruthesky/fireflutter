// import 'package:fireflutter/fireflutter.dart';
// import 'package:flutter/material.dart';
// import 'package:new_app/page.essentials/app.bar.dart';

// class ChatRoomBody extends StatefulWidget {
//   const ChatRoomBody({super.key});

//   @override
//   State<ChatRoomBody> createState() => _ChatRoomBodyState();
// }

// class _ChatRoomBodyState extends State<ChatRoomBody> {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//         stream: Room.myRooms.snapshots(),
//         builder: (context, snapshots) {
//           if (snapshots.connectionState == ConnectionState.waiting) {
//             return const CircularProgressIndicator();
//           }
//           List<String> chatRooms = snapshots.data!.docs.map((e) => e.id).toList();

//           return ListView.builder(
//               itemCount: chatRooms.length,
//               // prototypeItem: const Divider(),
//               itemBuilder: (context, index) {
//                 return FutureBuilder(
//                     future: _roomFinder(chatRooms[index]),
//                     builder: (context, snapshot) {
//                       if (!snapshot.hasData) {
//                         return const SizedBox.shrink();
//                       }
//                       final time = snapshot.data!.lastMessage!.createdAt;
//                       var timeago = dateTimeAgo(time);
//                       return ChatTile(timeago: timeago, room: snapshot.data!);
//                     });
//               });
//         });
//   }

//   Future<Room> _roomFinder(String roomId) async {
//     Room room = await Room.get(roomId);
//     // debugPrint('$test');
//     return room;
//   }
// }

// class ChatTile extends StatelessWidget {
//   const ChatTile({
//     super.key,
//     required this.timeago,
//     required this.room,
//   });
//   final Room? room;
//   final String timeago;

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: UserAvatar(
//         user: my,
//         size: sizeXxl,
//         radius: 40,
//       ),
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             room!.name,
//             style: const TextStyle(
//               fontSize: sizeSm,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           Text(
//             room!.lastMessage!.text ?? '',
//             style: const TextStyle(
//               fontSize: sizeSm - 2,
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//           Text(
//             timeago,
//             style: TextStyle(
//               fontSize: sizeXs + 5,
//               color: Theme.of(context).shadowColor.withAlpha(150),
//               fontWeight: FontWeight.w300,
//             ),
//           ),
//         ],
//       ),
//       onTap: () {
//         showGeneralDialog(
//           context: context,
//           pageBuilder: (context, _, __) => Scaffold(
//             appBar: AppBar(
//               leading: const LeadingButton(),
//               title: TitleText(text: room!.name),
//               forceMaterialTransparency: true,
//               actions: const [
//                 // AppBarAction(),
//               ],
//             ),
//             body: const Text('Chat'),
//           ),
//         );
//         // ChatService.instance.showChatRoom(context: context, user: my, room: room!);
//       },
//     );
//   }
// }
