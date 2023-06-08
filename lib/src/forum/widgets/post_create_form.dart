import 'package:flutter/material.dart';

class PostCreateForm extends StatelessWidget {
  const PostCreateForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Post Create',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.primary)),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Title',
            ),
          ),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Content',
            ),
            minLines: 5,
            maxLines: 10,
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              Spacer(),
              TextButton(
                onPressed: () {},
                child: Text('Create'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
