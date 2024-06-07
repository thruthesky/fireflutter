import 'package:cached_network_image/cached_network_image.dart';
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

  bool get isEmpty => contentController.text.isEmpty;
  bool get isNotEmpty => !isEmpty;

  final List<String> urls = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: contentController,
          decoration: InputDecoration(
            hintText: "Input content here...",
            border: const OutlineInputBorder(),
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
          maxLines: 10,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
        ),
        if (isNotEmpty)
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
        Wrap(
          alignment: WrapAlignment.start,
          spacing: 8,
          runSpacing: 8,
          children: urls
              .map(
                (url) => CachedNetworkImage(
                  imageUrl: url,
                  width: 100,
                  height: 100,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  onChanged(String value) {
    print(value);
    setState(() => {});
  }

  onSubmitted([String? value]) async {
    final post = await Post.create(
      title: contentController.text.cut(64),
      content: contentController.text,
      category: widget.category,
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

  onUpload() async {
    final url = await StorageService.instance.upload(context: context);
    if (url == null) return;
    setState(() => urls.add(url));
  }
}
