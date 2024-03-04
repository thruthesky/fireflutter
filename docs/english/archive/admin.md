# Admin

## How to set a user as admin

1. Add the user uid under `/admins`.
   For instance, if the user uid is `abc`, then set it like below
   `/admins/{ abc: master }`
2. Set the `isAdmin` to true in the `/users/<uid>`.

## Displaying the Entire User List and Editing

To display the entire user list, you can simply utilize `FirebaseDatabaseListView`. For editing user information, you can reference `AdminService.instance.showUserList(context: context)`
