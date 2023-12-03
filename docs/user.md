# User


## MyDoc

If the app is using `MyDoc` immediately when the it boots.

```dart
MyDoc(
    builder: (user) {
        if (user.exists == false) return const SizedBox.shrink();
        return ...
    }
)
```



## UserDocReady

This is to show(build) widgets that depends on the login user's document especially when the app is going to use the user's document immediately after the app boots (before the fireflutter loads the user document).


If you are going to use the global `my` variable immediately after app boots, it would cause null value error since the fireflutter `UserService` didn't loaded the user document, yet. To prevent this error, you may use `UserDocReady` widget. This widget displays `SizedBox.shrink()` until the user document is loaded. So, you can use the login user's document data safely.
This widget will now show `SizedBox.shrink()` if the user document is already loaded. So, it's not flickering.

One thing to note is that, if `setState` is called, the `UserDocReady` may cause screen flickering.


```dart
class SomeScreen extends StatelessWidget {
  const SomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return UserDocReady(
      builder: (user) => Text('${user.name}');
    );
  }
}
```


You may think of coding like below instead of using `UserDocReady`. And yes, you may do that if you have a reason for this.


```dart
class SomeScreen extends StatefulWidget {
  const SomeScreen({super.key});

  @override
  State<SomeScreen> createState() => _SomeScreenState();
}

class _SomeScreenState extends State<SomeScreen> {
  bool loaded = false;
  @override
  void initState() {
    super.initState();
    UserService.instance.documentChanges.listen((user) {
      if (loaded == true) return;
      if (user == null) return;
      if (user.exists == false) return;
      loaded = true;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyDoc(builder: (user) {
      if (user.exists == false) return const SizedBox.shrink();
      return Text('${user.name}');
    });
  }
}

```


## User information

The user documents under `users` collection are opened to public, so everyone can read and search.
The user documents under `user_private_data` collection are closed. No one except admin and the login user himself can read or update.


When a user registers with Google email or Phone number, fireflutter does not save these information into database since those are the most ciritical private information. If you want to save it, you must save in under `user_private_data` document, so it will not be exposed to others. You could save(update) the user's login email or phone number into `user_private_data` document anywhere in the app.
But consider not to save those sensitive information into the database.




## User resign

When a user wants to resign, the app may call `User.delete` method to delete the user's documents.



