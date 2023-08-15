import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:rxdart/rxdart.dart';

class UserService {
  static UserService? _instance;
  static UserService get instance => _instance ??= UserService._();

  /// null 이면 아직 로드를 안했다는 뜻이다. 즉, 로딩중이라는 뜻이다.
  ///
  final BehaviorSubject<UserModel?> userDocumentChanges = BehaviorSubject<UserModel?>.seeded(null);

  /// Currently login user's uid
  String get uid => FirebaseAuth.instance.currentUser!.uid;

  ///
  UserService._() {
    /// 로그인을 할 때, userModel 초기가 값 지정
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        userModel = null;
      } else {
        /// 이 후, 사용자 문서가 업데이트 될 때 마다, userModel 업데이트
        UserService.instance.doc.snapshots().listen((documentSnapshot) {
          /// 사용자 문서가 존재하지 않는 경우,
          if (!documentSnapshot.exists || documentSnapshot.data() == null) {
            userModel = UserModel(uid: '', exists: false);
          } else {
            userModel = UserModel.fromDocumentSnapshot(documentSnapshot);
          }
          userDocumentChanges.add(userModel);
        });
      }
    });
  }

  String get collectionName => UserModel.collectionName;

  get db => FirebaseFirestore.instance;

  /// Users collection reference
  CollectionReference get cols => db.collection(collectionName);

  /// User document reference of the currently login user
  DocumentReference get doc => cols.doc(uid);

  /// [_userCache] is a memory cache for [UserModel].
  ///
  /// Firestore 에서 한번 불러온 유저는 다시 불러오지 않는다. Offline DB 라서, 속도 향상은 크게 느끼지 못하지만, 접속을 아껴 비용을 절약한다.
  final Map<String, UserModel> _userCache = {};

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
  /// 예) EasyUser.instance.userModel?.photoUrl
  UserModel? userModel;

  /// userModel 의 getter 로 null operator 가 강제 적용된 것이다. 즉, userModel 이 null 이면
  /// Null check operator used on a null value 에러가 발생한다. 만약, 이 에러를 피하려면, 그냥
  /// userModel 을 쓰면 된다.
  ///
  UserModel get user => userModel!;

  String? get photoUrl => userModel?.photoUrl;

  /// 미리 한번 호출 해서, Singleton 을 초기화 해 둔다. 그래야 user 를 사용 할 때, 에러가 발생하지 않는다.
  init() {
    ///
  }

  /// Get user
  ///
  /// It does memory cache.
  /// If the user is already cached, it returns the cached value.
  /// Otherwise, it fetches from Firestore and returns the UserModel.
  /// If the user does not exist, it returns null.
  ///
  /// [reload] is a flag to force reload from Firestore.
  Future<UserModel?> get(String uid, [bool reload = false]) async {
    /// 캐시되어져 있으면, 그 캐시된 값(UserModel)을 리턴
    if (reload == false && _userCache.containsKey(uid)) return _userCache[uid];

    /// 아니면, Firestore 에서 불러와서 UserModel 을 만들어 리턴
    final u = await UserModel.get(uid);
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

    final model = UserModel(
      uid: u.uid,
      email: u.email ?? '',
      displayName: u.displayName ?? '',
      photoUrl: u.photoURL ?? '',
      createdAt: null,
    );
    userModel = await model.create();
  }

  /// Login user's document update
  ///
  /// Update a user document under /users/{uid} for the login user.
  ///
  /// This automatically updates the [userModel] value.
  Future<void> update({
    String? name,
    String? displayName,
    String? photoUrl,
    bool? hasPhotoUrl,
    String? phoneNumber,
    String? email,
    bool? complete,
    String? field,
    dynamic value,
  }) async {
    if (userModel == null) {
      throw Exception(Code.notLoggedIn);
    }

    userModel = await userModel!.update(
      name: name,
      displayName: displayName,
      photoUrl: photoUrl,
      hasPhotoUrl: hasPhotoUrl,
      phoneNumber: phoneNumber,
      email: email,
      complete: complete,
      field: field,
      value: value,
    );
  }
}
