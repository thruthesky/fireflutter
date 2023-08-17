<!-- 
This file provides your users an overview of how to use your extension after they've installed it. All content is optional, but this is the recommended format. Your users will see the contents of this file in the Firebase console after they install the extension.

Include instructions for using the extension and any important functional details. Also include **detailed descriptions** for any additional post-installation setup required by the user.

Reference values for the extension instance using the ${param:PARAMETER_NAME} or ${function:VARIABLE_NAME} syntax.
Learn more in the docs: https://firebase.google.com/docs/extensions/publishers/user-documentation#reference-in-postinstall

Learn more about writing a POSTINSTALL.md file in the docs:
https://firebase.google.com/docs/extensions/publishers/user-documentation#writing-postinstall
-->

# See it in action

You can test out this extension right away!

Simply create a document under `easy-commands` with the following fields.

```json
{
    "commands": "update_user_claims",
    "options": {
        "uid": "xxx",
        "level": 1
    }
}
```

A few moments later, you will the that the document is updated 

```json
{
  "response": {
    "claims": { "... updated claims ..." },
    "status": "success",
    "timestamp": "Timestamp { _seconds: xxx, _nanoseconds: xxx }"
  }
}
```

# Using the extension

When a command document is created, this extension will execute the specified command.

To learn more about this extension, visit the [Easy Extension Document Site](https://github.com/thruthesky/easy-extension).

<!-- We recommend keeping the following section to explain how to monitor extensions with Firebase -->
# Monitoring

As a best practice, you can [monitor the activity](https://firebase.google.com/docs/extensions/manage-installed-extensions#monitor) of your installed extension, including checks on its health, usage, and logs.
