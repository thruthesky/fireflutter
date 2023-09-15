import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ShareService {
  static ShareService? _instance;

  static ShareService get instance => _instance ??= ShareService._();

  ShareService._();

  showBottomSheet({
    required BuildContext context,
    List<Widget> actions = const [],
  }) {
    showModalBottomSheet(
      context: context,
      barrierColor: Theme.of(context).colorScheme.secondary.withOpacity(.5).withAlpha(110),
      isDismissible: true,
      enableDrag: true,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.96,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        margin: const EdgeInsets.symmetric(horizontal: sizeSm),
        child: Column(
          children: [
            Container(
              height: 4,
              width: 28,
              margin: const EdgeInsets.symmetric(vertical: sizeSm),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Theme.of(context).colorScheme.secondary.withAlpha(80),
              ),
            ),
            const TextField(),
            Expanded(
              child: ListView(
                children: const [
                  Text("Display your followers"),
                ],
              ),
            ),
            Wrap(
              spacing: 16,
              children: actions,
            ),
            const SafeArea(
                child: SizedBox(
              height: sizeMd,
            ))
          ],
        ),
      ),
    );
  }
}
