import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

// TODO Read Me
class CarouselView extends StatefulWidget {
  const CarouselView({super.key, required this.urls, this.index = 0});

  final List<String> urls;
  final int index;

  @override
  State<CarouselView> createState() => _CarouselViewState();
}

class _CarouselViewState extends State<CarouselView> {
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
    return SizedBox(
      width: double.infinity,
      height: 400,
      child: Stack(
        children: [
          PageView(
            controller: controller,
            children: widget.urls
                .asMap()
                .entries
                .map((e) => GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        StorageService.instance.showUploads(
                          context,
                          widget.urls,
                          index: e.key,
                        );
                      },
                      child: CachedNetworkImage(
                        imageUrl: e.value,
                        fit: BoxFit.cover,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
