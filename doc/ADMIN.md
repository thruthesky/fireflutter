# Table of Contents  


<!-- @import "[TOC]" {cmd="toc" depthFrom=2 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->
<!-- [toc] -->
- [Table of Contents](#table-of-contents)
- [Admin](#admin)
  - [Overview](#overview)
  - [Admin Service](#admin-service)
  - [Admin Widgets](#admin-widgets)
    - [Opening admin dashboard](#opening-admin-dashboard)
    - [AdminUserListView](#adminuserlistview)
    - [Updating auth custom claims](#updating-auth-custom-claims)
    - [Disable user](#disable-user)

<!-- /code_chunk_output -->

# Admin 

## Overview

FireFlutter has an Admin Builders and Widgets so you don't have to create your own and deploy them at once. This helps for User Management and more.

## Admin Service

You can access some features using the `AdminService.instance`. Here are few example of how to use `AdminService`

```dart
final service = AdminService.instance;

/// Display the Chat Room details
/// [Room] room is required
service.showChatRoomDetails(context, room: room); // returns Widget

/// Display a screen where you can see all post and open it
/// onTap is optional
service.showChoosePostScreen(context, onTap: (post){ // returns a Scaffold widget
  // your code here
});
```

## Admin Widgets

Here are the Admin widgets that you can use on your app.

### Opening admin dashboard

To open admin dashboard, call `AdminService.instance.showDashboard()`.

```dart
AdminService.instance.showDashboard(context);
```

Or you may want to open with your own code like below

```dart
Navigator.of(context).push(
  MaterialPageRoute(builder: (c) => const AdminDashboardScreen()),
);
```

### AdminUserListView

To display all users on Admin's side you can use this widget `AdminUserListView`

```dart
ElevatedButton(
  onTap: () => showDialog(
    context: context,
    builder: (cnx) => const Dialog(
      child: AdminUserListView(),
    ),
  ),
  child: Text('Show Admin User List View'),
)
```
<!-- TODO: Ask Sir Song if this is outdated -->

### Updating auth custom claims

- Required properties

  - `{ command: 'update_custom_claims' }` - the command.
  - `{ uid: 'xxx' }` - the user's uid that the claims will be applied to.
  - `{ claims: { key: value, xxx: xxx, ... } }` - other keys and values for the claims.

- example of document creation for update_custom claims

![Image Link](https://github.com/thruthesky/easy-extension/blob/main/docs/command-update_custom_claims_input.jpg?raw=true "This is image title")

- Response
  - `{ config: ... }` - the configuration of the extension
  - `{ response: { status: 'success' } }` - success respones
  - `{ response: { timestamp: xxxx } }` - the time that the executino had finished.
  - `{ response: { claims: { ..., ... } } }` - the claims that the user currently has. Not the claims that were requested for updating.

![Image Link](https://github.com/thruthesky/easy-extension/blob/main/docs/command-update_custom_claims_output.jpg?raw=true "This is image title")

- `SYNC_CUSTOM_CLAIMS` option only works with `update_custom_claims` command.
  - When it is set to `yes`, the claims of the user will be set to user's document.
  - By knowing user's custom claims,
    - the app can know that if the user is admin or not.
      - If the user is admin, then the app can show admin menu to the user.
    - Security rules can work better.

### Disable user

- Disabling a user means that they can't sign in anymore, nor refresh their ID token. In practice this means that within an hour of disabling the user they can no longer have a request.auth.uid in your security rules.

  - If you wish to block the user immediately, I recommend to run another command. Running `update_custom_claims` comand with `{ disabled: true }` and you can add it on security rules.
  - Additionally, you can enable `set enable field on user document` to yes. This will add `disabled` field on user documents and you can search(list) users who are disabled.

- `SYNC_USER_DISABLED_FIELD` option only works with `disable_user` command.

  - When it is set to yes, the `disabled` field with `true` will be set to user document.
  - Use this to know if the user is disabled.

- Request

```ts
{
  command: 'delete_user',
  uid: '--user-uid--',
}
```

<!-- - Warning! Once a user changes his displayName and photoUrl, `EasyChat.instance.updateUser()` must be called to update user information in easychat. -->

<!-- Disabling user -->