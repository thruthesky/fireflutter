import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/page.essentials/button_row.dart';

class PostCreate extends StatefulWidget {
  const PostCreate({super.key});

  @override
  State<PostCreate> createState() => _PostCreateState();
}

class _PostCreateState extends State<PostCreate> {
  ///
  ///   #Post required fields
  ///   - String id,
  ///   - DateTime createdAt
  ///
  ///   #Post.create() required fields
  ///   - String categoryId,
  ///   - String title,
  ///   - String content,
  ///
  final categoryId = TextEditingController();
  final title = TextEditingController();
  final content = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // CategoryService.instance.showListDialog
    return Dialog(
      elevation: 0,
      alignment: Alignment.center,
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 2,
        child: Padding(
          padding: const EdgeInsets.all(sizeSm),
          child: Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(sizeXs),
                  borderSide: const BorderSide(width: 200),
                ),
              ),
            ),

            /// add image upload button here
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // DropdownButton(items: items, onChanged: onChanged),
                InputFields(controller: categoryId, hintText: 'categ-temp'),
                const SizedBox(height: sizeXs),
                InputFields(controller: title, hintText: 'Title'),
                const SizedBox(height: sizeXs),
                InputFields(
                  controller: content,
                  hintText: 'Write Something...',
                  isContent: true,
                ),
                const SizedBox(height: sizeSm),
                ButtonRow(
                  label1: 'Create',
                  action1: () {
                    Post.create(categoryId: categoryId.text, title: title.text, content: content.text).then(
                      (post) {
                        context.pop();
                        return PostService.instance.showPostViewScreen(context: context, post: post);
                      },
                    );
                  },
                  label2: 'Cancel',
                  action2: () => context.pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InputFields extends StatelessWidget {
  const InputFields({
    super.key,
    required this.controller,
    required this.hintText,
    this.isContent = false,
  });
  final String hintText;
  final TextEditingController controller;
  final bool isContent;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: isContent ? 10 : 1,
      decoration: InputDecoration(
        hintText: hintText,
      ),
    );
  }
}

class PostField extends StatelessWidget {
  const PostField({
    super.key,
    required this.onTap,
  });

  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(sizeLg),
        onTap: onTap,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(
              width: .5,
            ),
            borderRadius: BorderRadius.circular(sizeLg),
          ),
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: sizeSm),
              child: Text("What's on your mind?"),
            ),
          ),
        ),
      ),
    );
  }
}
