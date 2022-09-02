import 'package:flutter/material.dart';
import '../../../../../fireflutter.dart';

class PostFormController {
  late _PostFormState state;
}

///
class PostForm extends StatefulWidget {
  const PostForm({
    this.category,
    this.subcategory,
    this.categories,
    this.photo,
    this.post,
    required this.onCreate,
    required this.onUpdate,
    this.onCancel,
    this.heightBetween = 10.0,
    this.titleFieldBuilder,
    this.contentFieldBuilder,
    this.submitButtonBuilder,
    this.controller,
    Key? key,
  }) : super(key: key);

  final PostFormController? controller;

  final Post? post;
  final String? category;
  final String? subcategory;

  final Map<String, String>? categories;
  final double heightBetween;

  /// If [photo] is set to true, then there must a photo in the post.
  final bool? photo;

  final Function(Post) onCreate;
  final Function(Post) onUpdate;
  final Function()? onCancel;

  final Widget Function(TextEditingController)? titleFieldBuilder;
  final Widget Function(TextEditingController)? contentFieldBuilder;
  final Widget Function(Function())? submitButtonBuilder;
  @override
  State<PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final title = TextEditingController();
  final content = TextEditingController();
  final documentId = TextEditingController();
  final summary = TextEditingController();

  late List<String> files = [];

  double uploadProgress = 0;
  bool inSubmit = false;

  /// 카테고리(게시판 아이디)가 null 이 아니거나 post.id 가 null 이면, 글 생성.
  bool get isCreate => (widget.post == null || widget.post?.id == '') || (category != '');
  bool get isUpdate => !isCreate;

  /// This is used by custom test also.
  String category = '';

  String? chooseCategory;

  @override
  void initState() {
    super.initState();
    category = widget.category ?? widget.post?.category ?? '';
    setState(() {
      title.text = widget.post?.title ?? '';
      content.text = widget.post?.content ?? '';
      summary.text = widget.post?.summary ?? '';
      files = widget.post?.files ?? [];
    });
    if (widget.controller != null) {
      widget.controller!.state = this;
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleField = widget.titleFieldBuilder != null
        ? widget.titleFieldBuilder!(title)
        : TextField(controller: title);
    final contentField = widget.contentFieldBuilder != null
        ? widget.contentFieldBuilder!(content)
        : TextField(controller: content, minLines: 3, maxLines: 10);

    final submitButton = widget.submitButtonBuilder != null
        ? widget.submitButtonBuilder!(onSubmit)
        : ElevatedButton(
            onPressed: () => onSubmit(),
            child: const Text('SUBMIT'),
            style: ElevatedButton.styleFrom(elevation: 0),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (category == '' && widget.categories != null) ...[
          Text(
            'Choose a category',
            style: Theme.of(context).textTheme.caption,
          ),
          DropdownButton<String>(
            isExpanded: true,
            value: chooseCategory,
            items: widget.categories!.entries
                .map((e) => DropdownMenuItem(child: Text(e.key), value: e.value))
                .toList(),
            onChanged: (v) => setState(() => chooseCategory = v),
          ),
          SizedBox(height: widget.heightBetween),
        ],
        const Text(
          'Title',
          style: TextStyle(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
        titleField,
        SizedBox(height: widget.heightBetween),
        const Text(
          'Content',
          style: TextStyle(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
        contentField,
        SizedBox(height: widget.heightBetween),
        Row(
          children: [
            FileUploadButton(
              child: Icon(
                Icons.camera_alt,
                size: 42,
              ),
              type: 'post',
              onUploaded: (url) {
                files = [...files, url];
                if (mounted)
                  setState(() {
                    uploadProgress = 0;
                  });
              },
              onProgress: (progress) {
                if (mounted) setState(() => uploadProgress = progress);
              },
            ),
            Spacer(),
            if (widget.onCancel != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: TextButton(
                  child: Text(
                    'Cancel',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  onPressed: widget.onCancel,
                ),
              ),
            inSubmit
                ? Container(
                    width: 18,
                    height: 18,
                    margin: const EdgeInsets.only(right: 16),
                    child: CircularProgressIndicator.adaptive(
                      strokeWidth: 2,
                    ),
                  )
                : submitButton
          ],
        ),
        SizedBox(height: 16),
        if (uploadProgress > 0)
          Column(
            children: [
              LinearProgressIndicator(
                value: uploadProgress,
              ),
              SizedBox(height: 8)
            ],
          ),
        ImageListEdit(
          files: files,
          onDeleted: (deletedFileUrl) {
            /// On post (or comment) edit screen, a user may press back button after deleting an image (without saving the post or comment),
            /// Then, the image is deleted but the post(or comment) still has the image and the app is trying to show.
            /// In result, there will be a broken image.
            /// To prevent this senario, when an image is deleted, the app will update the image list immediately.
            if (isUpdate == false) return;
            // TODO delete image from the post
            // FunctionsApi.instance.request(
            //   FunctionName.postUpdate,
            //   data: {'id': widget.post!.id, 'files': files},
            //   addAuth: true,
            // );
          },
        ),
        // if (UserService.instance.user.isAdmin)
        if (User.instance.isAdmin)
          Container(
            margin: EdgeInsets.only(top: 16),
            padding: EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.grey.shade200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Admin menu'),
                Divider(color: Colors.grey),
                Text('Document Id'),
                isCreate
                    ? TextField(controller: documentId)
                    : Text(
                        widget.post!.id,
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                SizedBox(height: 16),
                Text('Summary'),
                TextField(controller: summary),
              ],
            ),
          )
      ],
    );
  }

  Future<Post> onSubmit() async {
    if (widget.photo == true) {
      if (files.length == 0) {
        throw ERROR_NO_PHOTO_ATTACHED;
      }
    }
    setState(() => inSubmit = true);

    if (isCreate) {
      /// TODO: create a post
      // return PostApi.instance
      //     .create(
      //   documentId: documentId.text,
      //   category: category != '' ? category : (chooseCategory ?? ''),
      //   subcategory: widget.subcategory,
      //   title: title.text,
      //   content: content.text,
      //   files: files,
      // )
      //     .then((post) {
      //   widget.onCreate(post);
      //   return post;
      // }).onError((e, stackTrace) {
      //   ffAlert(context, 'ERROR', 'Failed to create a post. $e');
      //   throw e.toString();
      // }).whenComplete(
      //   () {
      //     if (mounted)
      //       setState(() {
      //         inSubmit = false;
      //       });
      //   },
      // );
    } else {
      /// TODO update the post
      /// update
      // return PostApi.instance
      //     .update(
      //   id: widget.post!.id,
      //   title: title.text,
      //   content: content.text,
      //   files: files,
      //   summary: summary.text,
      // )
      //     .then((post) {
      //   widget.onUpdate(post);
      //   return post;
      // }).whenComplete(
      //   () {
      //     if (mounted)
      //       setState(() {
      //         inSubmit = false;
      //       });
      //   },
      // );
    }

    return Future.value({} as Post);
  }
}
