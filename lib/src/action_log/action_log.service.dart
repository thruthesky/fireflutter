import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';

/// ActionLogOption
///
/// 만약, 특정 액션을 설정을 원하지 않는다면, ref 에 null 을 저장하면 된다. 그러면, 해당 액션은
/// 제한 설정을 하지 않는다.
class ActionLogOption {
  /// 주의: ref 에 직접 쿼리를 하지 않고, query 를 사용해야 한다.
  DatabaseReference? ref;
  Query? get query {
    /// 게시판의 경우, 카테고리 별로 제한을 한다.
    ///
    if (category != null) {
      return ref!.limitToLast(limit).orderByChild('createdAt');
    }
    return ref!.limitToLast(limit).orderByChild('createdAt');
  }

  /// 게시판의 경우, 카테고리를 지정하여, 여러개의 게시판에 대해서 각각의 제한을 설정할 수 있다.
  String? category;

  /// [limit] 은 몇 개의 액션을 허용할 것인지를 설정한다. 참고로 이 값이 커지면, DB 에서 그 만큼 많은 데이터를 가져와야
  /// 하므로, 성능에 영향을 줄 수 있다. 그래서 최대 100 정도로 설정하는 것이 좋다. 보통 10 이내의 값을 주면 된다.
  int limit;

  /// [seconds] 는 몇 초 동안 제한을 할 것인지를 설정한다. 만약, 10초 동안 3개의 액션을 허용하고 싶다면,
  /// limit 은 3, seconds 는 10 이 된다.
  int seconds;
  int count;
  bool debug;
  Future<bool?> Function(ActionLogOption)? overLimit;

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

    /// limit 이 0 이면, 무조건 제한을 한다. 즉, 액션을 한번도 허용하지 않는다.
    if (limit == 0) {
      final re = await overLimit?.call(this);
      return (re == null || re) ? true : false;
    }

    /// 현재 카운트가 limit 보다 작으면, 제한을 하지 않는다.
    /// 이 값은 ActionLogService init 에서 실시간으로 업데이트가 된다.
    if (count < limit) return false;
    if (debug) dog('--> 제한에 걸렸다. ${ref!.path}');

    /// 그런데, 제한에 걸린 다음에는 더 이상, action 을 기록(로그)하지 못하므로, 실시간 업데이트가 안된다.
    /// 그래서, 이곳에서 쿼리를 해서, 제한 시간이 지났는지 확인한다.
    /// 제한 시간이 지나면, 다시 action 이 가능해 지고, 그러면 계속 action 을 로그하므로, init 에서 실시간 업데이트가 된다.
    final snapshot = await query!.get();
    count = ActionLogService.instance
        .countFromSnapshot(snapshot: snapshot, option: this);
    if (count < limit) {
      if (debug) dog('제한 시간이 지나서, 다시 action 이 가능해졌다. ${ref!.path}');
      return false;
    } else {
      if (debug) {
        logTimeleft();
      }
    }

    final re = await overLimit?.call(this);
    return (re == null || re) ? true : false;
  }

  ActionLogOption({
    this.ref,
    this.limit = 100,
    this.seconds = 10000,
    this.count = 0,
    this.debug = false,
    this.overLimit,
  });

  /// 디버깅을 위해서, 남은 시간을 로그로 남긴다.
  logTimeleft() async {
    final snapshot = await query!.get();
    if (snapshot.exists) {
      final list =
          snapshot.children.map((e) => ActionLog.fromSnapshot(e)).toList();

      /// 첫번째 action 의 시간이 경과하려면 몇 초가 남았는지 계산한다.
      final first = list.first;
      final overtime = first.createdAt + seconds * 1000;
      final remain = overtime - DateTime.now().millisecondsSinceEpoch;
      dog(
        '제한 시간이 지나기까지 ${remain ~/ 1000} 초 남았다. ${ref!.path}',
      );
    }
  }
}

/// ActionLogService
///
/// 다른 사용자 프로필 보기를 1분에 3회로 제한 한 경우, 3회 제한이 걸리면, 이전에 본 다른 사용자의 프로필도 모두 볼 수 없다.
/// 단, 이전에 본 사용자의 프로필을 다시 보기 해도, 카운트가 증가하지는 않는다.
///
///
class ActionLogService {
  static ActionLogService? _instance;
  static ActionLogService get instance => _instance ??= ActionLogService._();
  ActionLogService._();

  ActionLogOption userProfileView = ActionLogOption(ref: null);
  ActionLogOption chatJoin = ActionLogOption(ref: null);
  Map<String, ActionLogOption> postCreate = {};
  ActionLogOption commentCreate = ActionLogOption(ref: null);

  List<StreamSubscription> subs = [];

  init({
    ActionLogOption? userProfileView,
    ActionLogOption? chatJoin,
    Map<String, ActionLogOption>? postCreate,
    ActionLogOption? commentCreate,
  }) {
    if (userProfileView != null) {
      this.userProfileView = userProfileView;
      // this.userProfileView.ref = ActionLog.userProfileViewRef;
      dog("[Check] Expect to updated ref's path. The myUid is $myUid.");
      this.userProfileView.ref = FirebaseDatabase.instance
          .ref()
          .child("action-logs/user-profile-view/$myUid");
    }
    if (chatJoin != null) {
      this.chatJoin = chatJoin;
      this.chatJoin.ref = ActionLog.chatJoinRef;
    }
    if (postCreate != null) {
      this.postCreate = postCreate;
      for (final key in postCreate.keys) {
        postCreate[key]!.ref = ActionLog.categoryCreateRef(key);
        postCreate[key]!.category = key;
      }
    }
    if (commentCreate != null) {
      this.commentCreate = commentCreate;
      this.commentCreate.ref = ActionLog.commentCreateRef;
    }

    listenActions();
  }

  /// [init] 이 호출 될 때 마다, 이전에 등록된 리스너를 모두 취소하고, 새로 리스너를 등록한다.
  ///
  /// 참고로, 새로 등록되는 설정만 리스너를 등록하도록 하면 좋을 것 같다.
  listenActions() {
    for (final sub in subs) {
      sub.cancel();
    }
    subs.clear();
    final subscriptions = [
      chatJoin,
      commentCreate,
      ...postCreate.values,
      userProfileView,
    ]
        .where(
            (element) => false == (element.ref == null)) // ref 가 null 인 경우는 제외
        .where((element) => element.limit > 0) // limit 이 0 인 경우 제외
        .toList();
    for (final actionOption in subscriptions) {
      // listen user view
      // print('---> ActionLogService.listenActions() - action: ${action.limit}');
      subs.add(
        actionOption.query!.onValue.listen((event) {
          actionOption.count = 0;
          if (event.snapshot.exists == false) {
          } else {
            // print(
            //     'listen actions; ${action.ref.path} -> ${event.snapshot.children.length}');
            actionOption.count = countFromSnapshot(
              snapshot: event.snapshot,
              option: actionOption,
            );
          }
        }, onError: (e) {
          dog('----> ActionLogService::listenActions() - with path: ${actionOption.ref!.path}, $e');
          if (e is FirebaseException && e.code == 'permission-denied') {
            /// Ignore permission-denied error because it usually happens when
            /// the user suddenly logs out.
          } else {
            throw e;
          }
        }),
      );
    }
  }

  /// Snapshot 의 데이터들에서 createdAt 이 seconds 보다 오래된 갯수를 리턴한다.
  countFromSnapshot({
    required DataSnapshot snapshot,
    required ActionLogOption option,
  }) {
    int count = 0;
    final overtime =
        DateTime.now().millisecondsSinceEpoch - (option.seconds * 1000);
    for (var snapshot in snapshot.children) {
      final actoin = ActionLog.fromSnapshot(snapshot);
      // print(" ${actoin.createdAt.toHis} > ${overtime.toHis}");
      if (actoin.createdAt > overtime) {
        count++;
      }
    }
    return count;
  }
}
