import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class EditUploads extends StatelessWidget {
  final List<String> urls;
  final void Function(String url) onDelete;

  const EditUploads({
    Key? key,
    required this.urls,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      children: urls.map((url) {
        return Stack(
          children: [
            Image.network(
              url,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: () async {
                  await StorageService.instance.delete(url);
                  onDelete(url);
                },
                icon: const Icon(Icons.delete),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
