import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/widget/user/profile_followers.screen.dart';
import 'package:fireflutter/src/widget/user/profile_following.screen.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

/// [my] is an alias of [UserService.instance.user].
///
/// [my] is updated with the latest user document but it is a bad idea to use it
/// on the app booting process. But don't use it immediately after login,
/// because it takes time to load the document from the firestore. In the case
/// of a 'null check operator used in a null value' error happens especially on
/// the test(test UI design) in root widget, you would suspect that [my] or
/// [UserService.instance.user] is null due to the latency of loading user
/// document from the firestore.
///
/// Don't use [my] on unit testing due to the latency of the sync with
/// firestore, it would have a wrong value.
///
///
/// Example
/// UserService.instance.documentChanges.listen((user) => user == null ? null : print(my));
/// my.update(state: stateController.text);
User get my => UserService.instance.user;

auth.User get currentUser => auth.FirebaseAuth.instance.currentUser!;
String get providerId => currentUser.providerData.first.providerId;

bool get isAnonymous => auth.FirebaseAuth.instance.currentUser?.isAnonymous ?? false;

/// Return true if the user signed with real account. Not anonymous.
bool get notLoggedIn => isAnonymous || auth.FirebaseAuth.instance.currentUser == null;

bool get loggedIn => !notLoggedIn;

/// Use this to check if the user document is ready.
bool get myDocumentReady => UserService.instance.nullableUser != null;

/// [myUid] is an alias of [FirebaseAuth.instance.currentUser?.uid].
///
/// You can use [myUid] as early as you can since [my.uid] is slow to be set.
/// [my.uid] 는 사용 준비가 느린데, [myUid] 는 빠르게 사용 할 수 있다.
String? get myUid => auth.FirebaseAuth.instance.currentUser?.uid;

class UserService {
  static UserService? _instance;
  static UserService get instance => _instance ??= UserService._();

  UserCustomize customize = UserCustomize();

  /// Admin user model
  ///
  /// If [adminUid] is set on init(), then [admin] will have the admin user document model.
  ///
  /// It is used to send a welcome message when the user registers. Or you may
  /// use it to let users to chage with admin.
  User? admin;

  /// [documentChanges] fires event for when
  /// - app boots.
  ///   - when app boots, if user didn't login in, it will be null.
  ///   - while the app is loading(reading) the user document, it will be null. (it will be null for a short time.)
  /// - user document is updated.
  /// - the event data will be
  ///   - null if the user signed out.
  ///   - null for the short time when the app is loading(reading) the user document.
  ///   - [event.data.exists] will be false if the user document does not exist.
  ///
  /// null 이면 아직 로드를 안했다는 뜻이다. 즉, 로딩중이라는 뜻이다. 로그인을 했는지 하지 않았는지 여부는 알 수 없다.
  /// 만약, 로그인을 했는지 여부를 알고 싶다면, [nullableUser] 가 null 인지 아닌지를 확인하면 된다.
  ///
  /// Example;
  /// ```dart
  /// UserService.instance.documentChanges.listen((user) => user == null ? null : print(my));
  /// ```
  ///
  final BehaviorSubject<User?> documentChanges = BehaviorSubject<User?>.seeded(null);

  /// [userChanges] fires when
  /// - app boots
  ///   - when app boots, if user didn't login in, it will be null.
  /// - when user login
  /// - when user logout. (it will be null)
  ///
  /// Note that, the difference from [documentChanges] is that this happens
  /// when user logs in or out while [documentChanges] happens when the user
  /// document changes.
  final BehaviorSubject<auth.User?> userChanges = BehaviorSubject<auth.User?>.seeded(null);

  ///
  UserService._();

  /// Users collection reference
  CollectionReference get col => userCol;

  /// User document reference of the currently login user
  DocumentReference get doc => col.doc(myUid);

  /// [_userCache] is a memory cache for [User].
  ///
  /// Firestore 에서 한번 불러온 유저는 다시 불러오지 않는다. Offline DB 라서, 속도 향상은 크게 느끼지 못하지만, 접속을 아껴 비용을 절약한다.
  final Map<String, User> _userCache = {};

  /// Current user model
  ///
  /// [nullableUser] is updated when the user document is updated. And
  /// [nullableUser] will be null when the user signed out.
  ///
  /// If it is not null, then it means the user has signed in.
  /// if [nullableUser.exists] is false, it menas user has signed in but has no
  /// user document in the firestore.
  ///
  /// [nullableUser] will be updated whenever the user document is updated.
  ///
  /// Use [UserDoc] widget if you want to show the user document in real time.
  ///
  /// 사용자가 로그인 할 때 마다 해당 사용자의 문서 값으로 바뀌고, 그리고 실시간 자동 업데이트를 한다.
  /// 실시간 자동 문서를 화면에 보여주어야 한다면 [UserDoc] 위젯을 사용하면 된다.
  ///
  /// 예) UserService.instance.nullableUser?.photoUrl
  ///
  /// 참고,
  /// 사용자가 로그인을 했어도, [nullableUser] 는 null 일 수 있다. 이 것은 Auth 에 로그인 한 다음,
  /// Firestore 의 /users 컬렉션으로 부터 사용자 문서를 가져오는데 시간이 걸릴 수 있는데, 그 사이에
  /// [nullableUser] 를 참조하면, 로그인 했지만 null 이다. 하지만, 이 시간 사이에 [documentChanges]
  /// 이벤트가 발생하지 않는다.
  ///
  /// 따라서, FirebaseAuth 에 사용자가 로그인을 했는지 안했는지 빠르게 확인을 해야한다면,
  /// [auth.FirebaseAuth.authStateChanges] 를 통해서 하고, 천천히 확인을 해도 된다면,
  /// [UserService.instance.documentChanges] 이벤트를 리슨해서, null 이 아니면, 로그인 한 것이며,
  /// [exists: false] 이 아니면, 사용자 문서가 존재하는 것으로 판단하면 된다.
  ///
  User? nullableUser;

  /// [nullableUser] 의 getter 로 물음표(?) 없이 간단하게 쓰기 위한 것으로 null operator 가 강제 적용된
  /// 것이다. 따라서, [nullableUser] 이 null 인데, [user] 를 사용하면, Null check operator used
  /// on a null value 에러가 발생한다. 만약, 이 에러를 피하려면, 그냥 nullableUser 을 쓰거나,
  /// [documentChanges] 를 통해서 값이 있는 경우만 쓰면 된다.
  ///
  /// 예를 들면 아래의 코드와 같다. 앱이 최초 로딩 할 때, [my] 또는 [user] 를 쓰면 nullableUser 가 null 이므로
  /// 에러가 나는데, 아래와 같이 하면 에러가 발생하지 않는다.
  /// UserService.instance.documentChanges.listen((user) => user == null ? null : print(my));
  ///
  User get user => nullableUser!;

  ///
  bool get isAdmin => nullableUser?.isAdmin ?? false;
  String? get photoUrl => nullableUser?.photoUrl;

  /// Returns the stream of the user model for the current login user.
  ///
  /// Use this to display widgets lively that depends on the user model. When
  /// the user document is updated, this stream will fire an event.
  Stream<User> get snapshot {
    return myDoc.snapshots().map(
          (DocumentSnapshot doc) => doc.exists ? User.fromDocumentSnapshot(doc) : User.nonExistent(),
        );
  }

  /// User create event. It fires when a user document is created.
  Function(User user)? onCreate;

  /// If any of the user document field updates, then this callback will be called.
  /// For instance, when a user creates a post or a comment, the no of posts or
  /// comments are updated in user document. Hence [onUpdate] will be called.
  Function(User user)? onUpdate;
  Function(User user)? onDelete;

  Function(User user)? onSignout;

  bool enableNoOfProfileView = false;

  /// If [enableMessagingOnPublicProfileVisit] is set to true it will send push notification
  /// when showPublicProfileScreen is called
  /// this will send a push notification to the visited profile
  /// and indicating that the current user visited that profile
  ///
  ///
  bool enableMessagingOnPublicProfileVisit = false;

  /// [onLike] is called when a post is liked or unliked by the login user.
  void Function(User user, bool isLiked)? onLike;

  // Enable/Disable push notification when profile was liked
  bool enableNotificationOnLike = false;

  /// 미리 한번 호출 해서, Singleton 을 초기화 해 둔다. 그래야 user 를 사용 할 때, 에러가 발생하지 않는다.
  init({
    String? adminUid,
    bool enableNoOfProfileView = false,
    Function(User user)? onCreate,
    Function(User user)? onUpdate,
    Function(User user)? onDelete,
    Function(User user)? onSignout,
    UserCustomize? customize,
    bool enableMessagingOnPublicProfileVisit = false,
    void Function(User user, bool isLiked)? onLike,
    bool enableNotificationOnLike = false,
  }) {
    dog('UserService.instance.init() - adminUid: $adminUid');

    if (adminUid != null && adminUid.isNotEmpty) {
      UserService.instance.get(adminUid).then((value) => admin = value);
    }

    if (customize != null) {
      this.customize = customize;
    }

    this.enableNoOfProfileView = enableNoOfProfileView;
    this.enableMessagingOnPublicProfileVisit = enableMessagingOnPublicProfileVisit;
    this.onCreate = onCreate;

    /// [onUpdate] will be triggered every time user is being updated.
    /// See user.dart and check the [update] method.
    this.onUpdate = onUpdate;
    this.onDelete = onDelete;
    this.onSignout = onSignout;

    this.onLike = onLike;
    this.enableNotificationOnLike = enableNotificationOnLike;

    /// Listener for the login event
    ///
    /// This listens the user login and logout event. And sets the [nullableUser].
    ///
    /// Note that, it will create the user document if it does not exist.
    auth.FirebaseAuth.instance
        .authStateChanges()

        /// To prevent for the login event firing muliple times.
        .distinct((p, n) => p?.uid == n?.uid)
        .listen((firebaseUser) {
      if (firebaseUser == null) {
        // User logged out. Set nullableUser to null.
        nullableUser = null;
        documentChanges.add(nullableUser);
        userChanges.add(null);
      } else {
        // User logged in.
        dog('UserService.instance.init() - User logged in: ${firebaseUser.uid}');
        // Fire user login event
        userChanges.add(firebaseUser);
        _listenUserDocument();
      }
    });
  }

  /// Listen the login user's document and set the [nullableUser] when the
  /// document is updated.
  ///
  /// The app may initialize the [UserService] more than once, so we need to
  /// cancel the previous subscription. Meaning, the app can initialize the
  /// [UserService] multiple times.
  StreamSubscription? _userDocuementSubscription;
  _listenUserDocument() {
    _userDocuementSubscription?.cancel();
    _userDocuementSubscription = doc.snapshots().listen((documentSnapshot) async {
      /// User document does not exist. Create the user document.
      ///
      if (!documentSnapshot.exists || documentSnapshot.data() == null) {
        dog('user.service.dart _listenUserDocument() - User document does not exist. Create the user document for the user $myUid');
        await User.create(uid: myUid!);
      } else {
        nullableUser = User.fromDocumentSnapshot(documentSnapshot as DocumentSnapshot<Map<String, dynamic>>);
      }
      documentChanges.add(nullableUser);
    });
  }

  /// Returns the stream of the user model of the user document for the user uid.
  ///
  Stream<User> snapshotOther(String uid) {
    return userDoc(uid).snapshots().map((doc) => User.fromDocumentSnapshot(doc));
  }

  /// Get user
  ///
  /// It does memory cache.
  /// If the user is already cached, it returns the cached value.
  /// Otherwise, it fetches from Firestore and returns the User.
  /// If the user does not exist, it returns null.
  ///
  /// [reload] is a flag to force reload from Firestore.
  ///
  /// [sync] if [sync] is set to true, then it gets user data from realtime database.
  /// Or if [sync] is set to false, it will get the user data under '/users'
  /// collection from firestore.
  ///
  /// Example
  /// ```
  /// UserService.instance.get(myUid!, reload: true, sync: false);
  /// ```
  ///
  /// Note that, it does not throw an Exception when the user document does not
  /// exist. It just returns null.
  /// The above example is same as [User.get]
  Future<User?> get(
    String uid, {
    bool reload = false,
  }) async {
    if (uid == '') return null;

    /// 캐시되어져 있으면, 그 캐시된 값(User)을 리턴
    if (reload == false && _userCache.containsKey(uid)) {
      /// Mark that the user data is cached
      _userCache[uid]!.cached = true;
      return _userCache[uid];
    }

    /// 아니면, Firestore 또는 RTDB 에서 사용자 문서를 가져와 User 을 만들어 리턴.
    /// * 주의: 만약, 사용자 문서가 존재하지 않으면 null 을 리턴하며, 캐시에도 저장하지 않는다. 즉, 다음 호출시 다시
    /// * 로드 시도한다. 이것은 UserService.instance.nullableUser 가 null 이 되는 것과 다른 것이다.

    final User? u = await User.get(uid);

    if (u == null) return null;
    _userCache[uid] = u;
    return _userCache[uid];
  }

  /// Sign out from Firebase Auth
  Future<void> signOut() async {
    await onSignout?.call(my);
    await auth.FirebaseAuth.instance.signOut();
  }

  /// Create user document
  ///
  /// Create a user document under /users/{uid} for the login user with the Firebase Auth user data.
  ///
  /// If the user document already exists, it throws an exception.
  Future<void> create() async {
    if ((await doc.get()).exists) {
      throw Exception(Code.documentAlreadyExists);
    }

    final u = auth.FirebaseAuth.instance.currentUser!;

    nullableUser = await User.create(uid: u.uid);
  }

  /// Returns a Stream of User model for the current login user.
  ///
  /// Use this with [StreamBuilder] for real time update(listen) of the login user document.
  ///
  /// Example
  /// ```dart
  /// StreamBuilder<User?>(
  ///   stream: UserService.instance.listen(widget.user.uid),
  ///   builder: (context, snapshot) {
  ///     user = snapshot.data!;
  /// ```
  ///
  /// Note that, you can use [UserDoc] for real time update of the user document.
  Stream<User?> listen() {
    return doc
        .withConverter<User>(
          fromFirestore: (snapshot, _) => User.fromDocumentSnapshot(snapshot),
          toFirestore: (user, _) => user.toMap(),
        )
        .snapshots()
        .map(
          (event) => event.data(),
        );
  }

  /// Send a welcome message on registration
  ///
  /// Send a welcome message to the user when the user registers by creating
  /// a 1:1 chat room with admin.
  ///
  /// Since there is no way to send a message from the admin to the login user
  /// automatically, the app just sends a welcome message to the user himself
  /// and put the protocol as 'register'. Then, the app will show the welcome
  /// post card on the chat room.
  ///
  Future<void> sendWelcomeMessage({required String message}) async {
    if (admin == null) {
      log("-----> admin is not set on UserService.instance.init() <-----");
    }
    final room = await Room.create(
      otherUserUid: admin!.uid,
    );
    await ChatService.instance.sendProtocolMessage(
      room: room,
      text: message,
      protocol: Protocol.register.name,
    );
    await noOfNewMessageRef(uid: myUid!).update({
      room.roomId: 1,
    });
  }

  /// Open public profile dialog
  ///
  /// It shows the public profile dialog for the user. You can customize by
  /// setting [UserCustomize] to [UserService.instance.customize].
  ///
  /// Send notification even if enableMessagingOnPublicProfileVisit is set to false
  /// set `sendNotification` to `true` to send push notification
  Future showPublicProfileScreen({required BuildContext context, String? uid, User? user}) {
    final String otherUid = uid ?? user!.uid;
    final now = DateTime.now();

    /// Dynamic link is especially for users who are not install and not signed users.
    if (loggedIn && enableNoOfProfileView) {
      profileViewHistoryDoc(myUid: my.uid, otherUid: otherUid).set(
        {
          "uid": otherUid,
          "seenBy": my.uid,
          "type": my.type,
          "lastViewdAt": FieldValue.serverTimestamp(),
          "year": now.year,
          "month": now.month,
          "day": now.day,
        },
        SetOptions(merge: true),
      );
    }

    if (loggedIn && (enableMessagingOnPublicProfileVisit) && myUid != otherUid) {
      MessagingService.instance.queue(
        title: "Your profile was visited.",
        body: "${my.name} visit your profile",
        id: myUid,
        uids: [otherUid],
        type: NotificationType.user.name,
      );
    }

    return customize.showPublicProfileScreen?.call(context, uid: uid, user: user) ??
        showGeneralDialog(
          context: context,
          pageBuilder: ($, _, __) => PublicProfileScreen(uid: uid, user: user),
        );
  }

  showFollowersScreen({required BuildContext context, User? user, Widget Function(User)? itemBuilder}) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) {
        return ProfileFollowerSceen(itemBuilder: itemBuilder, user: user ?? my);
      },
    );
  }

  showFollowingScreen({required BuildContext context, User? user, Widget Function(User)? itemBuilder}) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) {
        return ProfileFollowingScreen(
          user: user ?? my,
          itemBuilder: itemBuilder,
        );
      },
    );
  }

  showBlockedListScreen({required BuildContext context, required User user, Widget Function(User?)? itemBuilder}) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Blocked List'),
          ),
          body: FutureBuilder(
            future: user.blockedList,
            builder: (context, snapshot) {
              return UserListView.builder(uids: (snapshot.data ?? []), itemBuilder: itemBuilder);
            },
          ),
        );
      },
    );
  }

  showViewersScreen({required BuildContext context, Widget Function(User)? itemBuilder}) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) {
        return ProfileViewersListScreen(
          itemBuilder: itemBuilder,
        );
      },
    );
  }

  showPushNotificationSettingScreen({
    required BuildContext context,
  }) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) {
        return const PushNotificationSettingScreen();
      },
    );
  }

  /// Delete user document
  Future deleteDocuments() async {
    await my.delete();
    await myPrivateDoc.delete();
  }

  showLikedByListScreen({required BuildContext context, required List<String> uids}) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) {
        return UserLikedByListScreen(uids: uids);
      },
    );
  }

  /// Callback function when a user was liked or unliked.
  /// send only when user liked the other user.
  Future sendNotificationOnLike(User user, bool isLiked) async {
    if (enableNotificationOnLike == false) return;
    if (isLiked == false) return;

    MessagingService.instance.queue(
      title: 'New likes on your profile.',
      body: "${my.name} liked your profile",
      id: myUid,
      uids: [user.uid],
      type: NotificationType.user.name,
    );
  }
} // EO UserService
