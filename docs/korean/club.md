# 클럽 (동호회 또는 밋업)

- 클럽이란 동호회 또는 밋업과 같은 의미로 앱 내에서 오프라인 모임을 지원하기 위해, 클럽 가입, 클럽 오프라인 모임 설정 및 각종 채팅이나 게시판 등의 기능을 제공하는 것이다.
- 클럽은 FireFlutter 의 채팅이나 게시판 기능을 조합하여 만드는 기능으로 원한다면 얼마든지 FireFlutter 의 기능을 활용해서 다른 서비스를 만들 수 있다.
- 기본적으로 제공하는 클럽은 다양한 UI 변경 기능이 포함되지만, 커스터마이징을 위해서 소스 코드를 복사해서 수정하여 사용하면 된다.

- 특징적으로 클럽의 정보는 Firestore 에 저장된다. 이는 클럽의 소개나 일정을 좀 더 세밀하게 검색(필터링)하기 위한 것이다. 참고로 클럽 기능을 사용하지 않는 다면, 클럽 관련 Firestore 설정은 하지 않아도 된다.


## Firestore 설정

### Firestore security rules




## 데이터베이스 구조

- `/clubs/<club-id>` 와 같이 클럽의 설정 정보가 저장된다.
- `hasPhoto` 는 클럽 설정 정보에 사진이 있으면, 즉 운영자가 클럽 사진을 등록했으면, true 가 된다. 따라서 이 필드를 통해서 클럽 사진이 있는 클럽 정보만 가져 올 수 있다.
- 클럽 멤버는 `users` 에 저장한다.
  - `/clubs/<club-id>` 문서에 `{users: [ uid_a, uid_b, ...] }` 와 같이 방 참여자 목록을 기록한다.
  - 이 때, 문제는 참여한 멤버가 많아 질 수록 `users` 데이터 값이 커져, 문서의 크기가 커진다는 것이다. 하지만, 이 것은 모든 클럽에서 나타나는 현상이 아니라, 회원수가 많은 극히 일부 클럽 문서 데이터 로드에 부담이 된다. 그렇다고 이를 해결하기 위해서 데이터 정규화를 해도 동일한 문서 읽기 회수나 데이터 로드에 부담이 되기는 마찬가지이다. 그래서 그냥 이 방식으로 한다. UID 는 28 바이트이다. 클럽 멤버 수가 100명 2.8k 이면 약간 부담, 1천명 이상이면 28k 이어서 약간 더 부담되낟. 하지만, 2천명 까지는 무난 할 것으로 판단한다.
  2천 명이상이면 목록에서 제외하던지 아니면, 전체 목록을 할 때, 회원수가 적은순으로 목록하던지, 최근 생성순으로 목록하던지하면 된다.
- `master` 는 클럽 주인장이다.
- `moderators` 는 클럽을 관리 할 수 있는 부 운영자 목록이다.
- 모임 일정은 Firestore 로 따로 작업을 한다. 참여 희망자 확인 및 참여 철회 등을 표현 할 때 필요하다.
- 참고로 클럽 문서(`/clubs/<club-id>` 컬렉션 문서)는 너무 자주 업데이트가 되면 안된다. 예를 들어 클럽 조회수와 같은 카운트를 기록하면 `ClubDoc` 을 사용하는 경우, 화면에 너무 자주 깜빡일 수 있기 때문에 가능한 최소한의 업데이트 하도록 구조를 만들어야 한다.
- `reminder` 는 공지사항이다.


## 클럽 코딩 가이드라인

- 클럽 화면을 열고자 한다면 `ClubService.instnace.showClubScreen()` 을 호출하면 된다.
- 클럽을 생성하는 화면을 열고자 한다면, `ClubService.instance.showCreateScreen()` 을 호출하면 된다.
- 클럽 소개 정보를 수정하는 화면을 열고자 한다면, `ClubService.instance.showUpdateScreen()` 을 호출하면 된다.



## 클럽과 게시판

클럽을 생성 할 때, 따로 게시판에 대한 DB 변경을 하지 않는다. 다만, 클럽에는 게시판과 사진첩이 있는데 이 두 개가 있는데, 게시판으로 동작한다. 각 메뉴에 게시판 아이디와 사진첩 아이디를 `club.id` 와 `club.id-gallery` 로 연결하여 사용하는 것이다.




## 클럽과 채팅

클럽을 생성 할 때, 그룹 채팅방을 생성하고, 최초 클럽 생성자를 채팅방에 입장을 시킨다. 물론 클럽을 생성한 사용자가 채팅방의 관리자가 된다.

사용자가 클럽에 가입을 하면, 채팅방에 입장을 시키고 클럽 탈퇴를 하면 채팅방에서도 퇴장을 하게 된다. 참고로, 채팅방에 미리 입장을 시켜놓아야 알림 등을 받게 된다.





## 클럽과 모임 일정

- 클럽 소개와 마찬가지로 클럽의 모임 일정은 Firestore 에 저장이 된다.
- 서브 컬렉션으로 검색을 해서, 전체 모임 일정을 검색 할 수 있는데, 홈 화면이나 기타 검색 등의 화면에서 가장 가까운 모임이 어떤 것들이 있는지 회원들에게 보여주는 기능이, 앱의 아주 좋은 기능 중 하나가 될 수 있다. 최근 모임 중 어떤 모임들이 있는지 확인하고자 할 때 유용하게 쓸 수 있다.

- `/clubs/<club-id>/club-meetups/<meetup-id>` 와 같이 저장된다.
- `users` 필드에 참가 신청한 사용자 uid 가 저장된다.
- `createdAt` 에 모임 생성 날짜
- `meetAt` 에 오프라인 모임 날짜.
- `photoUrl` 에 모임 사진. 없으면 클럽 소개 photoUrl 이 사용됨.
- `title` 모임 소개 제목
- `descriptoin` 모임 소개 설명
- `address` 주소 - 모임 주소. 이 주소는 직접 타이핑해서 입력하도록 한다. 참고로 네비게이터 연결 버튼을 달아 놓도록 한다.








## 클럽 목록

- `ClubListView` 로 하면 된다. `ClubListView` 는 `ListView.separated` 의 모든 파라메타를 지원한다. 그래서 가로 스크롤이나 separator 등을 표현 할 수 있다.

- 기본적으로 Firestore 의 `clubs` 컬렉션에서 최근 생성된 순서로 클럽 정보를 가져오는데, `query` 옵션을 통해서 원하는 데로 쿼리를 할 수 있다.

- 아래의 예제는 클럽 목록을 가로 스크롤을 하는 예제이다.

```dart
SizedBox(
  height: 180,
  child: ClubListView(
    scrollDirection: Axis.horizontal,
    separatorBuilder: (p0, p1) => const SizedBox(width: 8),
    itemBuilder: (club, i) => SizedBox(
      width: 180,
      child: Padding(
        padding: EdgeInsets.only(left: i == 0 ? 16 : 0),
        child: ClubCard(club: club),
      ),
    ),
  ),
),
```

## 클럽 카드

- `ClubCard` 위젯은 클럽 사진과 이름 등을 카드 형태의 위젯 UI 로 보여주는 것으로 클럽을 목록이나 기타 방식으로 표현 할 때, 사용하면 된다.




## 클럽 가입과 탈퇴

아래와 같이 `join` 과 `leave` 함수로 클럽에 가입 또는 탈퇴를 할 수 있다.

```dart
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ClubJoinButton extends StatelessWidget {
  const ClubJoinButton({
    super.key,
    required this.club,
  });

  final Club club;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (club.joined) {
          await club.leave();
        } else {
          await club.join();
        }
      },
      child: Text(
        club.joined ? '탈퇴하기' : '가입하기',
      ),
    );
  }
}
```