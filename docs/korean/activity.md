# 액티비티 로그

- 글 쓰기, 코멘트 쓰기, 좋아요, 프로필 보기 등의 활동을 기록하고 관리하는 기능이다.
  - 단, 채팅 메시지 전송은 제외를 한다.


## 데이터베이스

- `user-activity/<uid>/profile-update` 는 프로필 수정
- `user-activity/<uid>/public-profile-view` 는 다른 사용자의 공개 프로필 보기
- `user-activity/<uid>/public-profile-like` 는 사용자 프로필 좋아요
- `user-activity/<uid>/post-create` 는 글 생성
- `user-activity/<uid>/post-like` 는 글 좋아요
- `user-activity/<uid>/comment-create` 은 코멘트 생성
- `user-activity/<uid>/comment-like` 은 코멘트 좋아요



```json
{
  createdAt: ...server-timestamp...
}
```
