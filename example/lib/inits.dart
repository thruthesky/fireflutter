import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:new_app/forums/post/custom.post.edit.dart';
import 'package:new_app/forums/post/custom.post.view.dart';
import 'package:new_app/page.essentials/app.bar.dart';

Future<User?> findUser(String uid) async => await UserService.instance.get(uid);
userInit() {
  UserService.instance.get(myUid ?? '');
}

customizePostInit(String categName) {
  PostService.instance.customize.showPostViewScreen = (context, {post, postId}) async => showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) {
        final dateAgo = dateTimeAgo(post!.createdAt);
        return Scaffold(
          appBar: appBar(
            post.title,
            hasActions: false,
            hasLeading: true,
          ),
          body: FutureBuilder(
            future: findUser(post.uid),
            builder: (context, snapshot) => snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : CustomPostViewScreen(
                    dateAgo: dateAgo,
                    post: post,
                    snapshot: snapshot,
                  ),
          ),
        );
      });
  PostService.instance.customize.showEditScreen = (context, {categoryId, post}) => showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) {
        if (categoryId != '') {
          CategoryService.instance.get(categoryId ?? '').then((value) => categName = value!.name);
        }
        return CustomPostEdit(categName: categName, post: post);
      });
  PostService.instance.uploadFromCamera = false;
  PostService.instance.uploadFromFile = false;

  PostService.instance.customize.postViewButtonBuilder = (post) => const Icon(Icons.add);
}
