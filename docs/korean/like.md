# 좋아요


텍스트 버튼으로 표시 할 때 아래와 같이 할 수 있다. 다만, 좋아요 숫자 증가는 cloud function 에 의해서 동작하므로, 실시간으로 빠르게 표시되 않는데, 적절한 처리가 필요하다.

```dart
ElevatedButton(
  onPressed: () async {
    await my?.like(uid);
  },
  child: Value(
    path: Path.userField(uid, Field.noOfLikes),
    builder: (v) => Text(
      v == null || v == 0
          ? T.like.tr
          : v == 1
              ? ('${T.like.tr} 1')
              : '${T.likes.tr} ${v ?? ''}',
    ),
  ),
),
```

## 좋아요 목록

좋아요 목록은 총 세 가지가 있다.

- 첫째, 내가 좋아요 한 사람 목록.
- 둘째, 나를 좋아요 한 사람 목록.
- 셋째, 서로 좋아요 한 목록. 내가 A 이고, A 가 B 를 좋아요 하고, B 도 A 를 좋아요 했다면, B 가 서로 좋아요 목록에 타나난다.


아래와 같이 코딩을 하면 된다.

```dart
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class LikeScreen extends StatefulWidget {
  const LikeScreen({super.key});

  @override
  State<LikeScreen> createState() => _LikeScreenState();
}

class _LikeScreenState extends State<LikeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Who Likes Me'),
              Tab(text: 'Who I Like'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            WhoLikeMeListView(),
            WhoILikeListView(),
          ],
        ),
      ),
    );
  }
}
```

## 좋아요 커스텀 코딩

- 2024년 4월 현재 `WhoLikeMeListView` 와 같은 좋아요 관련 위젯이 약간 부족한 느낌이 있다. 이와 같은 경우 아래와 같이 원하는데로 직접 코딩을 하면 된다. 참고로 좋아요 관련 위젯은 차후 더 좋은 UI 로 업데이트가 될 예정이다.


```dart
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:roha/app.localization.dart';
import 'package:roha/extensions.dart';
import 'package:roha/global.dart';
import 'package:roha/screens/like/widget/like_user.tile.dart';
import 'package:roha/screens/search/widgets/empty.search.dart';

class LikeScreen extends StatefulWidget {
  static const String routeName = '/Like';
  const LikeScreen({super.key});

  @override
  State<LikeScreen> createState() => _LikeScreenState();
}

class _LikeScreenState extends State<LikeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Theme(
                data: Theme.of(context).copyWith(
                  tabBarTheme: Theme.of(context).tabBarTheme.copyWith(
                        labelColor: Theme.of(context).colorScheme.primary,
                        unselectedLabelColor:
                            Theme.of(context).colorScheme.onBackground,
                      ),
                ),
                child: TabBar(
                  indicatorWeight: 6,
                  labelStyle:
                      context.titleLarge.copyWith(fontWeight: FontWeight.w400),
                  tabs: [
                    // review the tabar does not look good when using scalling the text size
                    // accordong to the sized
                    // so i change it to textoverflows
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              '${'receivedLikes'.tr} ',
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              style:
                                  TextStyle(fontSize: resizeTabText(context)),
                            ),
                          ),
                          const Icon(Icons.favorite)
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              '${'sentLikes'.tr} ',
                              maxLines: 1,
                              style:
                                  TextStyle(fontSize: resizeTabText(context)),
                              overflow: TextOverflow.clip,
                            ),
                          ),
                          const Icon(Icons.favorite),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              '${'mutualLikes'.tr} ',
                              maxLines: 1,
                              style:
                                  TextStyle(fontSize: resizeTabText(context)),
                              overflow: TextOverflow.clip,
                            ),
                          ),
                          const Icon(Icons.favorite)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    FirebaseDatabaseQueryBuilder(
                      query: User.whoLikeMeRef.child(myUid!),
                      pageSize: 8,
                      builder: (context, snapshot, child) {
                        if (snapshot.isFetching) {
                          return const Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                        }
                        if (!snapshot.hasData || snapshot.docs.isEmpty) {
                          return EmptyDisplay(
                            text: "아직 아무도 당신을 좋아하지 않았습니다."),
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.only(top: sm),
                          itemCount: snapshot.docs.length,
                          itemExtent: 120,
                          itemBuilder: (context, index) {
                            return LikeUserTile(
                              uid: snapshot.docs[index].key!,
                              showDeleteButton: false,
                            );
                          },
                        );
                      },
                    ),
                    FirebaseDatabaseQueryBuilder(
                      pageSize: 8,
                      query: User.whoILikeRef.child(myUid!),
                      builder: (context, snapshot, child) {
                        if (snapshot.isFetching) {
                          return const Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                        }
                        if (!snapshot.hasData || snapshot.docs.isEmpty) {
                          return EmptyDisplay(
                            text: "당신은 아직 아무도 좋아하지 않았습니다."),
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.only(top: sm),
                          itemCount: snapshot.docs.length,
                          itemExtent: 120,
                          itemBuilder: (context, index) {
                            return LikeUserTile(
                              uid: snapshot.docs[index].key!,
                              showDeleteButton: true,
                            );
                          },
                        );
                      },
                    ),
                    FirebaseDatabaseQueryBuilder(
                      pageSize: 8,
                      query: User.mutualLikeRef.child(myUid!),
                      builder: (context, snapshot, child) {
                        if (snapshot.isFetching) {
                          return const Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                        }
                        if (!snapshot.hasData || snapshot.docs.isEmpty) {
                          return EmptyDisplay(
                            text: "아직 서로 좋아요 한 사용자가 없습니다."),
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.only(top: sm),
                          itemCount: snapshot.docs.length,
                          itemExtent: 120,
                          itemBuilder: (context, index) {
                            return LikeUserTile(
                              uid: snapshot.docs[index].key!,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double resizeTabText(BuildContext context) {
    String languageCode = context.languageCode;
    dog('${context.screenWidth}');
    if (languageCode == 'my') {
      return context.isNarrow ? 12 : 15;
    } else if (languageCode == 'en') {
      return context.isNarrow ? 17 : 18;
    } else if (languageCode == 'th') {
      return context.isNarrow ? 15 : 18;
    } else if (languageCode == 'lo') {
      return context.isNarrow ? 12 : 15;
    } else {
      return 18;
    }
  }
}
```