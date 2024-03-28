# 클럽 (동호회 또는 밋업)

- 클럽이란 동호회 또는 밋업과 같은 의미로 앱 내에서 오프라인 모임을 지원하기 위해, 클럽 가입, 클럽 오프라인 모임 설정 및 각종 채팅이나 게시판 등의 기능을 제공하는 것이다.

- 기본적으로 제공하는 클럽은 다양한 UI 변경 기능이 포함되지만, 필요하다면 소스 코드를 복사해서 원하는데로 수정하여 사용하면 된다.

- 특징적으로 클럽의 정보는 Firestore 에 저장된다. 이는 클럽의 소개나 일정을 좀 더 세밀하게 검색(필터링)하기 위한 것이다. 참고로 클럽 기능을 사용하지 않는 다면, 클럽 관련 Firestore 설정은 하지 않아도 된다.


## Firestore 설정

### Firestore security rules


## 데이터베이스 구조

- `/clubs/<club-id>` 와 같이 클럽의 설정 정보가 저장된다.


## 클럽 코딩 가이드라인


- 클럽 화면을 열고자 한다면 `ClubService.instnace.showClubScreen()` 을 호출하면 된다.
- 클럽을 생성하는 화면을 열고자 한다면, `ClubService.instance.showCreateScreen()` 을 호출하면 된다.
- 클럽 소개 정보를 수정하는 화면을 열고자 한다면, `ClubService.instance.showUpdateScreen()` 을 호출하면 된다.




