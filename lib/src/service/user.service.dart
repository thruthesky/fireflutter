import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:fireflutter/fireflutter.dart';
import 'package:rxdart/rxdart.dart';

/// [my] is an alias of [UserService.instance.user].
///
/// 예제
/// UserService.instance.documentChanges.listen((user) => user == null ? null : print(my));
/// my.update(state: stateController.text);
User get my => UserService.instance.user;

class UserService with FirebaseHelper {
  static UserService? _instance;
  static UserService get instance => _instance ??= UserService._();

  /// null 이면 아직 로드를 안했다는 뜻이다. 즉, 로딩중이라는 뜻이다. 로그인을 했는지 하지 않았는지 여부는 알 수 없다.
  /// 만약, 로그인을 했는지 여부를 알고 싶다면, [nullableUser] 가 null 인지 아닌지를 확인하면 된다.
  ///
  /// UserService.instance.documentChanges.listen((user) => user == null ? null : print(my));
  final BehaviorSubject<User?> documentChanges = BehaviorSubject<User?>.seeded(null);

  ///
  UserService._() {
    /// 로그인을 할 때, nullableUser 초기가 값 지정
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        nullableUser = null;
        documentChanges.add(nullableUser);
      } else {
        /// 이 후, 사용자 문서가 업데이트 될 때 마다, nullableUser 업데이트
        UserService.instance.doc.snapshots().listen((documentSnapshot) {
          /// 사용자 문서가 존재하지 않는 경우,
          /// * exists: false 는 오직, documentChanges 이벤트에만 적용된다.
          if (!documentSnapshot.exists || documentSnapshot.data() == null) {
            nullableUser = User(uid: '', exists: false);
          } else {
            nullableUser = User.fromDocumentSnapshot(documentSnapshot as DocumentSnapshot<Map<String, dynamic>>);
          }
          documentChanges.add(nullableUser);
        });
      }
    });
  }

  /// Users collection reference
  CollectionReference get col => userCol;

  /// User document reference of the currently login user
  DocumentReference get doc => col.doc(uid);

  /// [_userCache] is a memory cache for [User].
  ///
  /// Firestore 에서 한번 불러온 유저는 다시 불러오지 않는다. Offline DB 라서, 속도 향상은 크게 느끼지 못하지만, 접속을 아껴 비용을 절약한다.
  final Map<String, User> _userCache = {};

  /// Current user model
  ///
  /// It will be initialized whenever the user is logged in and whenever
  /// the user document is updated. Use [UserDoc] widget if you want to
  /// show the user document in real time.
  ///
  /// 사용자가 로그인 할 때 마다 해당 사용자의 값으로 바뀌고, 그리고 실시간 자동 업데이트를 한다.
  /// 실시간 자동 문서를 화면에 보여주어야 한다면 [UserDoc] 위젯을 사용하면 된다.
  ///
  ///
  /// 예) EasyUser.instance.nullableUser?.photoUrl
  ///
  /// Note, that [exists: false] is only applied to [documentChanges] event.
  /// This means,
  /// - even if the user is logged in, [nullableUser] may be null (while app boots and loads the user document)
  /// - if [nullableUser] is not null, it means, the user has logged in and the docuemnt has loaded. But the document may not exist.
  /// - if `exists: false`, it means, the user has logged in, and the app tried to load the docuemnt, but document does not exist.
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

  /// 미리 한번 호출 해서, Singleton 을 초기화 해 둔다. 그래야 user 를 사용 할 때, 에러가 발생하지 않는다.
  init() {
    ///
  }

  /// Returns the stream of the user model for the current login user.
  ///
  /// Use this to display widgets lively that depends on the user model. When
  /// the user document is updated, this stream will fire an event.
  Stream<User> get snapshot {
    return UserService.instance.col.doc(uid).snapshots().map((doc) => User.fromDocumentSnapshot(doc));
  }

  /// Returns the stream of the user model for the user uid.
  ///
  /// This method stream the update of the user document from realtime database and returns
  /// the stream of the user model.
  ///
  /// Note that, '/users' collection in firestore is secured by security rules.
  Stream<User> snapshotOther(String uid) {
    return UserService.instance.rtdb.ref().child('/users/$uid').onValue.map(
      (event) {
        return User.fromMap(map: Map<String, dynamic>.from((event.snapshot.value ?? {}) as Map), id: uid);
      },
    );
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
  /// Or it will get the user_search_data document from firestore.
  Future<User?> get(
    String uid, {
    bool reload = false,
    bool sync = true,
  }) async {
    /// 캐시되어져 있으면, 그 캐시된 값(User)을 리턴
    if (reload == false && _userCache.containsKey(uid)) {
      /// Mark that the user data is cached
      _userCache[uid]!.cached = true;
      return _userCache[uid];
    }

    /// 아니면, Firestore 또는 RTDB 에서 사용자 문서를 가져와 User 을 만들어 리턴.
    /// * 주의: 만약, 사용자 문서가 존재하지 않으면 null 을 리턴하며, 캐시에도 저장하지 않는다. 즉, 다음 호출시 다시
    /// * 로드 시도한다. 이것은 UserService.instance.nullableUser 가 null 이 되는 것과 다른 것이다.

    late final User? u;
    if (sync) {
      u = await User.getFromDatabaseSync(uid);
    } else {
      u = await User.get(uid);
    }
    if (u == null) return null;
    _userCache[uid] = u;
    return _userCache[uid];
  }

  /// Sign out from Firebase Auth
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  /// Create a user document under /users/{uid} for the login user with the Firebase Auth user data.
  ///
  /// If the user document already exists, it throws an exception.
  Future<void> create() async {
    if ((await doc.get()).exists) {
      throw Exception(Code.documentAlreadyExists);
    }

    final u = FirebaseAuth.instance.currentUser!;

    final model = User(
      uid: u.uid,
      email: u.email ?? '',
      displayName: u.displayName ?? '',
      photoUrl: u.photoURL ?? '',
      createdAt: null,
    );
    nullableUser = await model.create();
  }

  /// Login user's document update
  ///
  /// Update a user document under /users/{uid} for the login user.
  ///
  /// This automatically updates the [nullableUser] value.
  Future<User?> update({
    String? name,
    String? firstName,
    String? lastName,
    String? middleName,
    String? displayName,
    String? photoUrl,
    bool? hasPhotoUrl,
    String? idVerifiedCode,
    String? phoneNumber,
    String? email,
    String? state,
    String? stateImageUrl,
    int? birthYear,
    int? birthMonth,
    int? birthDay,
    bool? complete,
    String? field,
    dynamic value,
  }) async {
    if (nullableUser == null) {
      throw Exception(Code.notLoggedIn);
    }

    nullableUser = await nullableUser!.update(
      name: name,
      firstName: firstName,
      lastName: lastName,
      middleName: middleName,
      displayName: displayName,
      photoUrl: photoUrl,
      idVerifiedCode: idVerifiedCode,
      phoneNumber: phoneNumber,
      email: email,
      state: state,
      stateImageUrl: stateImageUrl,
      birthYear: birthYear,
      birthMonth: birthMonth,
      birthDay: birthDay,
      complete: complete,
      field: field,
      value: value,
    );

    return nullableUser;
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
} // EO UserService
