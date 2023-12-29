import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class DefaultImageCarouselScaffold extends StatefulWidget {
  const DefaultImageCarouselScaffold({
    super.key,
    this.urls,
    this.index = 0,
    this.widgets,
    this.title,
    this.onPageChanged,
  }) : assert(urls != null || widgets != null);

  final List<String>? urls;
  final int index;
  final String? title;

  final List<Widget>? widgets;

  final void Function(int index)? onPageChanged;

  @override
  State<DefaultImageCarouselScaffold> createState() => _CarouselScreenState();
}

class _CarouselScreenState extends State<DefaultImageCarouselScaffold> {
  late PageController controller;

  late int pageNo;

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: widget.index);
    pageNo = widget.index + 1;
    controller.addListener(func);
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(func);
    controller.dispose();
  }

  func() {
    if (controller.page == null) return;
    if (controller.page == controller.page!.roundToDouble()) {
      setState(() {
        pageNo = controller.page!.round() + 1;
      });
      if (widget.onPageChanged != null) {
        widget.onPageChanged!(pageNo - 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('CarouselScreenCloseButton'),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
        title: Row(
          children: [
            Text(widget.title ?? 'Image Title...'),
            const Spacer(),
            Text('$pageNo/${widget.widgets?.length ?? widget.urls!.length}'),
          ],
        ),
      ),
      body: PageView(
        controller: controller,
        children: widget.widgets ??
            widget.urls!.map((e) => CachedNetworkImage(imageUrl: e)).toList(),
      ),
    );
  }
}
