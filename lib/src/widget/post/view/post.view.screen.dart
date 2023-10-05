import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostViewScreen extends StatefulWidget {
  const PostViewScreen({
    super.key,
    this.post,
    this.postId,
    this.customMiddleContentCrossAxisAlignment = CrossAxisAlignment.start,
    this.headerPadding = const EdgeInsets.only(bottom: sizeSm, left: sizeSm, right: sizeSm),
  });

  final Post? post;
  final String? postId;
  final CrossAxisAlignment customMiddleContentCrossAxisAlignment;
  final EdgeInsetsGeometry headerPadding;

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
        actions: PostService.instance.postViewActions(context: context, post: _post),
      ),
      body: _post == null
          ? const CircularProgressIndicator.adaptive()
          : _post?.deleted == true
              ? Center(child: Text(_post?.reason ?? 'This post has been deleted.'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PostCard(
                        customHeaderBuilder: (context, post) =>
                            PostViewMeta(post: _post, headerPadding: widget.headerPadding),
                        post: _post!,
                        customMainContentBuilder: (context, post) => CarouselView(
                          widgets: [
                            if (post.youtubeId.isNotEmpty) YouTube(youtubeId: post.youtubeId, autoPlay: true),
                            if (post.urls.isNotEmpty) ...post.urls.map((e) => DisplayMedia(url: e)).toList(),
                          ],
                        ),
                        customMiddleContentBuilder: (context, post) => Column(
                          crossAxisAlignment: widget.customMiddleContentCrossAxisAlignment,
                          children: [
                            PostViewTitle(post: _post),
                            PostViewContent(post: _post),
                          ],
                        ),
                        customActionsBuilder: (context, post) =>
                            PostService.instance.customize.postViewButtonBuilder?.call(_post) ??
                            PostViewButtons(post: _post, middle: const []),
                        customFooterBuilder: (context, post) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: sizeSm),
                          child: CommentListView(
                            commentTileTopSpacing: 8,
                            post: post,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                          ),
                        ),
                      ),
                      // PostViewTitle(post: _post),

                      // // user avatar
                      // PostViewMeta(post: _post),

                      // PostViewContent(post: _post),

                      // CarouselView(
                      //   widgets: [
                      //     YouTube(youtubeId: post.youtubeId, autoPlay: true),
                      //     if (post.urls.isNotEmpty) ...post.urls.map((e) => DisplayMedia(url: e)).toList(),
                      //   ],
                      // ),

                      // PostService.instance.customize.postViewButtonBuilder?.call(_post) ??
                      //     PostViewButtons(post: _post, middle: const []),

                      // const Divider(),
                      // CommentListView(
                      //   post: post,
                      //   shrinkWrap: true,
                      //   physics: const NeverScrollableScrollPhysics(),
                      // ),
                    ],
                  ),
                ),
    );
  }
}
