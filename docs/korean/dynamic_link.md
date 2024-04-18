# 다이나믹 링크

Dynamic link 란 앱을 공유(다른 사람에게 알려주기 위해)하고자 할 때 특정 링크를 생성해 다른 사용자에게 전달 해 주고, 그 사용자가 링크를 클릭하면 앱애 설치되어져 있으면 앱을 열고, 설치되어져 있지 않으면 Appstore 또는 Playstore 또는 홈페이지를 여는 것이다.

만약, dynamic link 를 사용하지 않는다면 굳이 본 항목을 살펴 볼 필요는 없다.

첫째, `link` 클라우드 함수를 설치한다.
이 함수를 설치하면 홈페이지 도메인 최상단 경로에 `/.well-known/assetlinks.json` 과 `/.well-known/apple-app-site-association` 을 설치 해 준다. 물론 이 때, SHA 와 Bundle ID 등의 정보를 잘 입력해야 한다.

둘째, 앱에서 App Link, Universal Link 설정을 해 주어야하며, Deeplink 설정도 해 주어야 한다. Deeplink 설정을 해 주는 이유는 카카오톡에서 링크를 클릭하면 인앱브라우저가 앱을 구동시키지 못하는 경우가 발생하는데, Deeplink 를 통해서 앱을 열기 위해서 필요하다.

셋째, 링크를 만들어 공유하는 코드를 작성한다.

Dynamic link 에 대한 자세한 설명은 dynamic link 항목을 참고한다. 설치가 약간 복잡한 만큼 관련 내용을 따로 설명하고 있다.




## 설치

먼저, `link` 클라우드 함수를 설치한다.

그리고 Firestore 의 `_link_` 문서에 android, ios, html 설정을 한다.

### Android 설정


아래의 그림과 같이 SHA256 를 저장하면 된다.

![Android Firestore Setting](https://github.com/thruthesky/fireflutter/blob/main/docs/assets/images/dynamic_link_android.jpg?raw=true)



## 활용

