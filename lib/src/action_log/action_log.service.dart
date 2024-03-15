import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';

/// ActionLogOption
///
/// 만약, 특정 액션을 설정을 원하지 않는다면, ref 에 null 을 저장하면 된다. 그러면, 해당 액션은
/// 제한 설정을 하지 않는다.
class ActionLogOption {
  /// 주의: limit 걸어서 쿼리를 할 때, query 를 사용해야 한다.
  /// ref 를 사용하면, limit 이 적용되지 않는다. 다만, 개별 데이터가 존재하는지는 ref 를 써서 쿼리를 하면 된다.
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
  /// false 를 리턴하면, limit 에 걸려도 계속 실행을 하라는 뜻으로, 앱은 계속 실행을 해야 한다.
  ///
  /// 참고로, limit 에 걸린 경우, overLimit 함수를 호출하여, limit 에 걸렸을 때 어떻게 해야 할지 처리를 한다.
  /// overLiimit 함수에서 경고 메시지를 보내주거나 할 수 있다.
  /// overLimit 함수가 정의되지 않았거나, overLimit 함수가 아무것도 리턴하지 않거나, null 을 리턴하면, 최종적으로 true 를 리턴하여
  /// 나머지 수행을 멈춘다.
  /// 하지만, overLimit 함수가 false 를 리턴하면, 최종저긍로 limit 에 걸려도 계속 수행을 하게 된다.
  ///
  /// [roomId] 채팅방 ID. chatJoin 동작에서 limit 이 발생하는 경우, 채팅방 ID 를 넘겨주어, overLimit callback 함수에서
  /// 채팅방 ID 를 이용하여, 채팅방에 이미 참여했으면 false 를 리턴하여 경고 없이 채팅방에 접속을 할 수 있도록 한다.
  Future<bool> isOverLimit({String? uid, String? roomId}) async {
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

    /// 제한에 걸린 경우, (count 가 limit 보다 크거나 같은 경우)
    ///
    /// 그런데, 제한에 걸린 다음에는 더 이상, action 을 기록(로그)하지 못하므로, 앱을 껐다 켜지 않는한, action 을 못해, 새로운 로그가 생성되지 않아, 실시간 업데이트가 안된다.
    /// 그래서, 이곳에서 쿼리를 해서, 제한 시간이 지났는지 확인한다.
    /// 제한 시간이 지나면, count 를 업데이트해서, 다시 action 이 가능해 지고, 그러면 계속 action 이 가능해 지고, action 을 하면 새로운 로그를 기록하므로,
    /// init 에서 계속 action 로그를 발생 할 때 마다, 실시간 업데이트가 된다.
    final snapshot = await query!.get();
    count = ActionLogService.instance
        .countFromSnapshot(snapshot: snapshot, option: this);
    if (count < limit) {
      if (debug) dog('제한 시간이 지나서, 다시 action 이 가능해졌다. ${ref!.path}');
      return false;
    } else {
      if (debug) {
        logTimeLeft();
      }
    }

    print('----> isOverLimit() - uid: $uid, roomId: $roomId');

    /// 제한에 걸린 경우, action 이 public profile view 나 chat join 중 하나라면,
    /// 이전에 본 사용자 프로필이라면 계속 볼 수 있게 하고, 또 이전에 접속한 채팅방이면 계속 접속 할 수 있도록 해 준다.
    if (uid != null) {
      final re =
          await ActionLogService.instance.userProfileView.ref!.child(uid).get();
      if (re.exists) {
        print('--> But continue, userProfileView - uid: $uid');
        return false;
      }
    } else if (roomId != null) {
      /// 참고, chatJoin 동작에서 limit 이 발생하는 경우, 채팅방 ID 를 받는 대신, chatRoom model 을 받아서, users 필드에 내가 들어가 있는지 확인을 하면
      /// 여기서 async/await 을 하지 않아도 처리가 가능하다.
      final re =
          await ActionLogService.instance.chatJoin.ref!.child(roomId).get();
      if (re.exists) {
        print('--> But continue, chatJoin - roomId: $roomId');
        return false;
      }
    }

    /// 새로운 정보를 가져와도 여전히 limit 에 걸려 있다면, overLimit 함수를 호출하여, limit 에 걸렸을 때 어떻게 해야 할지 처리를 한다.
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
  logTimeLeft() async {
    final remain = await getTimeLeft();
    dog(
      '제한 시간이 지나기까지 ${remain ?? 0} 초 남았다. ${ref!.path}',
    );
  }

  /// 제한 시간이 지나기까지 몇 초가 남았는지 계산한다.
  ///
  /// 제한을 5개로 한다면, 그 중 첫 번째 action 의 시간이 경과하려면 몇 초가 남았는지 계산한다.
  ///
  /// 만약, 제한에 걸린 로그가 없으면, null 을 리턴한다. 즉, 로그가 없다는 뜻이다.
  ///
  /// Example:
  /// ```
  /// final timeLeft = await ActionLogService.instance.chatJoin.getTimeLeft();
  /// print('Time left: $timeLeft');
  /// final dt = DateTime.now().add(Duration(seconds: timeLeft ?? 0));
  /// print('Try again at ${DateFormat.jm().format(dt)}');
  /// jm = DateFormat.jm().format(dt);
  /// ```
  Future<int?> getTimeLeft() async {
    final snapshot = await query!.get();
    if (snapshot.exists) {
      final list =
          snapshot.children.map((e) => ActionLog.fromSnapshot(e)).toList();

      /// 첫번째 action 의 시간이 경과하려면 몇 초가 남았는지 계산한다.
      final first = list.first;
      final overtime = first.createdAt + seconds * 1000;
      final remain = overtime - DateTime.now().millisecondsSinceEpoch;
      return remain ~/ 1000;
    } else {
      return null;
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
      this.userProfileView.ref = ActionLog.userProfileViewRef;
      dog("[Check] Expect to updated ref's path. The myUid is $myUid. this.userProfileView.ref path is ${this.userProfileView.ref?.path}");
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
    print('---> ActionLogService.listenActions()');
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
        .where((element) =>
            element.limit >
            0) // limit 이 0 인 경우 제외. 무조건 제한이므로, 결제한 사용자만 action 가능. 즉, 따로 action 을 count 할 필요 없음.
        .toList();

    dog('---> Actions to listen: ${subscriptions.length}');
    for (final actionOption in subscriptions) {
      // listen user view
      dog('---> ActionLogService.listenActions() - action: for ${actionOption.ref?.path} limit: ${actionOption.limit}');

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
