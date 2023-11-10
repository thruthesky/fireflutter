import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatRoomMenuScreen extends StatelessWidget {
  const ChatRoomMenuScreen({
    super.key,
    required this.room,
    // this.otherUser,
  });

  final Room room;
  // final User? otherUser;

  // Stream<DocumentSnapshot<Object?>> get roomStream => ChatService.instance.roomDoc(widget.room.id).snapshots();

  bool get isMaster => ChatService.instance.isMaster(room: room, uid: myUid!);
  @override
  Widget build(BuildContext context) {
    /// It is an intended design to wrap the entire screen with SafeArea and Padding for the best look.
    return Padding(
      padding: const EdgeInsets.fromLTRB(80, 0, 0, 0),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close),
            ),
            actions: [
              const Spacer(),

              // 즐겨찾기
              // IconButton(
              //   icon: const Icon(Icons.favorite_border),
              //   onPressed: () {
              //     showSnackBar(context, 'Favorite is not implemented yet.');
              //   },
              // ),

              // 공유
              // IconButton(
              //   onPressed: () {
              //     showSnackBar(context, 'Share is not implemented yet.');
              //   },
              //   icon: Icon(
              //       Platform.isAndroid ? Icons.share : Icons.ios_share_rounded),
              // ),

              /// Note that, for chat room push notification, if the setting document exists, it is unsubscribed.
              /// So, the icon should be reserved.
              PushNotificationIcon(
                action: ActionType.chatDisabled.name,
                roomId: room.roomId,
                onIcon: const Icon(Icons.notifications_off),
                offIcon: const Icon(Icons.notifications_active),
              ),

              // 친구초대
              if (room.isGroupChat)
                IconButton(
                  onPressed: () {
                    showGeneralDialog(
                      context: context,
                      pageBuilder: (context, _, __) => Scaffold(
                        appBar: AppBar(
                          title: const Text('Invite User'),
                        ),
                        body: ChatRoomMenuUserInviteDialog(room: room),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_add),
                ),
            ],
          ),
          // Temporarily added this because the leave is not actually
          // needed for 1:1 chat room. And, notifications_off is not
          // implemented yet.
          bottomNavigationBar: room.isGroupChat
              ? BottomNavigationBar(
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Leave'),
                    BottomNavigationBarItem(icon: Icon(Icons.notifications_off), label: 'Alarm'),
                  ],
                  onTap: (value) {
                    if (value == 0) {
                      // 방 나가기
                      if (isMaster == false) {
                        room.leave();
                      }
                    } else if (value == 1) {
                      showSnackBar(context, 'Alarm is not implemented yet.');
                    }
                  },
                )
              : null,
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                if (room.group) ...[
                  if (room.rename[myUid] == null)
                    Text(room.name, style: Theme.of(context).textTheme.titleLarge)
                  else ...[
                    Text(
                      room.rename[myUid]!,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(room.name, style: Theme.of(context).textTheme.titleSmall)
                  ],
                ] else ...[
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('1:1 채팅방과 그룹 채팅 메뉴를  분리 할 것.'),
                  ),
                ],
                Text("${room.users.length} joined"),
                Text("Created on ${room.createdAt.toString().split(' ').first}"),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const Text('Participants', style: TextStyle(fontSize: 18)),
                Expanded(child: ChatRoomMenuUserListView(room: room)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
