import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// 새 프로필 사진을 등록한 순서대로 사용자 목록을 보여주는 위젯
///
class NewProfilePhotos extends StatelessWidget {
  const NewProfilePhotos({
    super.key,
    this.avatarSize = 48,
    this.avatarRadius = 20,
  });

  final double avatarSize;
  final double avatarRadius;

  @override
  Widget build(BuildContext context) {
    return
        // 새 프로필
        SizedBox(
      height: 96,
      child: FirebaseDatabaseQueryBuilder(
        query: FirebaseDatabase.instance
            .ref('user-profile-photos')
            .orderByChild(
              Field.updatedAt,
            )
            .startAt(false),
        builder: (context, snapshot, _) {
          if (snapshot.isFetching) {
            return const SizedBox(
              height: 96,
            );
          }

          if (snapshot.hasError) {
            return Text('Something went wrong! ${snapshot.error}');
          }

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.docs.length,
            itemBuilder: (context, index) {
              // if we reached the end of the currently obtained items, we try to
              // obtain more items
              if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
                // Tell FirebaseDatabaseQueryBuilder to try to obtain more items.
                // It is safe to call this function from within the build method.
                snapshot.fetchMore();
              }

              final profile =
                  Map<String, dynamic>.from(snapshot.docs[index].value as Map);

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => UserService.instance.showPublicProfileScreen(
                  context: context,
                  uid: snapshot.docs[index].key!,
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 16 : 0),
                  child: Column(
                    children: [
                      Avatar(
                        photoUrl: profile[Field.photoUrl] ?? '',
                        size: avatarSize,
                        radius: avatarRadius,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ((profile[Field.displayName] ?? '') as String).cut(9),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(
              width: 8,
            ),
          );
          // ...
        },
      ),
    );
  }
}
