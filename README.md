# Fireship

A lightning-fast, robust CMS for seamless real-time content management in app development.



## 디자인 컨셉

- Realtime Database 위주로 사용을 하는데, 가장 큰 이유는 속도 때문이다. 물론 부가적으로 비용을 절감을 할 수 있다. 그러나, Firestore 보다는 검색 필터링 옵션이 부족하므로, 필요에 따라서 Firestore 에 데이터를 나누어 저장 할 필요가 있다.



## Messaging

As the deprecation of [Send messages to multiple devices](https://firebase.google.com/docs/cloud-messaging/send-message#send-messages-to-multiple-devices) is stated in the [official Firebase Documentation](Send messages to multiple devices), we will send push notifications in Flutter code.



