import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/forum/widgets/comments.display.dart';
import 'package:fireflutter/src/forum/widgets/custom.layoutbuilder.dart';
import 'package:fireflutter/src/forum/widgets/likes.counter.dart';
import 'package:fireflutter/src/service/image.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class PostViewScreen extends StatefulWidget {
  const PostViewScreen({super.key, required this.post});
  final PostModel post;

  @override
  State<PostViewScreen> createState() => _PostViewScreenState();
}

class _PostViewScreenState extends State<PostViewScreen> {
  XFile? image;
  bool showTextField = false;
  @override
  Widget build(BuildContext context) {
    return CustomLayoutBuilder(
      builder: (isWideScreen) => Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              //Theres a SafeArea Here wrapping Container
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                height: MediaQuery.of(context).size.height,
                padding: const EdgeInsets.all(10.0),
                child: LayoutGrid(
                  columnSizes: isWideScreen ? List.generate(12, (index) => 1.fr) : List.generate(4, (index) => 1.fr),
                  rowSizes: isWideScreen ? List.generate(4, (index) => auto) : List.generate(2, (index) => auto),
                  gridFit: GridFit.loose,
                  children: [
                    GridPlacement(
                      columnStart: isWideScreen ? 0 : 0,
                      columnSpan: isWideScreen ? 0 : 4,
                      rowStart: isWideScreen ? 0 : 0,
                      rowSpan: isWideScreen ? 0 : 1,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Text(
                                  widget.post.title,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  widget.post.content,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Row(
                              children: [
                                Text(
                                  DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(widget.post.createdAt)),
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const VerticalDivider(),
                                Text(
                                  DateFormat.yMMMEd()
                                      .format(DateTime.fromMillisecondsSinceEpoch(widget.post.createdAt)),
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                          LikesCounter(id: widget.post.id),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              LikeButton(),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    showTextField = !showTextField;
                                  });
                                },
                                icon: const Icon(Icons.create_outlined),
                                label: const Text('Reply'),
                              ),
                            ],
                          ),
                          const Divider(),
                          if (image != null) Image(image: AssetImage(image!.path)),
                          if (showTextField)
                            Row(
                              children: [
                                SizedBox(
                                  width: 32,
                                  child: IconButton(
                                    onPressed: () async {
                                      final re = await ImageService.chooseMedia(context);
                                      if (re == null) return;
                                      final ImagePicker picker = ImagePicker();
                                      image = await picker.pickImage(source: re);
                                      if (image == null) return;
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.camera_alt),
                                  ),
                                ),
                                const Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: TextField(),
                                  ),
                                ),
                                SizedBox(
                                  width: 32,
                                  child: IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.send),
                                  ),
                                ),
                              ],
                            ),
                          Text(
                            'Comments',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                    GridPlacement(
                      columnStart: isWideScreen ? 0 : 0,
                      columnSpan: isWideScreen ? 0 : 4,
                      rowStart: isWideScreen ? 0 : 1,
                      rowSpan: isWideScreen ? 0 : 1,
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CommentsDisplay(
                          parentId: widget.post.id,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
