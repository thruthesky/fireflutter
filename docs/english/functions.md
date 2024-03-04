# Functions

These functions are provided to be used anywhere in the code as needed.

## Error Display Functions

You can display errors on the screen using the following two methods:

- The `error` function utilizes `showDialog` to display the error on the screen using an ErrorDialog.
- The `errorToast` function uses a `toast` to display the error on the screen.

## Toast

Toast can be used to show a snackbar with a message.

```dart
toast(context: context, message: 'Hello User.');
```

Parameters:

- context
    - required BuildContext
    - the build context of the current widget
- title
    - String
    - title text of the snackbar
- message
    - required String
    - message to show as text
- icon
    - Icon
    - The icon to add in the snackbar
- duration
    - Duration
    - how long does the snackbar shows?
    - default: const Duration(seconds: 8)
- onTap
    - Function(Function)
    - on tap function
- error
    - bool
    - is it an error message?
- hideCloseButton
    - bool
    - default: false
- backgroundColor
    - Color
- foregroundColor
    - Color
- runSpacing
    - double
    - default: 12
    - spacing between the icon and the message

## confirm

The `confirm` is a prompt that will let the user choose from yes or no.

```dart
final re = await confirm(
    context: context,
    title: 'Delete Account',
    message: 'Are you sure you want to delete your account?'
);
```

The `re` in the example will be a nullable bool. If `re` is `true` means user chooses yes. If `false` means user chooses no. If `null` means neither user chooses yes nor no.

Parameters:

- [required] BuildContext context
- [required] String title
    - title of the message
- [required] String message
    - Add the question or confirmation message here.

## input

The `input` function can be used to ask for an input from user.

```dart
final re = await input(
    context: context,
    title: 'Name',
    subtitle: 'Enter your lovely name',
    hintText: 'Last Name, First Name',
);
```

Parameters:

- [required] BuildContext context
- [required] String title
    - The title of the prompt
- String subtitle
    - The subtitle or additional info for input box
- [required] String hintText
    - hintText for the input box
- String initialValue
    - the default input value
