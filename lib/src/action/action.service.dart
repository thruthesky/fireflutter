import 'package:fireship/fireship.dart';

class ActionOption {
  bool enable;
  int limit;
  int minutes;
  int count;
  Future<bool?> Function()? overLimit;

  bool get isOverLimit => count >= limit;

  ActionOption({
    this.enable = false,
    this.limit = 100,
    this.minutes = 10000,
    this.count = 0,
    this.overLimit,
  });
}

class ActionService {
  static ActionService? _instance;
  static ActionService get instance => _instance ??= ActionService._();
  ActionService._();

  ActionOption userView = ActionOption();
  ActionOption chatJoin = ActionOption();
  ActionOption postCreate = ActionOption();
  ActionOption commentCreate = ActionOption();

  init({
    ActionOption? userView,
    ActionOption? chatJoin,
    ActionOption? postCreate,
    ActionOption? commentCreate,
  }) {
    if (userView != null) this.userView = userView;
    if (chatJoin != null) this.chatJoin = chatJoin;
    if (postCreate != null) this.postCreate = postCreate;
    if (commentCreate != null) this.commentCreate = commentCreate;

    listenActions();
  }

  listenActions() {
    if (userView.enable) {
      // listen user view
      Ref.userViewAction
          .limitToLast(userView.limit)
          .orderByChild('createdAt')
          .onValue
          .listen((event) {
        if (event.snapshot.exists == false) {
          userView.count = 0;
        } else {
          print('---> children count: ${event.snapshot.children.length}');
          userView.count = 0;
          final overtime = DateTime.now().millisecondsSinceEpoch -
              (userView.minutes * 60 * 1000);
          for (var snapshot in event.snapshot.children) {
            final actoin = ActionModel.fromSnapshot(snapshot);
            // print(" ${actoin.createdAt.toHis} > ${overtime.toHis}");
            if (actoin.createdAt > overtime) {
              userView.count++;
            }
          }
        }

        print('---> limit count: ${userView.count}');
      });
    }
  }
}
