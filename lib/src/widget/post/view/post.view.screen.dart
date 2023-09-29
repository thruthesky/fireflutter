import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostViewScreen extends StatefulWidget {
  const PostViewScreen({
    super.key,
    this.post,
    this.postId,
  });

  final Post? post;
  final String? postId;

  @override
  State<PostViewScreen> createState() => _PostViewScreenState();
}

class _PostViewScreenState extends State<PostViewScreen> {
  Post? _post;
  get post => _post!;

  @override
  void initState() {
    super.initState();

    init();
  }

  init() async {
    // init post
    if (widget.post != null) {
      _post = widget.post;
    } else {
      _post = await PostService.instance.get(widget.postId!);
      setState(() {});
    }

    // listen for update.
    // This is for updating the post when it is edited without flickering.
    Post.doc(post.id).snapshots().listen((event) {
      _post = Post.fromDocumentSnapshot(event);
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: PostViewTitle(post: _post),
        actions:
            PostService.instance.postViewActions(context: context, post: _post),
      ),
      body: _post == null
          ? const CircularProgressIndicator.adaptive()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PostViewTitle(post: _post),

                  // user avatar
                  PostViewMeta(post: _post),

                  PostViewContent(post: _post),

                  YouTube(youtubeId: post.youtubeId, autoPlay: true),

                  const Divider(),
                  if (post.urls.isNotEmpty)
                    ...post.urls.map((e) => DisplayMedia(url: e)).toList(),

                  //
                  PostService.instance.customize.postViewButtonBuilder
                          ?.call(_post) ??
                      PostViewButtons(post: _post, middle: const []),

                  const Divider(),
                  CommentListView(
                    post: post,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                  ),
                ],
              ),
            ),
    );
  }
}
