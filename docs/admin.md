# 관리자


## 관리자 지정

- `/admins/{ uid: master }` 와 같이 지정하면 된다. 만약, 본인의 UID 가 ABCDEF 라면, `admins` 노드에 필드 이름을 `ABCDEF` 로 해서 값을 `master` 로 저장하면, 관리자가 된다.





## 전체 사용자 목록 및 수정

전체 사용자 목록은 그냥 `FirebaseDatabaseListView` 로 목록을 하면 된다. 참고로 `AdminService.instance.showUserList(context: context)` 를 통해서 사용자 목록을 할 수 있다.


