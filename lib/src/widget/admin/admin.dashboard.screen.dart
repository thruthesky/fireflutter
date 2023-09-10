import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.close,
              color: Theme.of(context).colorScheme.onInverseSurface),
        ),
        title: Text(
          'Admin Dashboard',
          style:
              TextStyle(color: Theme.of(context).colorScheme.onInverseSurface),
        ),
      ),
      body: Column(
        children: [
          TextButton(onPressed: () {}, child: const Text('Users')),
          TextButton(onPressed: () {}, child: const Text('Post')),
          TextButton(onPressed: () {}, child: const Text('Comment')),
          TextButton(onPressed: () {}, child: const Text('Photos')),
          TextButton(
              onPressed: () {
                CategoryService.instance.showListDialog(context);
              },
              child: const Text('Category')),
          TextButton(onPressed: () {}, child: const Text('Report')),
        ],
      ),
    );
  }
}
