# 오류 발생 시 문제 해결


## firebase_functions/not-found NOT FOUND


- `[firebase_functions/not-found] NOT FOUND` 에러 메시지는 주로 회원 탈퇴 할 때나 기타 Firebase Cloud Functions 의 callable function 을 호출 할 때, region 설정이 잘못되었을 경우 발생한다.
  - 참고: [Initialize the client SDK](https://firebase.google.com/docs/functions/callable?_gl=1*4mqqk3*_up*MQ..*_ga*MTEwMzIxMzE3My4xNzExNDI5NDY4*_ga_CW55HF8NVT*MTcxMTQyOTQ2OC4xLjAuMTcxMTQyOTQ2OC4wLjAuMA..&gen=2nd#initialize_the_client_sdk)
  - 해결하기 위해서는 `UserService.instance.init( callableFunctionRegion: ... )` 에 해당 함수의 region 을 적어주면 된다.