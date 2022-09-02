import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:paginate_firestore/bloc/pagination_cubit.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class ChatRoomsBlocked extends StatefulWidget {
  const ChatRoomsBlocked({
    required this.itemBuilder,
    this.onEmpty,
    Key? key,
  }) : super(key: key);

  final FunctionRoomsBlockedItemBuilder itemBuilder;
  final Widget? onEmpty;

  @override
  State<ChatRoomsBlocked> createState() => _ChatRoomsBlockedState();
}

class _ChatRoomsBlockedState extends State<ChatRoomsBlocked> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PaginateFirestore(
      shrinkWrap: true,
      footer: const SliverToBoxAdapter(child: SizedBox(height: 16)),
      itemsPerPage: 20,
      reverse: false,
      //item builder type is compulsory.
      itemBuilder: (context, documentSnapshots, index) {
        return Container(
          key: ValueKey(documentSnapshots[index].id),
          child: widget.itemBuilder(documentSnapshots[index].id),
        );
      },
      // orderBy is compulsory to enable pagination
      query: ChatBase.myRoomsBlockedCol.orderBy('timestamp', descending: true),
      //Change types accordingly
      itemBuilderType: PaginateBuilderType.listView,
      // To update db data in real time.
      isLive: true,

      /// initialLoader 가 제대로 잘 동작하지 않는 것 같다.
      // initialLoader: Row(
      //   children: [Icon(Icons.local_dining), Text('맨 처음에 한번만 표시되는 로더...')],
      // ),

      /// 이것도 제대로 동작하지 않는 것 같다.
      // bottomLoader: Row(
      //   children: [Icon(Icons.timer), Text('스크롤 해서 더 많이 로드 할 때 표시되는 로더!!!')],
      // ),

      onLoaded: (PaginationLoaded loaded) {
        // print('page loaded; reached to end?; ${loaded.hasReachedEnd}');
      },
      onReachedEnd: (PaginationLoaded loaded) {
        // This is called only one time when it reaches to the end.
        // print('Yes, Reached to end!!');
      },
      onPageChanged: (int no) {
        /// onPageChanged works on [PaginateBuilderType.pageView] only.
        // print('onPageChanged() => page no; $no');
      },
      onEmpty: widget.onEmpty ??
          const Center(
            child: Text('No blocked chat, yet.'),
          ),
      // separator: Divider(color: Colors.blue),
    );
  }
}
