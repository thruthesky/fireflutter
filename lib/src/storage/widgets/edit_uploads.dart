import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// EditUploads
///
/// Note that, it deletes the image from the storage and calls the onDelete
/// callback. But it does not chagne the [urls] list.
class EditUploads extends StatelessWidget {
  final List<String> urls;
  final void Function(String url) onDelete;

  const EditUploads({
    super.key,
    required this.urls,
    required this.onDelete,
  });

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
                  backgroundColor:
                      Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
                ),
                onPressed: () async {
                  try {
                    await StorageService.instance.delete(url);
                    onDelete(url);
                  } on FirebaseException catch (e) {
                    // 'object-not-found' - image was already deleted in the storage
                    // this usually happen when the user the delete an image and it didnt update the urls list on the server and reload/refresh the page then tried to delete again
                    // this will not happen if the user delete the image and it updates the urls list on the server as well after delete
                    if (e.code == 'object-not-found') {
                      onDelete(url);
                    } else {
                      rethrow;
                    }
                  }
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
