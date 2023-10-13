import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/page.essentials/app.bar.dart';
import 'package:new_app/page.essentials/button_row.dart';

class CustomPostEdit extends StatefulWidget {
  const CustomPostEdit({
    super.key,
    required this.categName,
    required this.post,
  });
  final Post? post;
  final String categName;

  @override
  State<CustomPostEdit> createState() => _CustomPostEditState();
}

class _CustomPostEditState extends State<CustomPostEdit> {
  final title = TextEditingController();
  final content = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(widget.categName, hasLeading: true, hasActions: false),
      body: Padding(
        padding: const EdgeInsets.all(sizeSm),
        child: Column(
          children: [
            txtFieldBuilder('Title'),
            const SizedBox(height: sizeSm),
            txtFieldBuilder('Content', maxLines: 5),
            const SizedBox(height: sizeSm),
            _buttons(),
          ],
        ),
      ),
    );
  }

  Row _buttons() {
    return Row(
      children: [
        const SizedBox(width: sizeXs),
        IconButton(
          onPressed: () {},
          icon: const FaIcon(FontAwesomeIcons.cameraRetro),
        ),
        const SizedBox(
          width: sizeSm,
        ),
        Expanded(
          child: ButtonRow(
            label1: 'Update',
            label2: 'Cancel',
            action2: () => context.pop(),
          ),
        ),
      ],
    );
  }

  TextField txtFieldBuilder(String label, {int? maxLines = 1}) {
    return TextField(
      decoration: InputDecoration(
        label: Text(label),
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
    );
  }
}
