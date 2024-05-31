import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class MeetupAdminSettingsScreen extends StatefulWidget {
  const MeetupAdminSettingsScreen({
    super.key,
    required this.meetup,
  });

  final Meetup meetup;

  @override
  State<MeetupAdminSettingsScreen> createState() => _MeetupAdminSettingsState();
}

class _MeetupAdminSettingsState extends State<MeetupAdminSettingsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(T.meetupAdminSettings.tr),
      ),
      body: MeetupDoc(
        meetup: widget.meetup,
        builder: (meetup) => Column(
          children: [
            ListTile(
              leading: const Icon(
                Icons.grade,
              ),
              title: Text(
                '${T.recommend.tr} ${meetup.recommendOrder != null && meetup.recommendOrder! > 0 ? "(${meetup.recommendOrder})" : ""}',
              ),
              subtitle: Text(
                T.inputRecommendHint.tr,
              ),
              onTap: () async {
                final text = await input(
                  context: context,
                  initialValue: meetup.recommendOrder != null
                      ? "${meetup.recommendOrder}"
                      : "",
                  title: T.recommend.tr,
                  hintText: T.inputRecommendHint.tr,
                );

                if (text != null) {
                  if (text == "0") {
                    final re = await confirm(
                        context: context,
                        title: T.recommendRemove.tr,
                        message: T.recommendRemoveMessage.tr);

                    if (re != true) return;
                  }
                  await meetup.update(recommendOrder: int.tryParse(text) ?? 0);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
