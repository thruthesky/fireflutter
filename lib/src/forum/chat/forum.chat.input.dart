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
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  double? progress;
  bool get isEmpty => titleController.text.isEmpty;
  bool get isNotEmpty => !isEmpty;

  final List<String> urls = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (progress != null) LinearProgressIndicator(value: progress),
        const SizedBox(height: 8),
        // Title
        TextField(
          controller: titleController,
          decoration: InputDecoration(
            hintText: "Input title here...",
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
          minLines: 1,
          maxLines: 1,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
        ),
        const SizedBox(height: 8),

        if (isNotEmpty) ...[
          // Content
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
            maxLines: 4,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          ),
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

        Wrap(
          alignment: WrapAlignment.start,
          spacing: 8,
          runSpacing: 8,
          children: urls
              .map(
                (url) => SizedBox(
                  height: 100,
                  width: 100,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: CachedNetworkImage(
                          imageUrl: url,
                        ),
                      ),
                      Align(
                        alignment: const Alignment(1.5, -1.5),
                        child: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            dog('$url is deleted');
                            StorageService.instance.delete(url);
                            urls.remove(url);
                            setState(() {});
                          },
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  onChanged(String value) {
    setState(() {});
  }

  onSubmitted([String? value]) async {
    final post = await Post.create(
      title: titleController.text.cut(64),
      content: contentController.text,
      category: widget.category,
      urls: urls,
    );
    print(post);

    if (post != null) {
      setState(() {
        urls.clear();
        contentController.clear();
        titleController.clear();
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
