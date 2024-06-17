import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostEditScreen extends StatefulWidget {
  static const String routeName = '/PostCreate';
  const PostEditScreen({
    super.key,
    this.category,
    this.post,
    this.group,
  });

  final String? category;
  final Post? post;
  final String? group;

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

  EdgeInsets get viewInsets => MediaQuery.of(context).viewInsets;

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// user meta
              Row(
                children: [
                  UserAvatar(
                    uid: myUid!,
                    size: 40,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UserDisplayName(
                        uid: myUid!,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Text(
                        DateTime.now().toShortDate,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.w300,
                            ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _textTitle('Title'),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: T.inputTitle.tr, // 'Title',

                  hintStyle: _hintTextStyle(),
                ),
                onTapOutside: (event) => FocusManager.instance.primaryFocus
                    ?.unfocus(), // to remove keyboard on tap outside
                // style: Theme.of(context).textTheme.titleMedium,
                minLines: 1,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _textTitle('Content'),
              TextField(
                controller: contentController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: T.inputContent.tr,
                  hintStyle: _hintTextStyle(),
                ),
                onTapOutside: (event) => FocusManager.instance.primaryFocus
                    ?.unfocus(), // to remove keyboard on tap outside
                style: Theme.of(context).textTheme.bodyMedium,
                minLines: 6,
                maxLines: 15,
              ),
              const SizedBox(height: 16),
              if (progress != null && progress?.isNaN == false)
                LinearProgressIndicator(
                  value: progress,
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
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 8, right: 16, top: 4),
        child: SafeArea(
          child: Padding(
            padding: viewInsets,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton.icon(
                  onPressed: () async {
                    final String? url = await StorageService.instance.upload(
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
                  label: Text(T.addPhoto.tr),
                  icon: Icon(
                    Icons.camera_alt,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                ElevatedButton(
                  // commenting this code because we should not give style inside
                  // we can just do theme in the app projects
                  // style: ButtonStyle(
                  //   elevation: const WidgetStatePropertyAll(0),
                  //   backgroundColor: WidgetStatePropertyAll(
                  //       Theme.of(context).colorScheme.primary),
                  //   foregroundColor: WidgetStatePropertyAll(
                  //       Theme.of(context).colorScheme.onPrimary),
                  // ),
                  onPressed: () async {
                    Post? newPost;
                    if (isCreate) {
                      newPost = await Post.create(
                        category: post.category,
                        title: titleController.text,
                        content: contentController.text,
                        urls: post.urls,
                        group: widget.group,
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
                  ), // 'CREATE' : 'UPDATE'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _hintTextStyle() {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
          wordSpacing: 2,
          letterSpacing: 2,
          color: Theme.of(context).colorScheme.secondary.tone(50),
        );
  }

  _textTitle(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium!.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
