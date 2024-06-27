import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class DefaultAdminReportScreen extends StatelessWidget {
  const DefaultAdminReportScreen({
    super.key,
    this.separatorBuilder,
    this.padding,
  });

  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(T.report.tr),
          bottom: TabBar(tabs: [
            Tab(text: T.request.tr),
            Tab(text: T.rejected.tr),
            Tab(text: T.accepted.tr),
          ]),
        ),
        body: TabBarView(
          children: [
            // unview
            FirebaseDatabaseQueryBuilder(
                query: Report.unviewedRef,
                builder: (context, snapshot, _) {
                  if (snapshot.isFetching) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Something went wrong! ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.docs.isEmpty) {
                    return Center(
                      child: Text(T.noReportsFound.tr),
                    );
                  }

                  return ListView.separated(
                    padding: padding ??
                        const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                    itemBuilder: (context, index) {
                      if (snapshot.hasMore &&
                          index + 1 == snapshot.docs.length) {
                        // Tell FirebaseDatabaseQueryBuilder to try to obtain more items.
                        // It is safe to call this function from within the build method.
                        snapshot.fetchMore();
                      }
                      return ReportAdminListTile(
                        snapshot: snapshot.docs[index],
                      );
                    },
                    separatorBuilder: separatorBuilder ??
                        (context, index) {
                          return const SizedBox(
                            height: 0,
                          );
                        },
                    itemCount: snapshot.docs.length,
                  );
                }),
            // reject
            FirebaseDatabaseQueryBuilder(
                query: Report.rejectedRef,
                builder: (context, snapshot, _) {
                  if (snapshot.isFetching) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text('Something went wrong! ${snapshot.error}');
                  }

                  if (!snapshot.hasData || snapshot.docs.isEmpty) {
                    return Center(
                      child: Text(T.noReportsFound.tr),
                    );
                  }
                  return ListView.separated(
                    padding: padding ??
                        const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                    itemBuilder: (context, index) {
                      if (snapshot.hasMore &&
                          index + 1 == snapshot.docs.length) {
                        // Tell FirebaseDatabaseQueryBuilder to try to obtain more items.
                        // It is safe to call this function from within the build method.
                        snapshot.fetchMore();
                      }
                      return ReportAdminListTile(
                        snapshot: snapshot.docs[index],
                      );
                    },
                    separatorBuilder: separatorBuilder ??
                        (context, index) {
                          return const SizedBox(
                            height: 0,
                          );
                        },
                    itemCount: snapshot.docs.length,
                  );
                }),
            // accepted
            FirebaseDatabaseQueryBuilder(
                query: Report.acceptedRef,
                builder: (context, snapshot, _) {
                  if (snapshot.isFetching) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text('Something went wrong! ${snapshot.error}');
                  }
                  if (!snapshot.hasData || snapshot.docs.isEmpty) {
                    return Center(
                      child: Text(T.noReportsFound.tr),
                    );
                  }

                  return ListView.separated(
                    padding: padding ??
                        const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                    itemBuilder: (context, index) {
                      if (snapshot.hasMore &&
                          index + 1 == snapshot.docs.length) {
                        // Tell FirebaseDatabaseQueryBuilder to try to obtain more items.
                        // It is safe to call this function from within the build method.
                        snapshot.fetchMore();
                      }
                      return ReportAdminListTile(
                        snapshot: snapshot.docs[index],
                      );
                    },
                    separatorBuilder: separatorBuilder ??
                        (context, index) {
                          return const SizedBox(
                            height: 0,
                          );
                        },
                    itemCount: snapshot.docs.length,
                  );
                })
          ],
        ),
      ),
    );
  }
}
