import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ForumChatInput extends StatefulWidget {
  const ForumChatInput({
    super.key,
    required this.category,
  });

  final String category;

  @override
  State<ForumChatInput> createState() => _ForumChatInputState();
}

class _ForumChatInputState extends State<ForumChatInput> {
  final contentController = TextEditingController();

  double? progress;
  bool get isEmpty => contentController.text.isEmpty;
  bool get isNotEmpty => !isEmpty;

  final List<String> urls = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (progress != null) LinearProgressIndicator(value: progress),
          const SizedBox(height: 8),
          TextField(
            controller: contentController,
            autofocus: false,
            decoration: InputDecoration(
              hintText: T.inputContentHere.tr,
              prefixIcon: isEmpty
                  ? IconButton(
                      onPressed: onUpload,
                      icon: const Icon(Icons.camera_alt),
                    )
                  : null,
              suffixIcon: isEmpty
                  ? const IconButton(
                      onPressed: null,
                      icon: Icon(Icons.send),
                    )
                  : null,
            ),
            minLines: isEmpty ? 1 : 3,
            maxLines: 4,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          ),
          if (isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: onUpload,
                  icon: const Icon(Icons.camera_alt),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onSubmitted,
                  icon: const Icon(Icons.send),
                )
              ],
            ),
          ],
          const SizedBox(height: 8),
          EditUploads(
              urls: urls, onDelete: (url) => setState(() => urls.remove(url))),
        ],
      ),
    );
  }

  onChanged(String value) {
    setState(() {});
  }

  onSubmitted([String? value]) async {
    final post = await Post.create(
      title: contentController.text.cut(64),
      content: contentController.text,
      category: widget.category,
      urls: urls,
    );
    print(post);

    if (post != null) {
      setState(() {
        urls.clear();
        contentController.clear();
      });
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> onUpload() async {
    final url = await StorageService.instance.upload(
      context: context,
      progress: (p) => setState(() => progress = p),
      complete: () => setState(() => progress = null),
    );
    if (url == null) return;
    progress = null;
    setState(() => urls.add(url));
  }
}
