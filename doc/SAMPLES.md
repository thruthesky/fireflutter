# Table of Contents


<!-- @import "[TOC]" {cmd="toc" depthFrom=2 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [How to build a user profile page](#how-to-build-a-user-profile-page)
  - [Create Scaffold widgets](#create-scaffold-widgets)
  - [UserBuilder()](#userbuilder)
  - [Result](#result)
- [How to build a chat app](#how-to-build-a-chat-app)
  - [initState](#initstate)
  - [ChatRoomListView Widget](#chatroomlistview-widget)
  - [Result](#result-1)
- [How to build a forum app](#how-to-build-a-forum-app)
  - [initState](#initstate-1)
  - [PostListView](#postlistview)
  - [Result](#result-2)

<!-- /code_chunk_output -->



## How to build a user profile page 

<!-- will revised this continously while studying fireflutter -->

Here is an example of how to build simple user profile page.

### Create Scaffold widgets

Build your own design of your app.

```dart
@override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; // get device's size
    return Scaffold(
      appBar: _myOwnAppBar(context), //custom AppBar
      body: SizedBox(
        width: size.width,
        child: const Column(
          children: [
            UserBuilder(), // Profile image Builder
            /*
             * ... Other Widgets here
             */
          ],
        ),
      ),
    );
  }
```

### UserBuilder()

[**UserDoc**](/README.md#userdoc) is responsible for taking all the documents of user from the database. With the help of [**UserProfileAvatar**](#userprofileavatar) we can display the user's profile photo to our app.

```dart
class UserBuilder extends StatelessWidget {
  const UserBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return UserDoc(builder: (user) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          UserProfileAvatar( // displays the user's profile photo
            radius: 20,
            user: user,
            size: 100,
            upload: true,
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // you can change this based on your needs
              _textBuilder(context, my.email),
              _textBuilder(context, my.uid),
              _textBuilder(context, my.hasPhotoUrl.toString()),
            ],
          ),
        ],
      );
    });
  }
}
```

### Result

**_Note:_** [**UserProfileAvatar**](/README.md#UserProfileAvatar) returns an icon that will serve as a default profile picture if the user doesn't have any picture uploaded.

![user_profile](/doc/img/user_profile.png)

## How to build a chat app

Here is an instruction on how to create a simple chat app

### initState

Create a stateful widget and add an `initState()`

```dart
@override
void initState() {
  super.initState();
  // using the code below you can customize the AppBar of Chat Room
  // Note: this will be created only of the Chat Room
  ChatService.instance.customize.chatRoomAppBarBuilder = ({room, user}) => customAppBar(context, room);
}
```

### ChatRoomListView Widget

Add the FireFlutter controller

```dart
final ChatRoomListViewController controller = ChatRoomListViewController();
```

Add a `Scaffold()` and create your own UI design. Inside the body add the `ChatRoomListView()`. See [Chat Features](#chat-feature) for more info.

```dart
Scaffold(
  appBar: appBar('Chats'),
  bottomNavigationBar: const BottomNavBar(index: 1),
  body: ChatRoomListView(
    controller: controller, // ChatRoomListViewController controller;
    singleChatOnly: false,
    itemBuilder: (context, room) => ChatRoomListTile(
      room: room,
      onTap: () {
        controller.showChatRoom(context: context, room: room); // display the chat room on tap... the appbar from initState() will apply to this.
      },
    ),
  ),
)
```

### Result

![chat_app](/doc/img/chat_app.png)

**_Note:_** Admins will automatically send a welcome message when `UserService.instance.sendWelcomeMessage(message: 'Welcome!')` is being used.

## How to build a forum app
### initState

```dart
@override
void initState() {
  super.initState();
  PostService.instance.enableNotificationOnLike = true; // set to true to enable notification
  PostService.instance.init( // This will send a notif to the owner of the post
      enableNotificationOnLike: true,
      onLike: (Post post, bool isLiked) async {
        if (!isLiked) return;
        MessagingService.instance.queue(
          title: post.title,
          body: '${my.name} liked your post',
          id: myUid,
          uids: [post.uid],
          type: NotificationType.post.name,
        );
      });
  // This will provide a custom design for showPostViewScreen()
  PostService.instance.customize.showPostViewScreen = (context, {post, postIdasync}) => showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) {
        final dateAgo = dateTimeAgo(post!.createdAt);
        return  CustomPostViewScreen(
                    dateAgo: dateAgo,
                    post: post,
                    snapshot: snapshot,
                  ),
        }
      ),
}
```

### PostListView

`PostListView()` builder works like a `ListView()`. It can display widgets with the posts details in a scrollable manner.

```dart
PostListView(
  itemBuilder: (context,post) => CustomTile(post: post)
)
```

You can use `PostCard()` to generate a default style of the post

```dart
PostListView(
    itemBuilder: (context, post) => InkWell(
      onTap: () => PostService.instance.showPostViewScreen(context: context, post: post),
      child: PostCard(
        post: post,
        shareButtonBuilder: (post) => IconButton(
          onPressed: () {
            ShareService.instance.showBottomSheet();
          },
          icon: const Icon(Icons.share, size: sizeSm), // FireFlutter provides sizes
        ),
      ),
    ),
  ),
```

**_Note:_** Aside from `Theme()`, there are many builders inside the `PostCard()` that you can use for customizing UI Design.

### Result

![forum_result](/doc/img/forum.png)
