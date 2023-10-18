# Table of Contents  


<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [Table of Contents](#table-of-contents)
- [Category](#category)
  - [Overview](#overview)
  - [CategoryServices](#categoryservices)
    - [Category Create Screen](#category-create-screen)
    - [Category List View](#category-list-view)
    - [Category Edit Screen](#category-edit-screen)

<!-- /code_chunk_output -->



# Category

## Overview
Categories are managed by Admins.
## CategoryServices
`CategoryServices` is responsible for managing categories on app. You can create or limit users on which categories they can use. See below for more

```dart
final service = CategoryService.instance;
// initialize Category feature
service.init();

// get category from Id
service.get(categoryId); // returns Future<Category?>

// open category create dialog
// [success] is required, it is a type if Function()
service.showCreateDialog(
  context, success: () => toast(title: 'Successful', message: 'Category Created'),
);
```

### Category Create Screen

`CategoryCreateScreen` is used for creating a dialog. To do this follow the sample code below;

```dart 
CategoryService.instance.showCreateDialog(context, success: (cat) => debugPrint('$cat'));
```
or use this
```dart
showDialog(
  context: context,
  builder: (cnx) => CategoryCreateScreen(
    success: (cat) => debugPrint('$cat'),
  ),
),
```



### Category List View

`CategoryListView` can be used to display the list of categories in list tiles.
To use, follow this simple code:

```dart
showDialog(
  context: context,
  builder: (cnx) => const Dialog(
    child: CategoryListView(),
  ),
),
```

### Category Edit Screen

Sometimes we want to modify the action when the user tapped the
category in the list view. For example, showing Update Category dialog
to an admin after tapping.

This is an example of list view that opens the editing dialog for the category:

```dart
CategoryListView(
  onTap: (category) {
    CategoryService.instance.showUpdateDialog(context, category);
  },
),
```