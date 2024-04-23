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
_link_/apps
  {
    "default" {
      "appStoreUrl": "The user will be redirected to this Appstore URL to download the app",
      "playStoreUrl": "구글 안드로이드를 사용하면, 앱 다운로드할 URL",
      "appleAppId": "숫자로된 애플 앱 아이디. App store connect 에서 알 수 있다. Smart app banner 에서 사용 됨.",
      "webUrl": "...",
      "appName": "...",
      "title": "...",
      "description": "....",
      "redirectingMessage": "사용자에게 보여 줄 메시지",
      "redirectingErrorMessage": "에러가 발생하여 redirecting 할 수 없는 경우 사용자에게 보여 줄 메세지",
      "appIconLink": "favicon",
      "imageUrl": "site preview image url",
    }
  }
```

위의 값에서 `title`, `descriptoin` 은 입력되는 값에 따라 적절히 대체된다.
`default` 에 저장하는 이유는 링크가 `?app=abc&pid=xxx` 와 같이 하나의 Firebase 에 여러앱이 있는 경우, `app` 이 들어오는 데, 만약 이 값이 없다면 기본 `default` 를 쓰기 위해서이다.

`title`, `description`, `imageUrl` 값은 uid, pid, cid 의 DB 정보에 의해서 적절하게 대체된다. 예를 들면, uid 의 state message 가 description 으로 들어가는 해당 uid 의 state message 가 없다면, app 문서에 있는 description 이 사용된다.


`webUrl` 은 공유된 링크가 컴퓨터에서 클릭되어, 웹 브라우저에서 열리고, 이 `webUrl` 로 redirect 된다. 따라서 `webUrl` 은 공유된 링크가 클릭되어 열리는 주소 임을 인지하고 특별하게 `https://my-domain.com/weblink` 와 같이 링크가 클릭되어 들어오는 주소로 준비를 하고, 링크로 들어오는 파라메타 값에 따라 다른 페이지로 이동 할 수 있는 코드를 짜 놓아야 한다.

만약, 앱이 Android 에만 배포된 경우, 또는 iOS 에는 배포를 하지 않는 경우, appStoreUrl 은 webUrl 과 동일하게 할 수 있다. 그러면 iOS 사용자들은 자연스럽게 webUrl 로 이동한다. 이 때, query parameter 는 전달되지 않으므로 주의한다. Anroid 에 배포하지 않고 iOS 에만 배포하는 경우도 마찬가지로 할 수 있다.




`LinkService.instance.init()` 에 링크 생성을 위한 설정을 해 주어야 한다.

- `linkUrlPrefix` - `https://abc.com/link`

`LinkService.instance.generatePostLink()` 는 `linkUrlPrefix` 에 `?pid=xxxx` 를 붙여서 링크를 생성한다. 예를 들면, `https://abc.com/link?pid=xxx` 와 같이 링크가 만들어지는 것이다.




## 링크가 공유된 경우, SEO & Site Preview

링크가 공유되는 경우, 여러 앱에서 site preview 를 보여주려고 한다.

- 각 공유 링크에는 `uid`, `pid`, `cid` 등의 값이 있을 수 있다.
  - `uid` 는 회원 프로필 정보를 공유하는 할 때 사용하는 것으로 사용자 uid 값이 들어간다.
  - `pid` 는 게시글 또는 코멘트를 공유할 때 사용하는 것으로 글을 id 값이 들어간다.
  - `cid` 는 (그룹) 채팅방을 공유할 때 사용하는 것으로 채팅방 id 값이 들어간다.

- `uid`, `pid`, `cid` 값이 들어가지 않을 수 있다. 예를 들어 `https://my-domain.com/link?page=abc` 와 같이 공유를 할 수도 있다.

- 각 앱(또는 각 웹)에서 site preview 를 할 때, 대부분의 경우 해당 URL 을 읽어서 meta 태그를 파싱해서 title, description, image 등을 화면에 보여준다.
 - 즉, 링크가 화면에 보여지면, 앱(웹)에서 그 링크의 HTML 정보를 읽는데, 이 때, `link.function.ts` 의 `get(*)` 이 실행되고 각 `uid`, `pid`, `cid` 에 맞는 값을 DB 에 읽어서 `defaultHtml` 의 title, description, image 등을 패치 한 다음, 클라이언트(웹 또는 앱)으로 전달해 주는 것이다. 그리고 각 앱(웹)이 그 HTML 파싱해서 화면에 보여준다.

## 링크가 공유 된 경우, 상황 별 설명

- 사용자 프로필을 공유하는 경우, 아래와 같이 공유 링크를 만들 수 있다.

```sh
% curl "http://127.0.0.1:5001/silbus/us-central1/link?uid=FjCrteoXHgdYi6MjRp09d51F71H3&a=apple&b=banana"
```
위와 같이 하면, uid 사용자의 이름과 상태 메시지, 프로필 사진이 site preview 로 나타난다.


- 글 또는 코멘트를 공유 할 때 아래와 같이 링크를 만들 수 있다.

```sh
% curl "http://127.0.0.1:5001/silbus/us-central1/link?pid=-NvlptAoVSIoz40mNpGn&a=apple&b=banana"
```

코멘트를 보여주는 화면이 따로 있는 것이 아니다. 그래서 코멘트를 공유할 때 그냥 그 코멘트의 글 id 를 pid 에 넣어주면 된다. 그러면 앱(웹)에서는 그냥 그 글을 화면에 보여주면 된다.



- 채팅방을 공유하는 경우 아래와 같이 링크를 만들 수 있다.

```sh
% curl "http://127.0.0.1:5001/silbus/us-central1/link?cid=17MCAQOIRJPYuIYqR6qD&a=apple&b=banana"
```

와 같이 공유 링크를 만들 수 있다. Site preview 를 할 때, title, description, imageUrl 등은 `/chat-rooms/{cid}` 에서 가져와 적절하게 defaultHtml 에 패치해서 클라이언트로 전달한다.



- 아래의 예제는 `uid`, `pid`, `cid` 를 쓰지 않고 query parameter 를 마음대로 준 경우이다. 이와 같은 경우 앱(또는 웹)으로 query parameter 가 그대로 전달된다.

```sh
% curl "http://127.0.0.1:5001/silbus/us-central1/link?page=about&a=apple&b=banana"
```

예를 들어 OS 가 앱을 바로 열거나 Smart App Banner 에 의해서 열리면, `page=about&a=apple&b=banana` 가 전달된다. 공유된 링크가 클릭되어 webUrl 이 열리면, webUrl 의 맨 끝에 `?page=about&a=appple&b=banana` 가 붙어서 webUrl 로 redirect 된다. 즉, 앱이나 웹 등에서 각 로직에 맞게 적절이 코딩을 하면 되는 것이다.




## 링크 탭되어 앱 또는 웹이 열린 경우 처리 방법

- 앱이 열리는 경우, pub.dev 의 [app_links](https://pub.dev/packages/app_links) 패키지를 이용해서 입력 값을 받아서 적절한 조치를 하면 된다.
  - 앱이 OS 에 의해서 바로 열리지 않고, 웹 사이트 내에서 smart app banner 에 의해서 열리는 경우도 동일한 입력 값이 전달되므로 앱 내에서 처리하는 로직은 동일하다.


- OS 가 앱을 열지 않고, 웹 브라우저를 열어서 공유 링크 페이지를 여는 경우
  - iOS 에서는 appStoreUrl 을 열고
  - Android 에서는 playStoreUrl 을 열고
  - Desktop 에서는 webUrl 을 연다.
  
  이 때, webUrl 을 열 때, 맨 끝에 query parameter 를 추가해 준다. 예를 들어 공유 링크가 `https://domain.com/link?a=b` 와 같고, webUrl 이 `https://domain.com/weblink` 와 같다면, desktop 에서는 `https://domain.com/weblink?a=b` 가 열린다. 그래서 웹 사이트에서 적절한 조치를 취하면 된다.

  OS 에서 앱을 바로 열지 못하고 웹 브라우저가 열릴 때, iOS 에서 Smart App Banner 를 보여주는 경우가 있다. 이 때, 앱을 실행하면 query parameter 가 앱으로 전달된다. 즉, OS 가 앱을 바로 열 때, query parameter 가 앱으로 전달되는게 그것과 동일한 값이 Smart App Banner 로 열어도 전달되도록 HTML 에 패치를 해 놓았다.



## 개발하는 방법

클라우드 함수 작업은 항상 로컬 컴퓨터에서 에뮬레이터를 실행해서, 로컬에서 테스트를 하면 된다. 소스 수정한 다음, deploy 해서 확인하는 경우가 없도록 한다.

먼저, 아래와 같이 function emulator 를 실행한다.

```sh
 % export GOOGLE_APPLICATION_CREDENTIALS=~/.../silbus-firebase-service-account.json
 % firebase use silbus
 % firebase emulators:start --only functions
```

그리고 TypeScript 로 코딩하므로, 아래와 같이 실시간 빌드를 해 준다.

```sh
% npm run build:watch
```

그리고 아래와 같이 테스트를 한다.

```sh
% curl "http://127.0.0.1:5001/silbus/us-central1/link?pid=-Nvgu90BBbLTz-vP-EJy"
```


## 배포하는 방법

아래와 같이 하면 eslint --fix 를 하고 배포한다.

```sh
% npm run deploy:link
```
