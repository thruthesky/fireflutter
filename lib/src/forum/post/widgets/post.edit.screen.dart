import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostEditScreen extends StatefulWidget {
  static const String routeName = '/PostCreate';
  const PostEditScreen({
    super.key,
    this.category,
    this.post,
    this.group,
    this.displayTitle = true,
  });

  final String? category;
  final Post? post;
  final String? group;

  /// [displayTitle] is to display the title input field on the screen. It is
  /// set to true by default. If you want to hide the title input field, set it
  /// to false. This is useful when you want to create a post without a title.
  ///
  /// This is used in [ForumChatViewScreen] to hide the title input field which
  /// is not necessary for chat.
  final bool? displayTitle;

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

  // for edit we show loading first until the updated post is loaded from the server
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    if (isUpdate) {
      isLoading = true;
      _post = widget.post;
      getPost();
    } else {
      _post = Post.fromCategory(widget.category!);
    }
  }

  /// get the updated post and patch
  getPost() async {
    _post = await post.reload();
    setState(() {
      titleController.text = post.title;
      contentController.text = post.content;
      isLoading = false;
    });
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
              if (isLoading)
                Container(
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                      const SizedBox(height: 16),
                      Text(T.loadingPost.tr),
                    ],
                  ),
                )
              else ...[
                if (widget.displayTitle!) ...[
                  _textTitle(T.title.tr),
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
                ],
                const SizedBox(height: 16),
                _textTitle(T.content.tr),
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
                const SizedBox(height: 8),
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
              ]
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
                  ),
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
