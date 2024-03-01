import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:fireship/fireship.dart';

class ActionOption {
  String id;
  DatabaseReference ref;
  bool enable;
  int limit;
  int minutes;
  int count;
  Future<bool?> Function()? overLimit;

  bool get isOverLimit => count >= limit;

  ActionOption({
    required this.id,
    required this.ref,
    this.enable = false,
    this.limit = 100,
    this.minutes = 10000,
    this.count = 0,
    this.overLimit,
  });
}

/// ActionService
///
/// 다른 사용자 프로필 보기를 1분에 3회로 제한 한 경우, 3회 제한이 걸리면, 이전에 본 다른 사용자의 프로필도 모두 볼 수 없다.
/// 단, 이전에 본 사용자의 프로필을 다시 보기 해도, 카운트가 증가하지는 않는다.
///
///
class ActionService {
  static ActionService? _instance;
  static ActionService get instance => _instance ??= ActionService._();
  ActionService._();

  ActionOption userView = ActionOption();
  ActionOption chatJoin = ActionOption();
  ActionOption postCreate = ActionOption();
  ActionOption commentCreate = ActionOption();

  List<StreamSubscription> subs = [];

  init({
    ActionOption? userView,
    ActionOption? chatJoin,
    ActionOption? postCreate,
    ActionOption? commentCreate,
  }) {
    if (userView != null) {
      this.userView = userView;
      this.userView.ref = Ref.userViewAction;
    }
    if (chatJoin != null) {
      this.chatJoin = chatJoin;
      this.chatJoin.ref = Ref.chatJoinAction;
    }
    if (postCreate != null) {
      this.postCreate = postCreate;
      this.postCreate.ref = Ref.postCreateAction;
    }
    if (commentCreate != null) {
      this.commentCreate = commentCreate;
      this.commentCreate.ref = Ref.commentCreateAction;
    }

    listenActions();
  }

  listenActions() {
    for (final sub in subs) {
      sub.cancel();
    }
    subs.clear();
    for (final actionOption in [
      userView,
      chatJoin,
      postCreate,
      commentCreate
    ]) {
      if (actionOption.enable) {
        // listen user view
        // print('---> ActionService.listenActions() - action: ${action.limit}');
        subs.add(
          actionOption.ref
              .limitToLast(actionOption.limit)
              .orderByChild('createdAt')
              .onValue
              .listen(
            (event) {
              if (event.snapshot.exists == false) {
                actionOption.count = 0;
              } else {
                // print(
                //     'listen actions; ${action.ref.path} -> ${event.snapshot.children.length}');
                actionOption.count =
                    _updateCountFromSnapshot(event.snapshot, actionOption);
              }
            },
          ),
        );
      }
    }
  }

  Future<bool?> userViewOverLimit() async {
    if (userView.enable == false) return null;

    final snapshot = await Ref.userViewAction
        .limitToLast(userView.limit)
        .orderByChild('createdAt')
        .get();

    if (snapshot.exists == false) {
      userView.count = 0;
      return true;
    } else {
      userView.count = _updateCountFromSnapshot(snapshot, userView);
      if (userView.isOverLimit == false) return true;
    }

    if (userView.overLimit != null) {
      return await userView.overLimit!();
    }
    return null;
  }

  Future<bool?> postCreateOverLimit() async {
    if (postCreate.enable == false) return null;

    /// 게시판의 경우, 카테고리 한 개를 입력받아서, 그
    final snapshot = await Ref.postCreateAction
        .limitToLast(postCreate.limit)
        .orderByChild('createdAt')
        .get();

    if (snapshot.exists == false) {
      postCreate.count = 0;
      return true;
    } else {
      postCreate.count = _updateCountFromSnapshot(snapshot, postCreate);
      if (postCreate.isOverLimit == false) return true;
    }
    return await postCreate.overLimit?.call();
  }

  Future<bool?> commentCreateOverLimit() async {
    if (commentCreate.enable == false) return null;
    final snapshot = await Ref.commentCreateAction
        .limitToLast(commentCreate.limit)
        .orderByChild('createdAt')
        .get();

    if (snapshot.exists == false) {
      commentCreate.count = 0;
      return true;
    } else {
      commentCreate.count = _updateCountFromSnapshot(snapshot, commentCreate);
      if (commentCreate.isOverLimit == false) return true;
    }
    return await commentCreate.overLimit?.call();
  }

  ///
  Future<bool?> chatJoinOverLimit() async {
    if (chatJoin.enable == false) return null;

    final snapshot = await Ref.chatJoinAction
        .limitToLast(chatJoin.limit)
        .orderByChild('createdAt')
        .get();

    if (snapshot.exists == false) {
      chatJoin.count = 0;
      return true;
    } else {
      chatJoin.count = _updateCountFromSnapshot(snapshot, chatJoin);
      if (chatJoin.isOverLimit == false) return true;
    }
    return await chatJoin.overLimit?.call();
  }

  _updateCountFromSnapshot(DataSnapshot snapshot, ActionOption option) {
    int count = 0;
    final overtime =
        DateTime.now().millisecondsSinceEpoch - (option.minutes * 60 * 1000);
    for (var snapshot in snapshot.children) {
      final actoin = ActionModel.fromSnapshot(snapshot);
      // print(" ${actoin.createdAt.toHis} > ${overtime.toHis}");
      if (actoin.createdAt > overtime) {
        count++;
      }
    }
    return count;
  }
}
