import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Report list for admin
///
/// 1. all, unviewed, rejected, accepted, blocked list.
class ReportAdminListView extends StatelessWidget {
  const ReportAdminListView({super.key, this.padding});
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              TabBar(tabs: [
                Tab(text: T.request.tr),
                Tab(text: T.rejected.tr),
                Tab(text: T.accepted.tr),
              ]),
              Expanded(
                child: TabBarView(
                  children: [
                    FirebaseDatabaseListView(
                        padding: padding ??
                            const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                        query: Report.unviewedRef,
                        errorBuilder: (context, error, stackTrace) {
                          dog("Error: $error");
                          return Center(
                            child: Text('Error: $error'),
                          );
                        },
                        itemBuilder: (context, snapshot) =>
                            ReportAdminListTile(snapshot: snapshot)),
                    FirebaseDatabaseListView(
                        padding: padding ??
                            const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                        query: Report.rejectedRef,
                        errorBuilder: (context, error, stackTrace) {
                          dog("Error: $error");
                          return Center(
                            child: Text('Error: $error'),
                          );
                        },
                        itemBuilder: (context, snapshot) =>
                            ReportAdminListTile(snapshot: snapshot)),
                    FirebaseDatabaseListView(
                      padding: padding ??
                          const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 8,
                          ),
                      query: Report.acceptedRef,
                      errorBuilder: (context, error, stackTrace) {
                        dog("Error: $error");
                        return Center(
                          child: Text('Error: $error'),
                        );
                      },
                      itemBuilder: (context, snapshot) => ReportAdminListTile(
                        snapshot: snapshot,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
