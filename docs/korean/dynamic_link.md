# 다이나믹 링크

Dynamic link 란 앱을 공유(다른 사람에게 알려주기 위해)하고자 할 때 앱 내에서 링크를 생성해 다른 사용자에게 전달 해 주고, 그 사용자가 링크를 클릭하면 앱이  설치되어져 있으면 앱을 열고, 설치되어져 있지 않으면 Appstore 또는 Playstore 또는 홈페이지를 여는 것이다.

Dynamic link 를 사용하기 위해서는 FireFlutter 에서 사용하는 dynamic link 의 기본 개념의 이해가 좀 필요하다. 만약, dynamic link 를 사용하지 않는다면 굳이 본 항목을 살펴 볼 필요는 없다.

첫째, dynamic link 를 담당하는 `link` 클라우드 함수를 설치한다.

설치를 할 때, firebase hosting 설정에서 `appAssociation` 을 NONE 으로 하고, 사이트 최상단 경로에 `/.well-known/assetlinks.json` 과 `/.well-known/apple-app-site-association` (AASA) 로 접속하면 클라우드 함수 `link` 로 접속하도록 URL rewrite 를 설정한다.

둘째, 링크가 공유되면 핸드폰 OS 가 App Link 와 Universial Link 관련 작업을 통해서 assetlinks 와 AASA 를 가져오는데, 올바른 정보를 넣어 주어야 한다. 이 값은 `_link_` 컬렉션의 `android` 와 `ios` 문서에 각각 넣어 주면 된다.

셋째, 개발하는 앱(플러터 앱)에서 App Link 와 Universial Link 가 동작하도록 설정을 해 주어야 한다. 또한 Deeplink 설정도 추가를 해 주어야 한다. Deeplink 설정을 해 주는 이유는 몇 몇 앱(예 카카오톡)에서 링크를 클릭하면 곧 바로 앱을 실행하지 못하고 인앱브라우저를 열어서 홈페이지로 접속을 하는 경우가 있다. 이 때, 홈페이지에서 Deeplink 를 통해서 앱을 열기 위해서 Deeplink 설정이 필요하다.

넷째, 링크를 만들어 공유하는 코드를 작성한다.
링크를 만들때 site preview 옵션 부터 다양한 옵션을 넣어서 만들 수 있다.





## 설치

먼저, `link` 클라우드 함수를 설치한다.

그리고 Firestore 의 `_link_` 문서에 android, ios, html 설정을 한다.

### Android 설정

AndroidManifest.xml 에 아래의 내용을 추가한다.

```xml
<activity
    android:name=".MainActivity"
    android:exported="true" >
    <!-- Add this in activity -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <!-- Accepts URIs that begin with https://YOUR_HOST.COM -->
        <data
            android:scheme="https"
            android:host="YOUR_HOST.COM" />
    </intent-filter>
</activity>
```

아래의 그림과 같이 SHA256 를 저장하면 된다.

![Android Firestore Setting](https://github.com/thruthesky/fireflutter/blob/main/docs/assets/images/dynamic_link_android.jpg?raw=true)


## Firebase 에 홈페이지를 운영하는 경우

Firebase Hosting 에 대한 충분한 이해가 필요하다.

먼저, FireFlutter 의 dynamic link 는 기본 사이트에 운영하는 것을 가정으로 하는데, 홈페이지도 기본 사이트에 운영하고자 한다면 `FireFlutter` 의 `firebase.json` 으로 hosting deploy 하면, 홈페이지로 개발한 데이터가 삭제된다. 여러가지 방법이 있겠지만 가능하면 홈페이지 개발은 별도의 폴더에서 하고, `firebase init hosting` 을 통해서 아래와 같은 설정을 하여, dynamic link 에서 사용하는 함수를 그대로 쓸 수 있도록 한다.

아래에서 `.well-known/**` 를 `link` 함수로 연결하여 assetlinks.json 과 AASA 를 적절하게 보여준다. 그리고 공유할 때 링크 생성은 `https://[기]본사이트-도메인]/link/[xxxx]` 와 같이 하면 되는 것이다. 그러면 링크가 탭 될 때, 웹브라우저가 열리는 경우, `link` 함수가 실행되어 적절한 처리를 하면 되는 것이다.

`firebase.json` 예제 - 아래와 같이 `appAssociation: NONE` 과 `rewrites` 를 개발하는 홈페이지 프로젝트의 `firebase.json` 에 넣어 주고 배포하면 dynamic link 를 그대로 쓸 수 있다.

```dart
{
  "hosting": {
    "source": ".",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "frameworksBackend": {
      "region": "asia-east1"
    },
    "appAssociation": "NONE",
    "rewrites": [
      {
        "source": "link/**",
        "function": "link"
      },
      {
        "source": ".well-known/**",
        "function": "link"
      }
    ]
  }
}
```


## 링크 생성해서 공유하기

먼저 Firestore 의 `_link_` 컬렉션의 `apps` 문서에 `default` 키의 값은 아래와 같은 맵데이터를 저장한다.
```json
{
  "appStoreUrl": "The user will be redirected to this Appstore URL to download the app",
  "playStoreUrl": "구글 안드로이드를 사용하면, 앱 다운로드할 URL",
  "appleAppId": "숫자로된 애플 앱 아이디",
  "webUrl": "...",
  "appName": "...",
  "title": "...",
  "description": "....",
  "redirectingMessage": "사용자에게 보여 줄 메시지",
  "redirectingErrorMessage": "에러가 발생하여 redirecting 할 수 없는 경우 사용자에게 보여 줄 메세지",
  "appIconLink": "favicon",
  "previewImageLink": "site preview image url",
}
```

위의 값에서 `title`, `descriptoin` 은 입력되는 값에 따라 적절히 대체된다.
`default` 에 저장하는 이유는 링크가 `?app=abc&pid=xxx` 와 같이 하나의 Firebase 에 여러앱이 있는 경우, `app` 이 들어오는 데, 만약 이 값이 없다면 기본 `default` 를 쓰기 위해서이다.


만약, 앱이 Android 에만 배포된 경우, 또는 iOS 에는 배포를 하지 않는 경우, appStoreUrl 은 webUrl 과 동일하게 할 수 있다. 그러면 iOS 사용자들은 자연스럽게 webUrl 로 이동한다. Anroid 에 배포하지 않고 iOS 에만 배포하는 경우도 마찬가지 이다.




`LinkService.instance.init()` 에 링크 생성을 위한 설정을 해 주어야 한다.

- `linkUrlPrefix` - `https://abc.com/link`

`LinkService.instance.generatePostLink()` 는 `linkUrlPrefix` 에 `?pid=xxxx` 를 붙여서 링크를 생성한다. 예를 들면, `https://abc.com/link?pid=xxx` 와 같이 링크가 만들어지는 것이다.






## 링크 탭으로 앱이 열린 경우


pub.dev 의 [app_links](https://pub.dev/packages/app_links) 패키지를 이용해서 링크 클릭으로 앱이 열릴 때, 조치를 하면 된다.




