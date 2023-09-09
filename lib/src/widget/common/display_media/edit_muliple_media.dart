import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class EditMultipleMedia extends StatelessWidget {
  const EditMultipleMedia(
      {super.key, required this.urls, required this.onDelete});

  final List<String> urls;
  final Function(String) onDelete;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
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
                      backgroundColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                    ),
                    onPressed: () => onDelete.call(e),
                    icon: const Icon(Icons.delete),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}
