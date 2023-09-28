import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CarouselScreen extends StatefulWidget {
  const CarouselScreen({super.key, this.urls, this.index = 0, this.widgets})
      : assert(urls != null || widgets != null);

  final List<String>? urls;
  final int index;

  final List<Widget>? widgets;

  @override
  State<CarouselScreen> createState() => _CarouselScreenState();
}

class _CarouselScreenState extends State<CarouselScreen> {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
        title: Row(
          children: [
            const Text('Images'),
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
