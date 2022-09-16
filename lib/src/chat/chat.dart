// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fireflutter/fireflutter.dart';

// @Deprecated('Merge it into ChatService')
// class Chat {
//   // The other user's uid of current room.
//   // Use to Identify which room the current user at.
//   // Chat Push Notification check if otherUid is the sender then dont show the notification.
//   // static String otherUid = '';

//   /// Get number of new messages for other user
//   ///
//   /// ! Warning - This will read many documents. Chat feature is based on firestore at this time and it's expensive.
//   /// ! Warning - Use noOfNewMessages instead which, observe new messages and have the updated value all the time.
//   static Future<int> getNoOfNewMessages(String otherUid) async {
//     /// Send push notification to the other user.
//     QuerySnapshot querySnapshot = await ChatBase.otherRoomsCol(otherUid)
//         .where('newMessages', isGreaterThan: 0)
//         .get();

//     int newMessages = 0;
//     querySnapshot.docs.forEach((doc) {
//       ChatMessageModel room = ChatMessageModel.fromJson(doc.data() as Map);
//       newMessages += room.newMessages;
//     });
//     return newMessages;
//   }
// }
