import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ForumChatInput extends StatefulWidget {
  const ForumChatInput({
    super.key,
    required this.category,
    this.requireLogin,
  });

  final String category;
  final Future<void> Function()? requireLogin;

  @override
  State<ForumChatInput> createState() => _ForumChatInputState();
}

class _ForumChatInputState extends State<ForumChatInput> {
  final contentController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  bool isValid = false;
  double? progress;
  bool get inputIsEmpty => contentController.text.isEmpty;
  bool get inputIsNotEmpty => !inputIsEmpty;

  List<String> urls = [];

  bool hasFocus = false;
  bool get inputExpanded => inputIsNotEmpty || hasFocus;
  bool get inputCollapsed => inputIsEmpty && hasFocus == false;

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (progress != null && progress?.isNaN == false) ...[
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
          ],
          if (urls.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 2),
            EditUploads(
              urls: urls,
              onDelete: (url) => setState(
                () => urls.remove(url),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (inputCollapsed && urls.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(T.pleaseFillInTheDetails.tr),
            ),
          Focus(
            child: TextField(
              focusNode: focusNode,
              controller: contentController,
              decoration: InputDecoration(
                hintText: T.inputContentHere.tr,
                prefixIcon: inputCollapsed
                    ? IconButton(
                        onPressed: onUpload,
                        icon: const Icon(Icons.camera_alt),
                      )
                    : null,
                suffixIcon: inputCollapsed
                    ? const IconButton(
                        onPressed: null,
                        icon: Icon(Icons.send),
                      )
                    : null,
              ),
              minLines: inputCollapsed ? 1 : 4,
              maxLines: 6,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              onTap: () {
                dog("onTap: $hasFocus");
                if (my == null) {
                  widget.requireLogin?.call() ?? _showLoginRequiredDialog();
                  focusNode.unfocus();
                  return;
                }
              },
            ),
            onFocusChange: (hasFocus) {
              dog("onFocusChange: $hasFocus");
              setState(() => this.hasFocus = hasFocus);
            },
          ),
          if (inputExpanded) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: onUpload,
                  icon: const Icon(Icons.camera_alt),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () async {
                    final re = await confirm(
                      context: context,
                      title: T.cancel.tr,
                      message: T.doYouWanToCancel.tr,
                    );
                    if (re == false) return;
                    urls.map((url) => StorageService.instance.delete(url));
                    setState(() {
                      contentController.clear();
                      urls = [];
                      hasFocus = false;
                      focusNode.unfocus();
                    });
                  },
                  icon: const Icon(Icons.delete),
                ),
                IconButton(
                  onPressed: contentController.text.isEmpty || progress != null
                      ? null
                      : onSubmitted,
                  icon: const Icon(Icons.send),
                )
              ],
            ),
          ],
        ],
      ),
    );
  }

  onChanged(String value) {
    dog("onChanged: $value");
    // setState(() {});
  }

  onSubmitted([String? value]) async {
    if (contentController.text.length <= 30) {
      toast(context: context, message: T.contentIsTooShort.tr);
      // setState(() {
      //   isValid = true;
      // });
      return;
    }

    final post = await Post.create(
      title: contentController.text.cut(64),
      content: contentController.text,
      category: widget.category,
      urls: urls,
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

  _showLoginRequiredDialog() {
    // TODO trs
    error(context: context, message: "Login is required to use this feature.");
  }

  Future<void> onUpload() async {
    final url = await StorageService.instance.upload(
      context: context,
      progress: (p) => setState(() => progress = p),
      complete: () => setState(() => progress = null),
    );
    if (url == null) return;
    progress = null;
    if (mounted) {
      setState(() => urls.add(url));
    } else {
      StorageService.instance.delete(url);
    }
  }
}
