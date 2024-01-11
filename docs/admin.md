# Admin


## How to set a user as admin

1. Add the user uid under `/admins`.

For instance, if the user uid is `abc`, then set it like below

`/admins/{ abc: master }`


2. Set the `isAdmin` to true in the `/users/<uid>`.




## 전체 사용자 목록 및 수정

전체 사용자 목록은 그냥 `FirebaseDatabaseListView` 로 목록을 하면 된다. 참고로 `AdminService.instance.showUserList(context: context)` 를 통해서 사용자 목록을 할 수 있다.


