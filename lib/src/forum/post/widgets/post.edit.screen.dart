import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class PostEditScreen extends StatefulWidget {
  static const String routeName = '/PostCreate';
  const PostEditScreen({super.key, this.category, this.post});

  final String? category;
  final PostModel? post;

  @override
  State<PostEditScreen> createState() => _PostEditScreenState();
}

class _PostEditScreenState extends State<PostEditScreen> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  PostModel? _post;
  PostModel get post => _post!;

  bool get isCreate => widget.post == null;

  double? progress;

  @override
  void initState() {
    super.initState();

    if (widget.post != null) {
      _post = widget.post;
    } else {
      _post = PostModel.fromCategory(widget.category!);
    }

    titleController.text = post.title;
    contentController.text = post.content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('글 수정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Title',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Content',
                ),
                minLines: 8,
                maxLines: 10,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                      onPressed: () async {
                        final String? url =
                            await StorageService.instance.upload(
                          context: context,
                          progress: (p) => setState(() => progress = p),
                          complete: () => setState(() => progress = null),
                        );
                        if (url != null) {
                          setState(() {
                            progress = null;
                            post.urls.add(url);
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.camera_alt,
                        size: 32,
                      )),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      PostModel? newPost;
                      if (isCreate) {
                        newPost = await PostModel.create(
                          category: post.category,
                          title: titleController.text,
                          content: contentController.text,
                          urls: post.urls,
                        );
                      } else {
                        newPost = await post.update(
                          title: titleController.text,
                          content: contentController.text,
                          urls: post.urls,
                        );
                      }
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                      if (isCreate) {
                        ForumService.instance
                            .showPostViewScreen(context, post: newPost!);
                      }
                    },
                    child: Text(isCreate ? 'CREATE' : 'UPDATE'),
                  ),
                ],
              ),
              if (progress != null && progress?.isNaN == false)
                LinearProgressIndicator(
                  value: progress,
                ),
              const SizedBox(
                height: 8,
              ),
              EditUploads(
                urls: post.urls,
                onDelete: (url) => setState(() => post.urls.remove(url)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
