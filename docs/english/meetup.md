# Meetup

- "Meetup" is another term for "meeting" and refers to a club or gathering. The app allows users to join clubs, schedule offline meetings, and access various chats and bulletin boards to support these meetings.

- Meetup combines FireFlutter's chat and forum functions. You can also use FireFlutter's features to create other services.

- The default meetup includes various UI customization functions. For further customization, you can copy and modify the source code.

- Meetup information is stored in Firestore to allow detailed searching and filtering of meetup introductions and schedules. If you do not use the meetup function, you do not need to set up meetup-related Firestore settings.

## Overview

Meeting is a service for sharing details, dates, and participation applications for online seminars and offline meetings. This feature is one of the app's best functionalities.

- Meetup records are stored in Firestore.
- Allow to view all meetup information.
- Display all meetup
- Display latest meetup
- \*Display nearest meetup
- \*Search meetup

### Meetup Document data structure

- `/meetups/<meetup-id>` meetup document path
- `uid` is the user ID who first created the meetup. Can edit current meetup.
- `master` is the ID of the user who created the meetup. Can edit current meetup.
- `users` is the list of users who have joined the meetup.
- `createdAt` is the date when the meetup was created
- `updatedAt` is the date when the meetup was updated
- `photoUrl` is the URL of the meetup photo
- `hasPhoto` is true if the meetup has a photo, so we can filter meetup that has photo
- `name` is the name of the meetup
- `description` is the description of the meetup
- `reminder` is the reminder of the meetup
- `recommendedOrder` is the order of the meetup. can be use to sort the meetup

### Meetup Event Document data structure

- Meetup events are save separately. Here we can see who want/withdraw to attend the meetup-event.

- `/meetup-events/<meetup-event-id>` meetup-events document path
- `meetupId` is the meetup id where it is connected
- `createdAt` is the date when the meetup-event was created
- `updatedAt` is the date when the meetup-event was updated
- `meetAt` is the date when the meetup event will take place
- `description` is the description of the meetup event
- `title` is the title of the meetup event
- `uid` is the uid of the user who created the meetup-event
- `users` is the list of users who want to attend the meetup-event.
- `photoUrl` is the URL of the meetup-event photo
- `hasPhoto` is true if the meetup-event has a photo, so we can filter meetup-event that has photo

## Meetup and Forum

- When creating a meetup, no additional settings are needed to connect it with forum.
- Every meetup will have their own forum and forum gallery category.
- The category will be `{meetupId}-meetup-post` and `{meetupId}-meetup-gallery`.
- With this, it easy to identify which meetup each post belongs to.

## Meetup Chat

- When creating a meetup, it will create a group chat room.
- The creator of the meetup will automatically be the administrator of the chatroom.
- Only Users who join the meetup can use the chat room.
- If the user leaves the meetup, the user will also leave the chatroom.
- User must also enter the chatroom to recieve push notification.

## Meetup Event

- Meetup master can create meetup event.
- Meetup event requires `date`, `time`, `photo`, `title`, `description`

## Meetup Coding Guidelines

### MeetupService

`MeetupService` is the main service for meetup. To use it you can all the instance like `MeetupService.instance.showViewScreen()`

It has helper method to open most of the accessible meetup screens

- To show meetup screen you can call
  - `MeetupService.instance.showViewScreen()`
- To show meetup create screen you can call
  - `MeetupService.instance.showCreateScreen()`
- To show meetup update screen you can call
  - `MeetupService.instance.showUpdateScreen()`
- To show meetup members screen you can call
  - `MeetupService.instance.showMembersScreen()`
- To show meetup blocked members screen you can call
  - `MeetupService.instance.showBlockedMembersScreen()`

### MeetupEventService

`MeetupEventService` is the main service for meetup event. To use it you can all the instance like `MeetupEventService.instance.showViewScreen()`

It has helper method to open most of the accessible meetup event screens

- To show meetup event view screen you can call
  - `MeetupEventService.instance.showViewScreen()`
- To show meetup event create screen you can call
  - `MeetupEventService.instance.showCreateScreen()`
- To show meetup event update screen you can call
  - `MeetupEventService.instance.showUpdateScreen()`

## Meetup Admin

To open the meetup admin screen you can call

- `AdminService.instance.showMeetupSettingScreen()`

```dart
ElevatedButton(
  onPressed: () => AdminService.instance.showMeetupSettingScreen(),
  child: const Text('Open Meetup Admin Screen'),
);
```

## Meetup Widgets

Meetup have a list of widget ready to use widget. You can also copy this widget if you want to customize your own widget.

### Meetup Doc

- `MeetupDoc` widget rebuild base on the latest snapshot of the meetup document.
- The `builder` will rebuild if there are any changes on the meetup document provided

```dart
  MeetupDoc(
      meetup: meetup,
      builder: (Meetup meetup)  = {
        Text(meetup.name)
      }
  );
```

### Meetup Create Button

- To create new meetup you can add `MeetupCreateButton` widget to the `AppBar`.
- This is simply a widget that display a `IconButton(Icon(Icons.add)`.
- The `onPressed` will call `MeetupService.instance.showCreateScreen()`.
- This will display the `MeetupCreateForm`.

```dart
AppBar(
  title: const Text('Meetup'),
  actions: [
    MeetupCreateButton(),
  ],
);
```

### Meetup Create Form

- A widget that will ask the user to enter the meetup `name`.
- If the user input a name then `Create` button will appear

```dart
  Scaffold(
    appBar: AppBar(
      title: Text('Create Meetup'),
    ),
    body: MeetupCreateForm(
        onCreate: (Meetup meetup) => setState(() => this.meetup = meetup),
    ),
  );
```

### Meetup Update Form

- A widget display the meetup information and allow the user to update the meetup.

```dart
  Scaffold(
    appBar: AppBar(
      title: Text('Create Meetup'),
    ),
    body: MeetupUpdateForm(
       meetup: meetup
    ),
  );
```

### Meetup List View

- You can use `MeetupListView()` to display meetup that `hasPhoto` and sort by `createdAt`
- `MeetupListView()` also has the same parameter as `ListView.separated`.
- Therefore you can use `MeetupListView()` like how you use `ListView.separated`.
- Meetup information is saved in Firestore `meetups` collection.
- You can also use `query` to filter meetup list.
- The example below is an example of horizontally scrolling the meetup list.

```dart
SizedBox(
  height: 180,
  child: MeetupListView(
    scrollDirection: Axis.horizontal,
    separatorBuilder: (p0, p1) => const SizedBox(width: 8),
    itemBuilder: (Meetup meetup, i) => SizedBox(
      width: 180,
      child: Padding(
        padding: EdgeInsets.only(left: i == 0 ? 16 : 0),
        child: MeetupCard(meetup: meetup),
      ),
    ),
  ),
),
```

### Meetup List Tile

- The `MeetupListTile()` widget display the meetup information in a list-like UI.
- By default the `MeetupListView` uses `MeetupListTile()` to display its item.

Simply add

```dart
  Scaffold(
    appBar: AppBar(
      title: Text('Meetup List'),
    ),
    body: MeetupListView()
  );
```

or if you want to encapsulate the `MeetupListTile()` widget or even provide your own widget through itemBuilder.

```dart
  MeetupListView(
    itemBuilder: (Meetup meetup, i) => Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: MeetupListTile(meetup: meetup),
    )
  );
```

### Meetup Card

- The `MeetupCard()` widget displays meetup photos and names in a card-shaped widget UI and can be used when expressing meetups in lists or other ways.

```dart
  MeetupListView(
    itemBuilder: (Meetup meetup, i) => MeetupCard(meetup: meetup),
  );
```

### Meetup View Screen

- Meetup also provide a screen to display the meetup information and other functionalities.
- This includes
  - Meetup Information tab
  - Meetup Event tab
  - Meetup Chat tab
  - Meetup Forum tab
  - Meetup Forum Gallery tab
- You can simple call `MeetupService.instance.showViewScreen()`
- `MeetupListTile` and `MeetupCard` when tap it will open the respective `MeetupViewScreen`

```dart
  ElevatedButton(
    onPressed: () => MeetupService.instance.showViewScreen(
      context: context,
      meetup: meetup,
    ),
    child: const Text('Open Meetup View Screen'),
  );
```

### Meetup Edit Screen

- `MeetupEditScreen` will displays either `MeetupCreateForm` or `MeetupUpdateForm`
- If `meetup` is not not null, it will display `MeetupUpdateForm`.
- Otherwise, it will display `MeetupCreateForm`.

Creat Meetup

```dart
  ElevatedButton(
    onPressed: () => MeetupService.instance.showCreateScreen(
      context: context,
    ),
    child: const Text('Open Meetup Create Screen'),
  )
  or simply use the `MeetupCreateButton()` widget

  MeetupCreateButton()
```

or

Update Meetup

```dart
  ElevatedButton(
    onPressed: () => MeetupService.instance.showUpdateScreen(
      context: context,
      meetup: meetup,
    ),
    child: const Text('Open Meetup Edit Screen'),
  )
```

### Meetup Members List Screen

- Display all the members of the meetup.
- Additonally for meetup creator/master they can blocked member from this list.

```dart
  ElevatedButton(
    onPress: () => MeetupService.instance.showMembersScreen(
      context: context,
      meetup: widget.meetup,
    ),
    child: const Text('Open Meetup Members Screen'),
  );
```

### Meetup Members Blocked Screen

- Display all the blocked members of the meetup.
- The creator/master are the only one who can unblock member from this list.

```dart
  ElevatedButton(
    onPress: () => MeetupService.instance.showBlockedMembersScreen(
      context: context,
      meetup: widget.meetup,
    ),
    child: const Text('Open Meetup Blocked Members Screen'),
  );
```

### Joining and leaving the meetup

- You can join or leave a meeup using the `join` and `leave` functions as shown below.

```dart
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class MeetupJoinButton extends StatelessWidget {
  const MeetupJoinButton({
    super.key,
    required this.meetup,
  });

  final Meetup meetup;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (meetup.joined) {
          await meetup.leave();
        } else {
          await meetup.join();
        }
      },
      child: Text(
        meetup.joined ? 'Leave' : 'Join',
      ),
    );
  }
}
```

### Meetup Details

- Display the meetup details.
- This is by default included in the first tab of the view screen

```dart
  Scaffold(
    appBar: AppBar(
      title: Text('Meetup Details'),
    ),
    body: MeetupDetails(
      meetup: meetup,
    )
  )
```

### Meetup View Blocked

- This widget only display a message that the loggin user is blocked in the meetup.
- This will be displayed on the chat tab, forum tab and forum gallery tab. If the user was blocked by the creator/master.

```dart
MeetupDoc(
  meetup: meetup,
  builder: (Meetup meetup) {
    if (meetup.blocked == true) {
      return MeetupViewBlocked(
        meetup: meetup,
        label: T.meetupChatBlocked.tr,
      );
    } else {
      // do something...
    }
  },
),

```

### Meetup View Register First Button

- This widget only display a message that the loggin user is not registered in the meetup.
- With a button to join the meetup.
- This is by default displayed on the chat tab, forum tab and forum gallery tab. if the user didnt yet join the meetup.

```dart
  MeetupDoc(
    meetup: meetup,
    builder: (Meetup meetup) {
      if (meetup.users.contains(myUid)) {
        // do something...
      } else {
        return MeetupViewRegisterFirstButton(
          meetup: meetup,
          label: T.joinMeetupToChat.tr,
        );
      }
    },
  ),
```

## Meetup Event Widgets

Meetup events also have a list of widget ready to use widget. You can also copy this widget if you want to customize your own widget.

### Meetup Event List View

- You can use `MeetupEventListView()` to display meetup event that `hasPhoto` and sort by `createdAt`
- `MeetupEventListView()` also has the same parameter as `ListView.separated`.
- Therefore you can use `MeetupEventListView()` like how you use `ListView.separated`.
- Meetup event information is saved in Firestore `meetup-events` collection.
- You can also use `query` to filter meetup list.

```dart
  Scaffol(
    appBar: AppBar(
      title: Text('Meetup Events List'),
    ),
    body: MeetupEventListView()
  )
```

### Meetup Event Card

- The `MeetupEventCard()` widget displays meetup event photos and title in a card-shaped widget UI
- Date and time information will only be displayed to member of the meetup.
- This is by default the widget used by the `MeetupEventListView()` widget.

```dart
  MeetupEventListView()

  or if you want to encapsulate the widget

  MeetupEventListView(
    itemBuilder: (Meetup meetup, i) => Padding(
      padding: const EdgeInsets.all(8.0),
      child: MeetupEventCard(
        meetup: meetup,
        index: i,
      ),
    ),
  );
```

### Meetup Event Create Form

- To create new event for the specific meetup, you can use `MeetupEventCreateForm()` widget.
- You can call the `MeetupEventService.instance.showCreateScreen()` to show the form.
- It need the `meetupId` to create the event.

```dart
  Scaffold(
    appBar: AppBar(
      title: Text('Create Meetup Event'),
    ),
    body: MeetupEventCreateForm(
      meetupId: meetupId,
    )
  )
```

### Meetup Event Update Form

- To update the meetup event, you can use `MeetupEventUpdateForm()` widget.
- You can call the `MeetupEventService.instance.showUpdateScreen()` to show the form.
- It need the `meetupId` to create the event.

```dart
  Scaffold(
    appBar: AppBar(
      title: Text('Create Meetup Event'),
    ),
    body: MeetupEventCreateForm(
      meetupId: meetupId,
    )
  )
```

### Meetup Event Doc

- `MeetupEventDoc` widget rebuild base on the latest snapshot of the meetup-events document.
- The `builder` will rebuild if there are any changes on the meetup event document provided

```dart
  MeetupEventDoc(
      event: event,
      builder: (MeetupEvent event)  = {
        Text(event.title)
      }
  );
```

### Meetup Event Edit Screen

- `MeetupEventEditScreen` will displays either `MeetupEventCreateForm` or `MeetupEventUpdateForm`
- If `event` is not not null, it will display `MeetupEventUpdateForm`.
- Otherwise, it will display `MeetupEventCreateForm`. `meetupId` is required when creating an event so we can know which meetup it belongs to.

Creat Event

```dart
  ElevatedButton(
    onPressed: () => MeetupEventService.instance.showCreateScreen(
      context: context,
      meetupId: meetup.id,
    ),
    child: const Text('Open Meetup Event Create Screen'),
  )
```

or

Update Event

```dart
  ElevatedButton(
    onPressed: () => MeetupEventService.instance.showUpdateScreen(
      context: context,
      event: event,
    ),
    child: const Text('Open Meetup Event Edit Screen'),
  )
```

### Meetup Event View Screen

- Meetup Event also provide a screen to display the meetup event information.
- You can simply call `MeetupEventService.instance.showViewScreen()`
- When `MeetupEventCard` was tap it will open the respective `MeetupEventViewScreen`

```dart
  ElevatedButton(
    onPressed: () => MeetupService.instance.showViewScreen(
      context: context,
      event: event,
    ),
    child: const Text('Open Meetup View Screen'),
  );
```

## Displaying One meetup information on the screen

- The example below retrieves meetup information through `Meetup.get()` and displays it on the screen.

```dart
    Scaffold(
      appBar: AppBar(
        title: const Text('Meetup Get'),
      ),
      body: Column(
        children: [
          const Text("Get specific meetup"),
          FutureBuilder<Meetup>(
            future: Meetup.get(id: '17MCAQOIRJPYuIYqR6qD'), // provide the meetup id here
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Something went wrong! ${snapshot.error}');
              }
              final meetup = snapshot.data!;
              return MeetupListTile(meetup: meetup);
            },
          ),
        ],
      ),
    );
```

## Firestore 설정

### Firestore security rules

You can copy the rules below and supplement the correct admin uids, that allow to update the meetup information.
This permission will be use when the admin is assigning recommendedOrder to specific meetup to display the meetup in recommended list.

```ts
rules_version = '2';

// ****************************** COPY FROM ***********************************
//
//
// Return true if the user is admin user.
function isAdmin() {
  let adminUIDs = ['admin1Id', 'admin2Id'];
  return request.auth.uid in adminUIDs || request.auth.token.admin == true;
}
// ****************************** COPY UNTIL HERE *****************************



service cloud.firestore {
  match /databases/{database}/documents {

    match /_deeplink_/{deeplink} {
      allow read: if true;
    }

    match /users/{uid} {
      allow read: if true;
    }

    match /meetups/{meetupId} {
      // Return true if the user is removing himself from the room.
      function isLeaving() {
        return onlyRemoving('users', request.auth.uid);
      }

      // Return true if the user is adding himself to the room.
      function isJoining() {
        return
          onlyAddingOneElement('users')
          &&
          request.resource.data.users.toSet().difference(resource.data.users.toSet()) == [request.auth.uid].toSet();
      }
      allow read: if true;
      allow create: if (request.resource.data.uid == request.auth.uid);
      allow update: if (resource.data.uid == request.auth.uid) || isJoining() || isLeaving() || isAdmin();
      allow delete: if resource.data.uid == request.auth.uid;
    }

    match /meetup-events/{meetupId} {
      function isLeaving() {
        return onlyRemoving('users', request.auth.uid);
      }
      function isJoining() {
        return
          onlyAddingOneElement('users')
          &&
          request.resource.data.users.toSet().difference(resource.data.users.toSet()) == [request.auth.uid].toSet();
      }
      allow read: if true;
      allow create: if (request.resource.data.uid == request.auth.uid);
      allow update: if (resource.data.uid == request.auth.uid) || isJoining() || isLeaving();
    }
  }
}

// Return true if the array field in the document is removing only the the element. It must maintain other elements.
//
// arrayField is an array
// [element] is an element to be removed from the arrayField
//
// Returns
// - true if it try to remove an element that is not existing int the array and no other fields are changed.
// - false if the document does not exsit (especially when you put it on "update if: ...").
//
// Use case;
// Other users can add or remove only their uid from the followers array of the otehr user document
// match /users/{documentId} {
//   allow update: if request.auth.uid == documentId || onlyAdding('followers', request.auth.uid) || onlyRemoving('followers', request.auth.uid)
// }
function onlyRemoving(arrayField, element) {

  let oldSet = (arrayField in resource.data ? resource.data[arrayField] : []).toSet();
  let newSet = request.resource.data[arrayField].toSet();

  return
      // If the field does not exist and no other except the field changes, return true.
      // Why? - preventing permission if it tries to remove somthing that does not exist.
      // Does - it jsut return true without producing permission error.
      // Result - when something is deleted from non exisiting array, just pass.
      ( !(arrayField in resource.data) && noFieldChangedExcept(arrayField) )
      ||
      // If the field exists but the element does not exists.
      // Why? - when something is delete when it is not existing, just pass without permission error.
      ( !(element in oldSet) && noFieldChanged() )
      ||
      (
        // If the "arrayField" is the only field that is being chagned,
        onlyUpdating([arrayField])
        &&
        // And if the "element" is the only element that is being removed.
        oldSet.difference(newSet) == [element].toSet()
        &&
        // And if the old set is same as new set meaning, when something is deleted, the old set without the deleted element must have same value with new set.
        oldSet.intersection(newSet) == newSet
      )
  ;
}


// Returns true if it adds only one element to the array field.
//
// * It allows to update other fields in the document.
//
// This must add an elemnt only. Not replacing any other element. It does unique element check.
function onlyAddingOneElement(arrayField) {
  return
    resource.data[arrayField].toSet().intersection(request.resource.data[arrayField].toSet()) == resource.data[arrayField].toSet()
    &&
    request.resource.data[arrayField].toSet().difference(resource.data[arrayField].toSet()).size() == 1
  ;
}

// Returns true if there is no fields that are updated except the specified field.
function noFieldChangedExcept(field) {
  return request.resource.data.diff(resource.data).affectedKeys().hasOnly([field]);
}

// Returns true if there is no fields that are updated.
function noFieldChanged() {
  return request.resource.data.diff(resource.data).affectedKeys().hasOnly([]);
}

// Returns true if only the specified fields are updated in the document.
//
// For instance, the input fields are ['A', 'B'] and if the document is updated with ['A', 'C'], then it return true.
// For instance, the input fields are ['A', 'B'] and if the document is updated with ['C', 'D'], then it return false.
function onlyUpdating(fields) {
  return request.resource.data.diff(resource.data).affectedKeys().hasOnly(fields);
}
```
