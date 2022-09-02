import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:paginate_firestore/bloc/pagination_cubit.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class ChatRoom extends StatefulWidget {
  ChatRoom({
    required this.otherUid,
    required this.onUpdateOtherUserRoomInformation,
    required this.messageBuilder,
    required this.inputBuilder,
    this.emptyDisplay,
    this.onAddFriend,
    Key? key,
  }) : super(key: key);

  /// [onUpdateOtherUserRoomInformation] is being invoked after room information
  /// had updated when user chat.
  final Function onUpdateOtherUserRoomInformation;
  final MessageBuilder messageBuilder;
  final InputBuilder inputBuilder;
  final Widget? emptyDisplay;

  /// Firebase user uid
  // final String myUid;
  final String otherUid;

  final Function? onAddFriend;

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  /// TODO global controller
  // Controller get _ => Controller.of;

  bool fetching = false;
  final int fetchNum = 20;
  bool noMore = false;

  List<ChatMessageModel> messages = [];

  int page = 0;

  late ChatMessageModel roomInfo;

  bool firstLoad = true;
  double progress = 0;

  bool isRoomBlocked = false;

  @override
  void initState() {
    super.initState();

    /// TODO global controller
    // _.otherUid = widget.otherUid;

    Chat.clearNewMessages(widget.otherUid);
    getRoomInfo();
  }

  getRoomInfo() async {
    /// ! Crashlytics happens an error: type 'Null' is not a subtype of type 'Map<dynamic, dynamic>' in type cast. Error thrown null. at _ChatRoomState.getRoomInfo(chat.room.dart:65)
    /// Not sure why "Chat.getRoomInfo()" produces null.
    DocumentSnapshot res = await Chat.getRoomInfo(widget.otherUid);
    if (res.exists == false || res.data() == null) {
      ///@ TODO global error controller
      // Controller.of.error(
      //   'There is no room information under my room list for the other user.',
      //   StackTrace.current,
      // );
      return;
    }
    roomInfo = ChatMessageModel.fromJson(res.data() as Map);
    DocumentSnapshot blockRes = await Chat.getBlockRoomInfo(widget.otherUid);
    if (blockRes.exists)
      setState(() {
        isRoomBlocked = true;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: PaginateFirestore(
              // Use SliverAppBar in header to make it sticky
              // header: const SliverToBoxAdapter(child: Text('HEADER')),
              footer: const SliverToBoxAdapter(child: SizedBox(height: 16)),

              itemsPerPage: 20,

              reverse: true,
              //item builder type is compulsory.
              itemBuilder: (context, documentSnapshots, index) {
                final snapshot = documentSnapshots[index];

                final data = snapshot.data() as Map?;
                final message = ChatMessageModel.fromJson(data!, snapshot.reference);

                return widget.messageBuilder(message);
              },
              // orderBy is compulsory to enable pagination
              query: ChatBase.messagesCol(widget.otherUid).orderBy('timestamp', descending: true),
              //Change types accordingly
              itemBuilderType: PaginateBuilderType.listView,
              // To update db data in real time.
              isLive: true,

              // initialLoader: Row(
              //   children: [Icon(Icons.local_dining), Text('Initial loader ...')],
              // ),

              ///
              // bottomLoader: Row(
              //   children: [Icon(Icons.timer), Text('More ...!')],
              // ),

              /// This will be invoked whenever it displays a new message. (from the login user or the other user.)
              onLoaded: (PaginationLoaded loaded) async {
                // print('page loaded; reached to end?; ${loaded.hasReachedEnd}');
                // print('######################################');
                // _myRoomDoc.set({'newMessages': 0}, SetOptions(merge: true));
                Chat.clearNewMessages(widget.otherUid);
              },
              onReachedEnd: (PaginationLoaded loaded) {
                // This is called only one time when it reaches to the end.
                // print('Yes, Reached to end!!');
              },
              onPageChanged: (int no) {
                /// onPageChanged works on [PaginateBuilderType.pageView] only.
                // print('onPageChanged() => page no; $no');
              },
              onEmpty: widget.emptyDisplay != null
                  ? widget.emptyDisplay!
                  : Center(child: Text('No chats, yet. Please send some message.')),
              // separator: Divider(color: Colors.blue),
            ),
          ),
          ChatFriend(
            uid: widget.otherUid,
            builder: (isFriend) {
              if (isFriend == false)
                TextButton(
                    onPressed: () async {
                      // print('add as friend');
                      await Chat.addFriend(widget.otherUid);
                      if (widget.onAddFriend != null) widget.onAddFriend!();
                    },
                    child: Text("Add as a friend"));

              return SizedBox.shrink();
            },
          ),
          if (isRoomBlocked == false) SafeArea(child: widget.inputBuilder(onSubmitText)),
        ],
      ),
    );
  }

  /// This will be called to send chat data to other user.
  /// It includes text, image url, other other files url.
  void onSubmitText(String text) async {
    final data = await Chat.send(text: text, otherUid: widget.otherUid);

    /// callback after sending a message to other user and updating the no of
    /// new messages on other user's room list.
    widget.onUpdateOtherUserRoomInformation(data);
  }
}
