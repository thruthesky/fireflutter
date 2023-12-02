# Widgets



## GraidentBox


```dart
return UserDocReady(
  builder: (user) => Scaffold(
    body: Stack(
      children: [
        if (user.hasPhotoUrl) CachedNetworkImage(imageUrl: user.photoUrl ),
        const GradientBox( // Top down
            height: 400,
            colors: [
            Colors.black,
            Colors.transparent,
            ],
        ),
        const Positioned( // Bottom up
            bottom: 0,
            left: 0,
            right: 0,
            child: GradientBox(
            height: 400,
            colors: [
                Colors.transparent,
                Colors.black,
            ]),
        ),
      ])
    ),
);
```