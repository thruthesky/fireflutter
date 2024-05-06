import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:rxdart/rxdart.dart';

class UserSettingService {
  static UserSettingService? _instance;
  static UserSettingService get instance =>
      _instance ??= UserSettingService._();

  UserSettingService._();

  /// 사용자 설정 저장 모델
  ///
  /// `/user-settings/<my-uid>` 에 저장된 사용자 설정을 가져와 모델링하여 저장한다.
  /// 만약, 사용자가 로그인을 하지 않았거나, 로그인을 했어도 아직 DB 에서 읽고 있는 중이라면, 이 값은 null 이 된다.
  /// 사용자 설정을 읽지 못했거나 (예: 퍼미션 에러, 네트워크 에러 등) 성공적으로 설정값을 읽으면 이 값은 모델링된다.
  /// 즉, UserSetting.get() 함수가 호출되면 (에러가 있더라도) 이 모델 값은 설정이 된다.
  UserSetting? settings;

  /// 사용자 설정이 변경되면, 이 스트림을 통해 알 수 있다.
  ///
  /// 특히, 사용자가 로그인/로그아웃 할 때, 이 스트림 이벤트가 발생한다.
  BehaviorSubject<UserSetting?> changes =
      BehaviorSubject<UserSetting?>.seeded(null);

  /// 사용자 설정을 초기화 한다.
  ///
  /// [defaultCommentNotification] 이 true 로 지정되면,
  /// 사용자가 new comment notification 설정을 하지 않았으면 기본적으로 on 을 저장 해 준다. 즉, 처음 앱을 설치하면,
  /// 기본적으로 on 이 되도록 하는 것이다.
  ///
  init({
    bool defaultCommentNotification = true,
  }) {
    /// 로그인 하면,
    FirebaseAuth.instance
        .authStateChanges()
        .distinct((a, b) => a?.uid == b?.uid)
        .listen((user) async {
      if (user != null) {
        settings = await UserSetting.get(
          user.uid,
        );

        /// 새 코멘트 알림의 기본 설정을 on 으로 하려는 경우,
        if (defaultCommentNotification) {
          if (settings?.commentNotification == null) {
            await settings?.update(
              commentNotification: true,
            );
          }
        }
      }

      changes.add(settings);
    });
  }
}
