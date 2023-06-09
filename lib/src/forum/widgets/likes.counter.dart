import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class LikesCounter extends StatelessWidget {
  const LikesCounter({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseDatabase.instance.ref('likes/$id').onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox.shrink();
          }
          if (snapshot.hasData && snapshot.data!.snapshot.exists) {
            return Row(
              children: [
                Text(
                  '${snapshot.data!.snapshot.value.toString()} person likes this post',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            );
          }
          if (snapshot.hasError) {
            debugPrint('--------->custom like button: ${snapshot.error}');
          }
          return SizedBox.shrink();
        });
  }
}

class LikeButton extends StatefulWidget {
  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      builder: (context, snapshot) => TextButton.icon(
        onPressed: () {
          setState(() {
            isLiked = !isLiked;
          });
        },
        icon: Icon(isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined),
        label: const Text('Like'),
      ),
    );
  }
}
