# Activity log


Fireflutter uses Firestore to save the activity logs.

It was first implemented with RTDB and it was working fine. But it was more complicated and difficult to manage when it is built with RTDB. So, we replaced RTDB with firestore. Using firestore may cause a bit more but we thought it would be more beneficial for management.


Activity logs should contain as minimal data as it can be since the size of data stroage can grow fast. And when it has minimal data, the logic goes simple.




## Database structure


- All the activities are saved as a document under `activity_logs` collection.
- It has the following fields
  - `uid` - the uid of the login user
  - `otherUid` - the other uid that the activity to applied to. It's optional and may not be exists.
  - `postId` - the post id that the activity is applied to.
  - `commentId` - the comment id that the activity is applied to.
  - `type` - is the model name or namespace where the activity is made on. `user`, `post`, `chat` are predefined. You can add your own type here like `shoppingmall`, `todo`, `game`, etc.
    - For `chat`, it only logs when a user create or join the chat room. It does not leave logs for the sending chat messages.
  - `action` - it may be one of the CRUD action. Or `like`, `unlike`, `follow`, `unfollow`, etc.
  - `createdAt` - the time that the action made.
  - You may add your own fields to extends the activity logs. 
    - For instance, you need to save logs for the activities of shopping mall feature that you maid. Then you would add `itemId` for the product item.
      - And you can save `mall` as the type.


Note that, when the type is `comment`, `postId` will have value and you can use it to display all the activities of the post.
Note that, if the the action happens too much like reading a post or comment, then it should not be saved since the size of the storage may grow so fast. But if some action is not happen too often, then the log may be saved like viewing public profile, or updating comment.


## Saving logs


- Use `activityLog()` function to save activities.

When the login user likes on abc, then use the code below.

```dart
activityLog(
    otherUid: 'abc',
    type: `user`,
    action: `like`
)
```

When the login user updates a post, then use the code below;

```dart
activityLog(
    type: `post`,
    action: `update`,
    postId: `-post-id-xxx-`
)
```



## Admin listing

- There is a widget named `AdminActivityList`. With this, you can filter by `type, action` and sort by time. If you want to customize the list, you can copy the widget and make your own.
  - The `AdminAcitivyList` also provide an input box to search by user name.
- To provide more filter options, you can use `ActivityService.instance.init( adminFilterOptions: [ 'user', 'post', 'comment', 'todo', 'mall', ] )`.

