import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostEditDialog extends StatefulWidget {
  const PostEditDialog({
    super.key,
    this.categoryId,
    this.post,
  });

  final String? categoryId;
  final Post? post;

  @override
  State<PostEditDialog> createState() => _PostEditDialogState();
}

class _PostEditDialogState extends State<PostEditDialog> {
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();

  late String categoryId = '';
  String categoryName = '';

  List<String> urls = [];
  double? progress;

  bool get isCreate => widget.post == null;
  bool get isUpdate => !isCreate;

  @override
  void initState() {
    super.initState();
    categoryId = widget.categoryId ?? '';
    categoryName = widget.categoryId ?? '@t Post Create';
    if (widget.post != null) {
      title.text = widget.post!.title;
      content.text = widget.post!.content;
      urls = widget.post!.urls;
    }
    if (widget.categoryId != null) {
      CategoryService.instance.get(widget.categoryId!).then((cat) {
        setState(() {
          categoryName = cat!.name;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                      isDense: false,
                      padding: const EdgeInsets.only(left: 12, top: 4, right: 4, bottom: 4),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem(
                          value: '',
                          child: Text('Select Category'),
                        ),
                        ...CategoryService.instance.categoriesOnCreate.entries.map((e) {
                          return DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          );
                        }).toList(),
                      ],
                      value: categoryId,
                      onChanged: (value) {
                        setState(() {
                          categoryId = value ?? '';
                        });
                      }),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: title,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: tr.form.title,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: content,
                minLines: 5,
                maxLines: 8,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: tr.form.content,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      final url = await StorageService.instance.upload(
                        context: context,
                        progress: (p) => setState(() => progress = p),
                        complete: () => setState(() => progress = null),
                      );
                      if (url != null && mounted) {
                        setState(() {
                          urls.add(url);
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.camera_alt,
                      size: 36,
                    ),
                  ),
                  const Spacer(),
                  // Form submit button
                  ElevatedButton(
                    child: Text(isCreate ? tr.form.postCreate : tr.form.postUpdate),
                    onPressed: () async {
                      if (title.text.isEmpty) {
                        return warningSnackbar(context, tr.form.titleRequired);
                      }
                      if (content.text.isEmpty) {
                        return warningSnackbar(context, tr.form.contentRequired);
                      }
                      Post post;
                      if (isCreate) {
                        post = await Post.create(
                          categoryId: categoryId,
                          title: title.text,
                          content: content.text,
                          urls: urls,
                        );
                      } else {
                        await Post.update(
                          postId: widget.post!.id,
                          title: title.text,
                          content: content.text,
                          urls: urls,
                        );
                        post = await Post.get(widget.post!.id);
                      }
                      if (mounted) {
                        Navigator.pop(context);
                        PostService.instance.showPostViewDialog(context, post);
                      }
                    },
                  ),
                ],
              ),
              // uploading pregress bar
              if (progress != null) ...[
                const SizedBox(height: 4),
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 20),
              ],
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                children: urls
                    .map(
                      (e) => Stack(
                        children: [
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                              child: DisplayMedia(url: e),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                              ),
                              onPressed: () async {
                                await StorageService.instance.delete(e);
                                setState(() {
                                  urls.remove(e);
                                });
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
