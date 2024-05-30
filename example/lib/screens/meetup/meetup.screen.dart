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
      body: const DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: 'new'),
                Tab(text: 'recommended'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  MeetupListView(
                    padding: EdgeInsets.all(0),
                  ),
                  Text('Recommended Meetup'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
