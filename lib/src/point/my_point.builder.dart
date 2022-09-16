// import 'package:flutter/material.dart';

// class MyPointBuilder extends StatelessWidget {
//   MyPointBuilder({
//     Key? key,
//     this.builder,
//   }) : super(key: key);

//   final Function(int point)? builder;

//   @override
//   Widget build(BuildContext context) {
//     return Container();

//     // final uid = Controller.of.uid;
//     // if (uid == null) return SizedBox.shrink();

//     // return StreamBuilder<DatabaseEvent>(
//     //     stream: pointRef.child(uid).child('point').child('point').onValue,
//     //     builder: (c, snapshot) {
//     //       if (snapshot.hasData) {
//     //         final DatabaseEvent event = snapshot.data!;
//     //         final int point = (event.snapshot.value ?? 0) as int;

//     //         return builder != null
//     //             ? builder!(point)
//     //             : Text(
//     //                 'Point. $point',
//     //                 style: TextStyle(
//     //                   fontSize: 12,
//     //                   color: Colors.grey,
//     //                   fontStyle: FontStyle.italic,
//     //                 ),
//     //               );
//     //       } else {
//     //         return SizedBox.shrink();
//     //       }
//     //     });
//   }
// }
