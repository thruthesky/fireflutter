import 'package:flutter/material.dart';

class ButtonRow extends StatelessWidget {
  const ButtonRow({
    super.key,
    required this.label1,
    required this.label2,
    this.action1,
    this.action2,
  });

  final String label1;
  final String label2;
  final VoidCallback? action1;
  final VoidCallback? action2;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        // height: ,
        width: constraints.maxWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                action1?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                elevation: 0,
                foregroundColor: Theme.of(context).canvasColor,
                minimumSize: Size(size.width / 3, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              child: Text(label1),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                action2?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).hintColor.withAlpha(25),
                elevation: 0,
                foregroundColor: Theme.of(context).shadowColor,
                minimumSize: Size(size.width / 3, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: Theme.of(context).shadowColor.withAlpha(100),
                  ),
                ),
              ),
              child: Text(label2),
            ),
          ],
        ),
      );
    });
  }
}
