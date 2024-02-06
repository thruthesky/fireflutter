# Building blocks

In this chapter, you will learn how to use some of the basic widgets to build your app fast. You may copy the source of the widget and customize for you own need.

You can use theme design to change the outlook of the building blocks.


## Error handling

Some widget may throw exception without any handler. It is recommended to set global error handler to catch all unhandled exceptions like below

```dart
runZonedGuarded(
    () async {
      runApp(const MyApp());
      /// Flutter error happens here like Overflow, Unbounded height
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.dumpErrorToConsole(details);
      };
    },
    zoneErrorHandler,
  );
  /// TODO record this error
  zoneErrorHandler(error, stackTrace) {
    /// Unhandled exceptions NOT from flutter framework.
    /// Firebase exceptions or dart(outside flutter) exceptions.
    /// Error from outside of Flutter will be handled here.
    print("----> runZoneGuarded() : exceptions outside flutter framework.");
    print("---> runtimeType: ${error.runtimeType}");

    if (error is FirebaseAuthException) {
      if (AppService.instance.smsCodeAutoRetrieval) {
        if (error.code.contains('session-expired') ||
            error.code.contains('invalid-verification-code')) {
          print("....");
          return;
        }
      } else {}

      toast(
          context: context,
          message: 'Error :  ${error.code} - ${error.message}');
    } else if (error is FirebaseException) {
      print("FirebaseException :  $error }");
    } else {
      print("Unknown Error :  $error");
      // toast(context: context, message: "백엔드 에러 :  ${error.code} - ${error.message}");
    }
    debugPrintStack(stackTrace: stackTrace);
  }
```




## Login

For simple login, you can use `SimpleEmailPasswordLoginForm`.



## Chat widgets

Whatever app that has the chat feature has common screens and widgets.


### Chat room list

To list chat rooms that the login user joined, use `DefaultChatRoomListView` widget. You can use the options to customize. Or simply copy all the code of the widget and customize with your own code.


### Chat room create


