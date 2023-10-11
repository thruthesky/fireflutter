# Table of Contents

<!-- @import "[TOC]" {cmd="toc" depthFrom=2 depthTo=5 orderedList=false} -->

<!-- code_chunk_output -->

- [Overview](#overview)
- [ShareService](#shareservice)

<!-- /code_chunk_output -->



# Share

## Overview

## ShareService

ShareService is a helper library that gives some feature utility for sharing. It has `showBottomSheet` method that displays a bottom sheet showing some UI elements for sharing. You may get an idea seeing the look and the code of the method.

It also has a method `dyamicLink` that returns a short dyanmic link. You may see the source code of the method to get an insight how you would copy and paste in your project.

```dart
Share.share(
  await ShareService.instance.dynamicLink(
    link: "https://xxx.page.link/?type=feed&id=${post.id}",
    uriPrefix: "https://xxx.page.link",
    appId: "com.xxx.xxx",
    title: post.title,
    description: post.content.upTo(255),
  ),
  subject: post.title,
);
```
Often, the `dynamicLink` method is called deep inside the widget tree. So, we provide a customization for building dynmaic links. You can set the `uriPrefix` and the `appId`. And the fireflutter will use this setting to generator custom build.

```dart
ShareService.instance.init(
  uriPrefix: "https://xxx.page.link",
  appId: "xxx.xxx.xxx",
);
```

When the dyanmic link is build, it has one of the `type` between `user`, `post`. When it is a `user`, you may show the user's profile. If it is `post`, you may show the post. We don't support the link for `chat` yet. Because the user needs to register first before entering the chat room while user profile and post view can be seen without login. But we are planning to support for `chat` link soon.

Dispaly a share bottom sheet.

```dart
ShareService.instance.showBottomSheet(actions: [
  IconTextButton(
    icon: const Icon(Icons.share),
    label: "Share",
    onTap: () async {
      Share.share(
        await ShareService.instance.dynamicLink(
          link: "https://xxxx.page.link/?type=xxx&id=xxx",
          uriPrefix: "https://xxxx.page.link",
          appId: "xxx",
          title: 'title',
          description: 'description..',
        ),
        subject: 'subject',
      );
    },
  ),
  IconTextButton(
    icon: const Icon(Icons.copy),
    label: "Copy Link",
    onTap: () {},
  ),
  IconTextButton(
    icon: const Icon(Icons.comment),
    label: "Message",
    onTap: () {},
  ),
]),
```

Example of copying the dynamic link to clipboard

```dart
IconTextButton(
  icon: const Icon(Icons.copy),
  label: "Copy Link",
  onTap: () async {
    final link = await ShareService.instance.dynamicLink(
      type: DynamicLink.post.name,
      id: 'post.id',
      title: 'title',
      description: 'description..',
    );
    Clipboard.setData(ClipboardData(text: link));
    toast(title: tr.copyLink, message: tr.copyLinkMessage);
  },
),
```

Below is an example of how to use `ShareBottomSheet` widget. You can insert this widget in home screen and do some UI work. Then, apply it.

```dart
ShareBottomSheet(actions: [
  IconTextButton(
    icon: const Icon(Icons.share),
    label: "Share",
    onTap: () async {
      Share.share(
        await ShareService.instance.dynamicLink(
          type: DynamicLink.feed.name,
          id: 'post.id',
          title: 'title',
          description: 'description..',
        ),
        subject: 'subject',
      );
    },
  ),
  IconTextButton(
    icon: const Icon(Icons.copy),
    label: "Copy Link",
    onTap: () async {
      final link = await ShareService.instance.dynamicLink(
        type: DynamicLink.post.name,
        id: 'post.id',
        title: 'title',
        description: 'description..',
      );
      Clipboard.setData(ClipboardData(text: link));
      toast(title: tr.copyLink, message: tr.copyLinkMessage);
    },
  ),
  IconTextButton(
    icon: const Icon(Icons.comment),
    label: "Message",
    onTap: () async {
      final link = await ShareService.instance.dynamicLink(
        type: DynamicLink.post.name,
        id: 'post.id',
        title: 'title',
        description: 'description..',
      );
      final re = await launchSMS(phnumber: '', msg: link);
      if (re) {
        toast(title: 'SMS', message: 'Link sent by SMS');
      } else {
        toast(title: 'SMS', message: 'Cannot open SMS');
      }
    },
  ),
]),
```