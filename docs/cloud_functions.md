# Firebase Cloud Functions

I thought that I will not use Firebase cloud functions since it is a bit difficult to maintain the code. And we already have all the neccessary code in Flutter. But the code in the Flutter is not efficient. For instance, sending push notifications for a group chat from the Flutter app can downgrade the performance seriously. Even if the work is done in isolated, still it will consume a hugh resource. I am expecing that there are more than 1,000 uesrs who are chatting a lot every day. That's what acctually happens. And every time a user send a message, the push message ... (I will not explain it details.)

So, the app should not do this work from the Flutter app. You may send the push notification from client only if it will not consume a lot of resource.

And here comes the cloud functions


## Sending push notificaiton on each chat message

## Sending push notification on post and comment create


## Indexing data into typesense




## indexing post data issues

- When ever comment is created/updated/deleted, the post write event trigger unneccessarily causing extra function call, document read(including all the comments), and band width, and unneccessary typesense indexing. As of now, we just let it be this way. This is the cheapest for now.
