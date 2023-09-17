import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CarouselScreen extends StatefulWidget {
  const CarouselScreen({super.key, required this.urls});

  final List<String> urls;

  @override
  State<CarouselScreen> createState() => _CarouselScreenState();
}

class _CarouselScreenState extends State<CarouselScreen> {
  final controller = PageController();

  int pageNo = 1;

  @override
  void initState() {
    super.initState();

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
            Text('$pageNo/${widget.urls.length}'),
          ],
        ),
      ),
      body: PageView(
        controller: controller,
        children: widget.urls.map((e) => CachedNetworkImage(imageUrl: e)).toList(),
      ),
    );
  }
}
