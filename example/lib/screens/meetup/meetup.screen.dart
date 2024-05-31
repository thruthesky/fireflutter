import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class MeetupScreen extends StatefulWidget {
  static const String routeName = '/Meetup';
  const MeetupScreen({super.key});

  @override
  State<MeetupScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MeetupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meetup'),
        actions: const [
          MeetupCreateButton(),
          SizedBox(width: 24),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'new'),
                Tab(text: 'recommended'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  const MeetupListView(
                    padding: EdgeInsets.all(0),
                  ),
                  MeetupListView(
                    padding: const EdgeInsets.all(0),
                    query: Meetup.col
                        .where('hasPhoto', isEqualTo: true)
                        .orderBy('recommendOrder', descending: true),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
