import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostViewScreen extends StatefulWidget {
  const PostViewScreen({
    super.key,
    this.post,
    this.postId,
    this.customMiddleContentCrossAxisAlignment = CrossAxisAlignment.start,
    this.headerPadding = const EdgeInsets.all(sizeSm),
    this.onPressBackButton,
  });

  final Post? post;
  final String? postId;
  final CrossAxisAlignment customMiddleContentCrossAxisAlignment;
  final EdgeInsetsGeometry headerPadding;

  final Function(BuildContext, Post)? onPressBackButton;

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
        title: PostViewTitle(padding: const EdgeInsets.only(top: 0), post: _post),
        centerTitle: true,
        actions: PostService.instance.postViewActions(context: context, post: _post),
        leading: widget.onPressBackButton == null
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => widget.onPressBackButton!(context, _post!),
              ),
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
                        color: Theme.of(context).colorScheme.secondary.withAlpha(20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        customHeaderBuilder: (context, post) =>
                            PostViewMeta(post: _post, headerPadding: widget.headerPadding),
                        post: _post!,
                        customMainContentBuilder: (context, post) {
                          if (post.youtubeId.isEmpty && post.urls.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return CarouselView(
                            widgets: [
                              if (post.youtubeId.isNotEmpty) YouTube(youtubeId: post.youtubeId, autoPlay: true),
                              if (post.urls.isNotEmpty) ...post.urls.map((e) => DisplayMedia(url: e)).toList(),
                            ],
                          );
                        },
                        customMiddleContentBuilder: (context, post) => Column(
                          crossAxisAlignment: widget.customMiddleContentCrossAxisAlignment,
                          children: [
                            PostViewTitle(post: _post),
                            PostViewContent(post: _post),
                          ],
                        ),
                        customFooterBuilder: (context, post) => Padding(
                          padding: const EdgeInsets.only(left: sizeSm, top: sizeSm),
                          child: CommentListView(
                            commentTileTopSpacing: 8,
                            post: post,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
