enum ActivityType {
  chat,
  feed,
  post,
  comment,
  user,
}

enum ActivityUserAction {
  create,
  update,
  delete,
  signin,
  signout,
  like,
  unlike,
  follow,
  unfollow,
  viewProfile,
  favorite,
  unfavorite,
  share,
}

enum ActivityPostAction {
  create,
  update,
  delete,
  like,
  unlike,
  favorite,
  unfavorite,
  share,
}

enum ActivityCommentAction {
  create,
  update,
  delete,
  like,
  unlike,
  favorite,
  unfavorite,
  share,
}

enum ActivityChatAction {
  open,
  send,
  share,
  favorite,
  unfavorite,
}

enum ActivityFeedAction {
  follow,
  unfollow,
  share,
}
