import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostEditScreen extends StatefulWidget {
  static const String routeName = '/PostCreate';
  const PostEditScreen({super.key, this.category, this.post});

  final String? category;
  final Post? post;

  @override
  State<PostEditScreen> createState() => _PostEditScreenState();
}

class _PostEditScreenState extends State<PostEditScreen> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  Post? _post;
  Post get post => _post!;

  bool get isCreate => widget.post == null;
  bool get isUpdate => !isCreate;

  double? progress;

  @override
  void initState() {
    super.initState();

    if (widget.post != null) {
      _post = widget.post;
    } else {
      _post = Post.fromCategory(widget.category!);
    }

    titleController.text = post.title;
    contentController.text = post.content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isCreate ? T.createPost.tr : T.editPost.tr),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: T.inputTitle.tr, // 'Title',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: T.inputContent.tr, // 'Content',
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
                        Post? newPost;
                        if (isCreate) {
                          newPost = await Post.create(
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
                          ForumService.instance.showPostViewScreen(
                            context: context,
                            post: newPost!,
                          );
                        }
                      },
                      child: Text(
                        isCreate ? T.postCreate.tr : T.postUpdate.tr,
                      ) // 'CREATE' : 'UPDATE'),
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
                onDelete: (url) async {
                  setState(() => post.urls.remove(url));

                  /// If isUpdate then delete the url silently from the server
                  /// sometimes the user delete a url from post/comment but didnt save the post. so the url still exist but the actual image is already deleted
                  /// so we need to update the post to remove the url from the server
                  /// this will prevent error like the url still exist but the image is already deleted
                  if (isUpdate) {
                    await post.update(
                      urls: post.urls,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
