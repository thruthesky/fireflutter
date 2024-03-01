import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';

/// ActionOption
///
/// 만약, 특정 액션을 설정을 원하지 않는다면, ref 에 null 을 저장하면 된다. 그러면, 해당 액션은
/// 제한 설정을 하지 않는다.
class ActionOption {
  DatabaseReference? ref;
  Query? get query => ref?.limitToLast(limit).orderByChild('createdAt');
  int limit;
  int seconds;
  int count;
  bool debug;
  Future<bool?> Function()? overLimit;

  /// limit 에 걸렸는지 확인을 한다.
  ///
  /// limit 에 걸리지 않았거나, limit 에 걸려도 계속 실행을 하게 하는 경우 false 를 리턴한다. 이 경우 앱은 그대로 실행을 하면 된다.
  ///
  /// 이 함수가 true 를 리턴하면, limit 에 걸려서 더 이상 수행을 하지 말라는 뜻으로, 앱은 해당 action 에 대한 나머지 실행을 멈추어야 한다.
  ///
  /// 참고로, limit 에 걸린 경우, overLimit 함수를 호출하여, limit 에 걸렸을 때 어떻게 해야 할지 처리를 한다.
  /// overLiimit 함수에서 경고 메시지를 보내주거나 할 수 있다.
  /// overLimit 함수가 정의되지 않았거나, overLimit 함수가 아무것도 리턴하지 않거나, null 을 리턴하면, 최종적으로 true 를 리턴하여
  /// 나머지 수행을 멈춘다.
  /// 하지만, overLimit 함수가 false 를 리턴하면, 최종저긍로 limit 에 걸려도 계속 수행을 하게 된다.
  ///
  Future<bool> isOverLimit() async {
    /// ref 가 null 이면, 제한을 하지 않는다.
    if (ref == null) return false;

    /// 현재 카운트가 limit 보다 작으면, 제한을 하지 않는다.
    /// 이 값은 ActionService init 에서 실시간으로 업데이트가 된다.
    if (count < limit) return false;
    if (debug) dog('--> 제한에 걸렸다. ${ref!.path}');

    /// 그런데, 제한에 걸린 다음에는 더 이상, action 을 기록(로그)하지 못하므로, 실시간 업데이트가 안된다.
    /// 그래서, 이곳에서 쿼리를 해서, 제한 시간이 지났는지 확인한다.
    /// 제한 시간이 지나면, 다시 action 이 가능해 지고, 그러면 계속 action 을 로그하므로, init 에서 실시간 업데이트가 된다.
    final snapshot = await query!.get();
    count = ActionService.instance
        .countFromSnapshot(snapshot: snapshot, option: this);
    if (count < limit) {
      if (debug) dog('제한 시간이 지나서, 다시 action 이 가능해졌다. ${ref!.path}');
      return false;
    } else {
      if (debug) {
        logTimeleft();
      }
    }

    final re = await overLimit?.call();
    return re == null ? true : false;
  }

  ActionOption({
    this.ref,
    this.limit = 100,
    this.seconds = 10000,
    this.count = 0,
    this.debug = false,
    this.overLimit,
  });

  /// 디버깅을 위해서, 남은 시간을 로그로 남긴다.
  logTimeleft() async {
    final snapshot =
        await ref!.limitToLast(limit).orderByChild('createdAt').get();
    if (snapshot.exists) {
      final list =
          snapshot.children.map((e) => ActionModel.fromSnapshot(e)).toList();

      /// 첫번째 action 의 시간이 경과하려면 몇 초가 남았는지 계산한다.
      final first = list.first;
      final overtime = first.createdAt + seconds * 1000;
      final remain = overtime - DateTime.now().millisecondsSinceEpoch;
      dog('제한 시간이 지나기까지 ${remain ~/ 1000} 초 남았다. ${ref!.path}');
    }
  }
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

  ActionOption userProfileView = ActionOption(ref: null);
  ActionOption chatJoin = ActionOption(ref: null);
  ActionOption postCreate = ActionOption(ref: null);
  ActionOption commentCreate = ActionOption(ref: null);

  List<StreamSubscription> subs = [];

  init({
    ActionOption? userProfileView,
    ActionOption? chatJoin,
    ActionOption? postCreate,
    ActionOption? commentCreate,
  }) {
    if (userProfileView != null) {
      this.userProfileView = userProfileView;
      this.userProfileView.ref = Ref.userViewAction;
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
    final subscriptions = [userProfileView, chatJoin, postCreate, commentCreate]
        .where((e) => e.ref != null);
    for (final actionOption in subscriptions) {
      // listen user view
      // print('---> ActionService.listenActions() - action: ${action.limit}');
      subs.add(
        actionOption.query!.onValue.listen(
          (event) {
            actionOption.count = 0;
            if (event.snapshot.exists == false) {
            } else {
              // print(
              //     'listen actions; ${action.ref.path} -> ${event.snapshot.children.length}');
              actionOption.count = countFromSnapshot(
                  snapshot: event.snapshot, option: actionOption);
            }
          },
        ),
      );
    }
  }

  // Future<bool?> userViewOverLimit() async {
  //   if (userView.enable == false) return null;

  //   final snapshot = await Ref.userViewAction
  //       .limitToLast(userView.limit)
  //       .orderByChild('createdAt')
  //       .get();

  //   if (snapshot.exists == false) {
  //     userView.count = 0;
  //     return true;
  //   } else {
  //     userView.count = _updateCountFromSnapshot(snapshot, userView);
  //     if (userView.isOverLimit == false) return true;
  //   }

  //   if (userView.overLimit != null) {
  //     return await userView.overLimit!();
  //   }
  //   return null;
  // }

  // Future<bool?> postCreateOverLimit() async {
  //   if (postCreate.enable == false) return null;

  //   /// 게시판의 경우, 카테고리 한 개를 입력받아서, 그
  //   final snapshot = await Ref.postCreateAction
  //       .limitToLast(postCreate.limit)
  //       .orderByChild('createdAt')
  //       .get();

  //   if (snapshot.exists == false) {
  //     postCreate.count = 0;
  //     return true;
  //   } else {
  //     postCreate.count = _updateCountFromSnapshot(snapshot, postCreate);
  //     if (postCreate.isOverLimit == false) return true;
  //   }
  //   return await postCreate.overLimit?.call();
  // }

  // Future<bool?> commentCreateOverLimit() async {
  //   if (commentCreate.enable == false) return null;
  //   final snapshot = await Ref.commentCreateAction
  //       .limitToLast(commentCreate.limit)
  //       .orderByChild('createdAt')
  //       .get();

  //   if (snapshot.exists == false) {
  //     commentCreate.count = 0;
  //     return true;
  //   } else {
  //     commentCreate.count = _updateCountFromSnapshot(snapshot, commentCreate);
  //     if (commentCreate.isOverLimit == false) return true;
  //   }
  //   return await commentCreate.overLimit?.call();
  // }

  // ///
  // Future<bool?> chatJoinOverLimit() async {
  //   if (chatJoin.enable == false) return null;

  //   final snapshot = await Ref.chatJoinAction
  //       .limitToLast(chatJoin.limit)
  //       .orderByChild('createdAt')
  //       .get();

  //   if (snapshot.exists == false) {
  //     chatJoin.count = 0;
  //     return true;
  //   } else {
  //     chatJoin.count = _updateCountFromSnapshot(snapshot, chatJoin);
  //     if (chatJoin.isOverLimit == false) return true;
  //   }
  //   return await chatJoin.overLimit?.call();
  // }

  // @Deprecated('dont use this')
  // _updateCountFromSnapshot(DataSnapshot snapshot, ActionOption option) {
  //   int count = 0;
  //   final overtime =
  //       DateTime.now().millisecondsSinceEpoch - (option.minutes * 60 * 1000);
  //   for (var snapshot in snapshot.children) {
  //     final actoin = ActionModel.fromSnapshot(snapshot);
  //     // print(" ${actoin.createdAt.toHis} > ${overtime.toHis}");
  //     if (actoin.createdAt > overtime) {
  //       count++;
  //     }
  //   }
  //   return count;
  // }

  /// Snapshot 의 데이터들에서 createdAt 이 seconds 보다 오래된 갯수를 리턴한다.
  countFromSnapshot({
    required DataSnapshot snapshot,
    required ActionOption option,
  }) {
    int count = 0;
    final overtime =
        DateTime.now().millisecondsSinceEpoch - (option.seconds * 1000);
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
