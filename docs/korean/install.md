# 설치

FireFlutter 는 단순히 pub.dev 에 있는 것을 Flutter 에 dependency 추가 및 시작 코드 작성한다고 되는 것이 아니다. 앱이 올바로 동작하기 위해서는 각종 Security Rules, Cloud Functions 등이 같이 설치되어야 한다.

본 문서에서는 이러한 설치에 대한 설명을 한다.


## Firebase 프로젝트 준비


새로운 프로젝트(또는 기존 프로젝트)에서 아래의 기능을 활성화 한다.

```txt
Authentication
Firestore
Functions
Realtime Database
Messaging
Storage
```


### Firebase Security Rules 설치

Security rules 에는 Firestore, Realtime Database, Storage 와 같이 세 가지가 있다. 각각의 Security rules 파일은 [assets 폴더](../assets/) 에서 찾을 수 있다. 각 Security files 을 복사(또는 수정)하여 Firebase 에 추가하도록 한다.


### FireFlutter Functions 설치

- FireFlutter 의 클라우드 함수를 배포해야하는데, 그 전에 설정을 해야 한다.
- 설정 파일 `config.ts` 를 열고 region, firestoreRegion, databaseRegion 이렇게 세 가지를 수정 해야 한다.
  - `region` 은 2nd cloud functions 의 위치를 지정하는 것으로, realtime database 의 위치와 동일한 위치를 지정하면 된다.
  - `firestoreRegion` 에는 Firestore 의 위치를 지정하면 된다.
  - `databaseRegion` 에는 Realtime Database 의 위치를 지정하면 된다.
- 그리고 아래와 같이 deploy 하면 된다.
  - `cd functions`
  - `npm run deploy`



## Fireflutter 패키지 설치

패키지 설치는 단순히, pub.dev 의 최신 버전을 설치하면 된다.

먼저 플러터 앱을 생성한다.

```sh
flutter create --org com.xxx app
```

그리고 아래와 같이 Firebase 관련 패키지를 설치한다. FlutterFire 의 BoM 2.1.0 버전을 설치하면 된다. 참고로 flutterfire 는 플러터에서 firebase 관련 설정을 도와주는 것이다. FireFlutter 와 혼동되지 않도록 한다.

```sh
flutterfire install 2.1.0
```

위 명령을 실행 후, `Core,Authentication,Firestore,Functions,Realtime Database,Messaging, Storage` 를 선택하면 된다.

만약 수동으로 설치하고자 한다면, 아래의 버전을 설치하면 된다.

```txt
Core: 3.1.0
Authentication: 5.1.0
Firestore: 5.0.1
Functions: 5.0.1
Realtime Database: 11.0.1
Messaging: 15.0.1
Storage: 12.0.1
```

그리고 아래와 같이 프로젝트에 Firebase 를 연결한다.

```sh
flutterfire config -a com.xxx.app -i com.xxx.app -p withcenter-test-3
```

그리고 플러터 main.dart 소스 코드에서 아래와 같이 Firebase 를 연결한다.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}
```

그리고, Podfile 에서 아래와 같이 platform :ios 버전을 13 이상으로 해 준다.

```pod
platform :ios, '13.0'
```

그리고 아래와 같이 firestore pre-compliled sdk 를 Podfile 에 추가해 준다.

```pod
target 'Runner' do
  pod 'FirebaseFirestore', :git => 'https://github.com/invertase/firestore-ios-sdk-frameworks.git', :tag => '10.27.0'
end
```

그리고 FireFlutter 를 설치한다.

```
% flutter pub add fireflutter
```

그리고 [빠르게 시작하기(퀵 스타트)](./quick_start.md#빠르게-시작하기) 항목에 나오는 로그인 코드를 복사 & 붙여 넣기 하여, 회원 로그인과 로그아웃 코드를 작성하여 잘 실행되는지 테스트 한다.

다음은 FireFlutter 작업을 할 때, 권장하는 기본 코드이다. 참고로 아래의 코드가 동작하기 위해서는 Firebase 가 올바로 설정되어져 있어야 하며, Push notification 을 위한 설정이 올바로 되어져 있어야 한다. 예를 들면, ios 에서 push notification 이 동작하기 위해서는 Firebase 에 apn auth key 를 등록하고, xcode 에서 push notification, background mode(background fetch, remote notification), info(url type 에 encoded app id 와 bundle id ) 등을 설정 해 주어야 한다.


우선 pubspec.yaml 의 파일 내용은 아래와 같다.

```yaml
name: buyandsell
description: "A new Flutter project."

publish_to: 'none' 

version: 1.0.0+1

environment:
  sdk: '>=3.4.3 <4.0.0'

dependencies:
  cloud_firestore: 5.0.1
  cloud_functions: 5.0.1
  connectivity_plus: ^6.0.3
  cupertino_icons: ^1.0.6
  dio: ^5.4.3+1
  easystate: ^1.0.3
  firebase_auth: 5.1.0
  firebase_core: 3.1.0
  firebase_database: 11.0.1
  firebase_messaging: 15.0.1
  firebase_storage: 12.0.1
  fireflutter:
    path: ../..
  flutter:
    sdk: flutter
  flutter_local_notifications: ^17.1.2
  go_router: ^14.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
```

main.dart 의 내용은 아래와 같이 한다.
- Info.plist 파일에 아래와 같이, 기본적인 것들을 추가해 주어야 한다. 언어 코드, entitlement, application scheme 등 일반적으로 필요한 기능들이며, fireflutter 에서도 필요로하는 것들이다.
```xml
<key>CFBundleLocalizations</key>
	<array>
		<string>en</string>
		<string>ko</string>
	</array>
	<key>NSCameraUsageDescription</key>
	<string>...</string>
	<key>NSMicrophoneUsageDescription</key>
	<string>...</string>
	<key>NSPhotoLibraryUsageDescription</key>
	<string>...</string>
	<key>LSApplicationQueriesSchemes</key>
	<array>
		<string>sms</string>
		<string>tel</string>
		<string>https</string>
	</array>
```
- 참고로 아래의 설정에서 dynamic link 설정은 빠져있다. Dynamic link 에 대한 자세한 내용은 [Dynamic Link](./dynamic_link.md) 항목을 참고한다.

```dart
import 'dart:async';

import 'package:buyandsell/firebase_options.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easystate/easystate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey();
BuildContext get globalContext => globalNavigatorKey.currentContext!;

/// GoRouter
final router = GoRouter(
  navigatorKey: globalNavigatorKey,
  routes: [
    GoRoute(
      path: HomeScreen.routeName,
      pageBuilder: (context, state) => NoTransitionPage<void>(
        key: state.pageKey,
        child: const HomeScreen(),
      ),
    ),
  ],
);

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(
      EasyState(
        state: AppState(),
        child: const MyApp(),
      ),
    );

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
    };
  }, runZonedGuardedHandler);
}

class AppState extends ChangeNotifier {
  int counter = 0;

  void increment() {
    counter++;
    notifyListeners();
  }
}

runZonedGuardedHandler(e, stackTrace) {
  dog("---> runZonedGuardedHandler(); runtimeType: ${e.runtimeType}");
  if (e is FirebaseAuthException) {
    toast(
        context: globalContext,
        message: '로그인 관련 에러 :  ${e.code} - ${e.message}');
  } else if (e is FirebaseException) {
    dog("FirebaseException :  $e }");
    if (e.code.contains('permission-denied')) {
      error(context: globalContext, message: '권한이 없습니다.');
    }
  } else if (e is FireFlutterException) {
    dog("FireFlutterException: (${e.code}) - ${e.message}");
    error(context: globalContext, message: e.message);
  } else {
    dog("Unknown Error :  $e");
    if (e.toString().contains('@phone_sign_in/malformed-phone-number')) {
      error(context: globalContext, message: '전화번호가 올바르지 않습니다.');
    } else {
      error(context: globalContext, message: '알 수 없는 에러가 발생했습니다. - $e');
    }
  }
  debugPrintStack(stackTrace: stackTrace);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    FireFlutterService.instance.init(
      cloudFunctionRegion: 'asia-southeast1',
      globalContext: () => globalContext,
    );
    AdminService.instance.init();
    UserService.instance.init();
    ChatService.instance.init();
    ForumService.instance.init();
    initFirstInternetConnection();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageCode = getLanguageCode(context);
    TextService.instance.init(languageCode: languageCode);
    initIntlDefaultLocale(context);
  }

  @override
  void dispose() {
    connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizationsDelegate(), // 여기에 위의 클래스를 집어 넣는다.
      ],
      locale: null,
      supportedLocales: AppLocalizations.locales,
    );
  }

  /// Run code on the first internet connection
  ///
  /// It initializes the messaging service when the first internet connection is established
  /// to avoid `firebase_messaging/unknown] Internet connection is not available` error.
  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;
  initFirstInternetConnection() {
    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> connectivityResult) {
      dog('connectivityResult: $connectivityResult');

      /// Is the internet connection available?
      if (connectivityResult.contains(ConnectivityResult.none) == false) {
        /// Then, run this code only one time on the first internet connection.
        connectivitySubscription?.cancel();
        dog('initConnectivity: Internet connection is available. Continue to init MessagingService.');
        initMessaging();
      }
    });
  }

  initMessaging() async {
    dog("initMessaging: begins");
    MessagingService.instance.init(
      onBackgroundMessage: null,
      onForegroundMessage: (RemoteMessage message) {},
      onMessageOpenedFromTerminated: onMessageOpened,
      onMessageOpenedFromBackground: onMessageOpened,
      onNotificationPermissionDenied: () {
        dog("onNotificationPermissionDenied()");
      },
      onNotificationPermissionNotDetermined: () {
        dog("onNotificationPermissionNotDetermined()");
      },
      // If Push notification does not work, check the sendURL in the functions
      sendUrl: "https://sendpushnotifications-2fgryf46pa-du.a.run.app",
    );

    /// Android Head-up Notification 설정
    if (isAndroid) {
      /// 채널 설정
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description: 'This channel is used for important notifications.', //
        importance: Importance.max, // max 로 해야 Head-up display 가 잘 된다.
        showBadge: true,
        enableVibration: true,
        playSound: true,
      );

      /// 채널 등록
      /// 만약, 채널이 이미 등록되어 있다면, 아래 코드로 업데이트 된다.
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  onMessageOpened(RemoteMessage remoteMessage) {
    dog("onMessageOpened: ${remoteMessage.data}");
    SchedulerBinding.instance.addPostFrameCallback((duration) async {
      final messageData = remoteMessage.data;
      dog("---- message ${messageData.toString()}");
      final message = MessagingService.instance.parseData(messageData);
      dog(message.toString());

      if (message is CommentMessaging) {
        dog("CommentMessaging: ${message.toString()}");
        final post =
            await Post.get(category: message.category, id: message.postId);
        if (post == null) return;
        if (!globalContext.mounted) return;
        await ForumService.instance.showPostViewScreen(
          context: globalContext,
          post: post,
        );
      } else if (message is PostMessaging) {
        // If it gives postId, it means it's a comment,
        // so show the post view screen using postId. The id
        // becomes the comment id.
        dog("PostMessaging: ${message.toString()}");
        final post = await Post.get(
          category: message.category,
          id: message.id,
        );
        if (post == null) return;
        if (!globalContext.mounted) return;
        await ForumService.instance.showPostViewScreen(
          context: globalContext,
          post: post,
        );
      } else if (message is ChatMessaging) {
        if (message.senderUid == myUid) return;
        if (!globalContext.mounted) return;
        return await ChatService.instance.showChatRoomScreen(
          context: globalContext,
          roomId: message.roomId,
        );
      } else if (message is UserMessaging) {
        if (!globalContext.mounted) return;
        return await UserService.instance.showPublicProfileScreen(
          context: globalContext,
          uid: message.senderUid,
        );
      } else if (message is UserProfileMessaging) {
        if (!globalContext.mounted) return;
        return await UserService.instance.showPublicProfileScreen(
          context: globalContext,
          uid: message.uid,
        );
      } else {
        dog("Unknown message type: $message");
      }
    });
  }
}


class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;
  String get lang => locale.languageCode;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const List<Locale> locales = [
    Locale('en', 'US'),
    Locale('ko', 'KR'),
  ];
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.locales.contains(locale);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsExtension on BuildContext {
  /// 이것을 사용한다! 영어 또는 한글을 리턴한다.
  String ke(String ko, String en) =>
      AppLocalizations.of(this).lang == 'ko' ? ko : en;
}


class HomeScreen extends StatefulWidget {
  static const String routeName = '/';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          {
            "en": "Home",
            "ko": "홈",
          }.tr,
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 80,
            child: UserListView(
              scrollDirection: Axis.horizontal,
              itemBuilder: (user, index) => Padding(
                padding: EdgeInsets.fromLTRB(index == 0 ? 16 : 4, 4, 4, 0),
                child: SizedBox(
                  width: 48,
                  child: Column(
                    children: [
                      UserAvatar(
                        uid: user.uid,
                        cacheId: 'user',
                      ),
                      UserDisplayName(
                        uid: user.uid,
                        initialData: user.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Login(
            yes: (uid) => Column(
              children: [
                Text('UID: $uid'),
                ElevatedButton(
                  onPressed: () => UserService.instance.signOut(),
                  child: const Text('로그아웃'),
                ),
              ],
            ),
            no: () => const SimpleEmailPasswordLoginForm(),
          ),
        ],
      ),
    );
  }
}
```

위 소스 코드가 잘 실행(컴파일)되면, 이 후 앱 개발에 필요한 코드를 추가해 나가면 된다. 참고로 위 코드에는 EasyState 상태 관리자를 사용하는데, 사실, 상태 관리자가 하는 역할은 아무것도 없다. 또한 원하는 상태 관리자를 적용해도 된다.





## FireFlutter 패키지를 개발자 모드로 설치하기

fireflutter 패키지를 pub.dev 에서 설치하는 것이 아니라, git clone 하여 소스 코드를 다운 받아 설치하면 보다 더 활용을 잘 할 수 있다.

개발자 모드로 설치하면, FireFlutter 패키지를 좀 더 쉽게 기능 수정(또는 추가)하고 또 PR 할 수 있다.

아래와 같이 개발자 모드로 설치할 수 있다.

- 먼저 [FireFlutter Github](https://github.com/thruthesky/fireflutter) repo 로 부터 Fireflutter 를 포크한다. 

- 그리고 클론한다.

- 그리고 자신만의 branch 를 만든다.

- 그리고 FireFlutter 루트 폴더에서 `apps` 폴더를 만들고, 그 안에 여러분의 앱을 추가하면 된다.

대충 아래와 같은 명령어가 필요할 것이다.

```dart
git fork ...
git clone ...
git checkout -b ...
mkdir apps
cd apps
flutter create your_project
```

- 그리고 추가한 앱의 pubspec.yaml 에서 아래와 같이 FireFlutter 를 dependency 로 추가하면 된다.


```yaml
dependencies:
  fireflutter:
    path: ../..
```

- 만약, FireFlutter 코드의 버그를 수정하거나 새로운 기능을 추가한다면 PR 를 통해서 알려주기를 바란다.


## Firebase Realtime Database Secuirty Rules


[Firebase Realtime Database Security Rules](../assets/realtime_database_security_rules.md) 를 복사해서 Realtime Database 의 Secrity Rulers 에 붙여 넣기 한 다음 저장한다. 물론 자신만의 보안 규칙이 있다면 적절히 수정을 해야 할 것이다.

참고로 Security Rules 는 Security 에 초점을 맞추도록 한다. Security 에서 data validation 이나 기타 security 와 직접적인 관련이 없는 작업은 하지 않는다.

## Firestore Security Rules

[Firebase Firestore Security Rules](../assets/firestore_security_rules.md) 를 Firestore Security Rules 에 복사해 넣으면 된다. 물론 자신만의 보안 규칙이 있다면 적절히 수정을 해야 할 것이다.

참고로 Security Rules 는 Security 에 초점을 맞추도록 한다. Security 에서 data validation 이나 기타 security 와 직접적인 관련이 없는 작업은 하지 않는다.

참고로, 아직, Firestore 에서 어떤 index 를 미리 만들어야 하는지 목록을 해 놓지 못하고 있다. 그래서 index 에러가 나면 콘솔에서 링크를 복사해서 index 를 생성해 주어야한다. 조만간 필요한 index 를 이곳에 나열을 할 예정이다.



## Storage Security Rules

[Firebase Storage Security Rules](../assets/storage_security_rules.md)를 Storage Rules 로 복사해 넣는다.



## 앱 설정 iOS

`FireFlutter` 패키지를 사용하기 위해서 기본적으로 다음과 같은 설정을 해야 합니다. 아래 설정은 사진 업로드에 사용되는 entitlement 입니다.


```xml
<key>NSCameraUsageDescription</key>
<string>This app requires access to the camera to share the photo on profile, chat, forum.</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app requires access to the microphone to share vioce with other users.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app requires access to the photo library to share the photo on profile, chat, forum.</string>
```

## FireFlutter 기본 설치

다음은 FireFlutter 를 적용하는 간단한 예제이다.

- 우선, Firebase 를 플러터 프로젝트에 연결하고,
- FireFlutter 의 `UserService` 를 초기화한다.
- 그리고, 로그인을 UI 를 제공하는 위젯인 `SimpleEmailPasswordLoginForm` 을 화면에 보여준다.

아래의 코드는 어떻게 FireFlutter 를 사용 할 수 있는지에 대한 설명을 하는 것으로, 매우 간단한 코드를 가지고 있으며, 앱 개발 작업을 진행하면서, 필요에 따라 여러가지 코드가 추가되어야 할 것이다.

```dart
import 'package:example/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    UserService.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Login(
            yes: (uid) => Column(
              children: [
                Text('UID: $uid'),
                ElevatedButton(
                  onPressed: () => UserService.instance.signOut(),
                  child: const Text('로그아웃'),
                ),
              ],
            ),
            no: () => const SimpleEmailPasswordLoginForm(),
          ),
        ],
      ),
    );
  }
}
```

추가적으로 [에러 핸들링](./error_handling.md) 문서와 [빠르게 시작하기](./quick_start.md) 문서를 참고 해 보기 바란다.




## 클라우드 함수 설치

2024년 6월 11일, 클라우드함수가 FireFlutter 에서 [Fire-Engine](https://github.com/thruthesky/fire-engine)으로 분리되어 개발 관리된다. 또는 Realtime Database 의 데이터를 Firestore 로 미러링하는 함수들을 별도로 분리하였는데, [mirror-database-to-firestore](https://github.com/thruthesky/mirror-database-to-firestore) 를 통해서 mirroring 할 수 있다.

### 클라우드 함수 설정

클라우드 함수를 설치하기 전에 설정을 해 주어야 한다. 예를 들면, 클라우드 함수는 Hosting 이나 Firestore 근처의 region 이면 좋겠지만, Realtime Database 의 Event Trigger 로 동작하는 함수는 Realtime Database 의 region 에 존재해야 한다. 즉, 함수가 여러 region 에 존재하는 것이 좋을 수 있는 것이다.

`Fire-Engine` 의 `src/config.ts` 에 다음과 같이 설정을 한다.

- `region` 함수의 region 이다.
- `rtdbRegion` 은 Realtime Database 의 region 이다.


#### 푸시 알림 로그 기록

`logPushNotificationLogs` 가 true 이면, 모든 푸시 알림을 `push-notification-logs` 에 기록하는데, DB 용량을 많이 차지 할 수 있으므로 유의한다.
개발 또는 테스트를 하는 경우에는 true 로 할 수 있지만, 실제 운영을 할 때에는 false 로 할 것을 추천한다.


### 전체 클라우드 함수 설치하기

아래와 같이 명령하면 된다.

```sh
cd firebase
firebase use --add
cd functions
npm run deploy
```

#### 푸시 알림 함수

푸시 알림 함수에는 여러 가지 함수가 있다.


- `sendPushNotifications` 함수는 클라이언트에서 여러 개의 푸시 알림 토큰을 서버로 전달해서, 서버에서 푸시 알림을 보낼 수 있게 해 준다.
  - 설치는 그냥 일반적인 클라우드 함수 설치 방식인 `firebase deploy --only functions:sendPushNotifications` 와 같이 하면 된다. 이 후, 다른 클라우드 함수들의 설치도 이와 같아서 생략한다.
  - 참고로 이 함수는 http trigger 함수이다. Restful API 방식으로 호출한다고 생각하면 된다.

- `mirrorBackfillRtdbToFirestore` 함수는 `userMirror`, `postMirror`, `commentMirror` 를 사용 할 때, 기존의 mirror 되지 않은 데이터를 모두 mirror 하는 것이다. 이 함수는 callable function 이며 관리자만 실행하는 한 함수이다.


- `userLike` 함수는 좋아요 관련 추가 작업을 해 준다. 예를 들어 A 가 B 를 좋아요 하면 A 가 B 를 좋아요 했다는 표시 뿐만아니라 좋아요 갯 수 증/감, 푸시 알림 등 추가적인 작업을 하고자 할 때 이 함수를 쓰면 된다.

- `userDeleteAccount` 는 회원 계정을 Firebase Auth 에서 삭제한다. 클라이언트 SDK 에서 Firebase Auth 를 삭제하려면 recent auth 에러를 내고 다시 로그인하라고 하는데, 이 함수를 사용하면 곧 바로 Firebase Auth 계정을 삭제 할 수 있다.
  - 이 클라우드 함수는 callable function 이다.


- `managePostsSummary` 함수는 글을 RTDB 의 `post-summaries` 와  `post-all-summaries` 에 간추려 저장한다. 기본적으로 `posts` 에 저장되는 글은 여러가지 정보를 추가로 저장하는데, 코멘트까지 같이 저장하므로 글의 용량이 클 수 있다. 그래서 각종 글 관련 목록을 할 때 다운로드해야 하는 양이 많아 비용이 증가 할 수 있는데, 이를 방지하고자 제목, 글쓴이 정도의 간단한 정보만 따로 저장하는 것이다.

- `sendMessagesToCategorySubscribers` 함수는 게시판 (카테고리) 구독자에게 푸시 알림을 전송하고자 할 때 사용하는 함수이다.


- `sendMessagesToChatRoomSubscribers` 함수는 채팅 방에 있는 사용자들 중 푸시 알림 구독자들에게만 푸시 알림을 보내고자 할 때 사용하는 함수이다.

- `link` 함수는 dynamic link 함수이다. 앱을 공유하고자 할 때 사용하는 함수이다.



### Mirroring 함수 설치하기

- 2024년 6월 이전에는 userMirror, postMirror, commentMirror 와 같은 함수가 있었는데, 이제는 `mirror-database-to-firestore` 함수로 분리되었다.
- 사용자 정보, 게시글, 코멘트 글 등을 Firestore 로 mirroring 하는 이유는 Firestore 를 통해서 데이터를 더 잘 활용할 수 있기 때문이다. 필요에 따라 Firebase Extension 을 활용할 수도 있다.
  - Fireflutter 에서 기본적으로 제공하는 사용자 검색 기능은 이 mirroring 이 필요하다.


- 아래와 같이 설정하고 region 값만 RTDB 의 region 으로 바꾸어준 다음 설치를 하면 된다.

```ts
export class Config {
  /**
   * Region to deploy the function.
   */
  public static region = "us-central1"; // 여기에 RTDB 의 region 을 입력하면 된다.
  /**
     * Paths to mirror.
     */
  public static paths: Array<ConfigPath> = [
    {
      source: "users/{uid}",
      destination: "users",
    },
    {
      source: "posts/{category}/{postId}",
      destination: "posts",
      // fields: ["name", "timestamp"],
    },
    {
      source: "comments/{postId}/{commentId}",
      destination: "comments",
    },
  ];
}
```

위와 같이 하면, users, posts, comments 노드의 값들이 각각 firestore 의 users, posts, comments 컬렉션에 저장된다.




## Dynamic Link 설치

Dynamic link 란 앱을 공유(다른 사람에게 알려주기 위해)하고자 할 때 특정 링크를 생성해 다른 사용자에게 전달 해 주고, 그 사용자가 링크를 클릭하면 앱애 설치되어져 있으면 앱을 열고, 설치되어져 있지 않으면 Appstore 또는 Playstore 또는 홈페이지를 여는 것이다.

Firebase 에서 제공하던 기존 Dynamic link 도 좀 복잡한 편이었으며 다른 dynamic link 서비스를 쓴다고 해도 딱 그 만큼 복잡하다. 자세한 설명을 위해서는 [다이나믹 링크](./dynamic_link.md) 문서를 참고한다.




## Initializing TextService

Fireflutter has some UI and you may want to show it in different languages.

And you can use the text translation funtionality in your app.

```dart

/// Call this somewhere while the app boots.
initTextService();

void initTextService() {
  print('--> AppService.initTextService()');

  TextService.instance.texts = {
    ...TextService.instance.texts,
    if ( languageCode == 'ko' ) ...{
      T.ok: '확인',
      T.no: '아니오',
      T.yes: '예',
      T.error: '에러',
      T.dismiss: '닫기',
      Code.profileUpdate: '프로필 수정',
      Code.recentLoginRequiredForResign:
          '회원 탈퇴는 본인 인증을 위해서, 로그아웃 후 다시 로그인 한 다음 탈퇴하셔야합니다.',
      Categories.qna: '질문',
      Categories.discussion: '토론',
      Categories.buyandsell: '장터',
      Categories.info: '정보/알림',
      T.notVerifiedMessage: '본인 인증을 하셔야 전체 기능을 이용 할 수 있습니다.',
      T.chatRoomNoMessageYet: '앗, 아직 메시지가 없습니다.\n채팅을 시작 해 보세요.',
    },
    if ( languageCode == 'en' ) ...{
      T.ok: 'Ok',
      // ...
    }
  };
}
```

## Admin

- See [Admin Doc](admin.md)

## Unit tests

- There are many unit test codes. You can read other document of Fireflutter on how to install and test the unit test codes.
