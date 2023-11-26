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