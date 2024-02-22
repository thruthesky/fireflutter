# 북마크

- 북마크는 `좋아요`와는 다르게 나중에 다시 보고 싶은 정보를 저장 해 놓는 것이다.
- 북마크는 즐겨찾기 또는 Favorite 과 같은 의미이다.
- `/bookmarks/<로그인_사용자_UID>/<Target_UID>` 와 같이 저장된다.
- 값에
    - otherUserUid 가 들어가 있으면, 사용자 북마크
    - category 가 있으면 글 북마크
    - commentId 가 있으면 코멘트 복마크이다.
    - 채팅방은 북마크를 하지 않는다.

- 북마크와 북마크 해제는 `BookmarkModel.toggle()` 을 사용하면 된다.


## 북마크 목록






