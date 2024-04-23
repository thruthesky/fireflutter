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

클럽을 생성 할 때, 생성된 클럽과 그 클럽에서 사용할 게시판들을 연결할 설정을 따로 하지 않는다. 즉, 클럽과 게시판의 연결(링크)를 위해서 DB 변경이나 따로 코드 실행을 하지 않는다. 클럽에는 게시판과 사진첩이 있는데 이 두 개가 있는데, 각 아이디이를 `clubId-club-post` 와 `clubId-club-gallery` 로 사용한다. 그러면 클럽별 게시글을 목록 할 수 있고, 각 게시글이 어느 클럽에 속해 있는지도 알 수 있게 된다.

이와 같이 게시판의 아이디를 활용하여 여러가지 형태로 사용 할 수 있다. 전체 게시글을 목록 할 때 클럽의 글이 나오므로 주의해야 한다. 이 경우 클럽에 가입해야지만 내용을 볼 수 있도록 할 수 있다.






## 클럽과 채팅

클럽을 생성 할 때, 그룹 채팅방을 생성하고, 최초 클럽 생성자를 채팅방에 입장을 시킨다. 물론 클럽을 생성한 사용자가 채팅방의 관리자가 된다.

사용자가 클럽에 가입을 하면, 채팅방에 입장을 시키고 클럽 탈퇴를 하면 채팅방에서도 퇴장을 하게 된다. 참고로, 채팅방에 미리 입장을 시켜놓아야 알림 등을 받게 된다.





## 클럽과 모임 일정

클럽 마스터가 일정을 생성 할 수 있다. 자세한 내용은 [모임 문서](./meetup.md)를 참고한다.






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


## 하나의 클럽 정보를 화면에 표시하기

아래의 예제는 `Club.get()` 을 통해서 클럽 정보를 가져와 화면에 표시를 해 주는 예제이다.


```dart
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ClubFindFriendScreen extends StatefulWidget {
  static const String routeName = '/ClubFindFriend';
  const ClubFindFriendScreen({super.key});

  @override
  State<ClubFindFriendScreen> createState() => _ClubFindFriendScreenState();
}

class _ClubFindFriendScreenState extends State<ClubFindFriendScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이성 친구 찾기 추천 모임 목록'),
      ),
      body: Column(
        children: [
          const Text("많고 많은 모임들 중에서 이성 친구를 찾을 수 있는 모임을 추천해 드립니다."),
          FutureBuilder<Club>(
            future: Club.get(id: '17MCAQOIRJPYuIYqR6qD'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Something went wrong! ${snapshot.error}');
              }
              final club = snapshot.data!;
              return ClubListTile(club: club);
            },
          ),
        ],
      ),
    );
  }
}
```
