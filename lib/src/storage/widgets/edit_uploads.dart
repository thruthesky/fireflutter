import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

/// EditUploads
///
/// Note that, it deletes the image from the storage and calls the onDelete
/// callback. But it does not chagne the [urls] list.
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
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
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
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
                ),
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
