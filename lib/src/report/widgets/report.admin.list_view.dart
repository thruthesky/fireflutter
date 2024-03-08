import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Report list for admin
///
/// 1. all, unviewed, rejected, accepted, blocked list.
class ReportAdminListView extends StatelessWidget {
  const ReportAdminListView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              TabBar(tabs: [
                Tab(text: 'unviewed'.tr),
                Tab(text: 'rejected'.tr),
                Tab(text: 'accepted'.tr),
              ]),
              Expanded(
                child: TabBarView(
                  children: [
                    FirebaseDatabaseListView(
                      query: Report.unviewedRef,
                      errorBuilder: (context, error, stackTrace) {
                        dog("Error: $error");
                        return Center(
                          child: Text('Error: $error'),
                        );
                      },
                      itemBuilder: (context, snapshot) =>
                          ReportAdminListTile(snapshot: snapshot),
                    ),
                    FirebaseDatabaseListView(
                      query: Report.rejectedRef,
                      errorBuilder: (context, error, stackTrace) {
                        dog("Error: $error");
                        return Center(
                          child: Text('Error: $error'),
                        );
                      },
                      itemBuilder: (context, snapshot) => ReportAdminListTile(
                        snapshot: snapshot,
                        from: From.rejeced,
                      ),
                    ),
                    FirebaseDatabaseListView(
                      query: Report.acceptedRef,
                      errorBuilder: (context, error, stackTrace) {
                        dog("Error: $error");
                        return Center(
                          child: Text('Error: $error'),
                        );
                      },
                      itemBuilder: (context, snapshot) => ReportAdminListTile(
                        snapshot: snapshot,
                        from: From.accepted,
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
