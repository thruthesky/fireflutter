# Category

Categories are used for posts. This can be access by Admin.

## Features

- Admins can do basic create, and update categories functions.

## Model

Category class is the model for categories.
It has:

- id
- name
- description
- createdAt
- updatedAt
- uid
  - This is used for the uid of the creator of the category.

## Security

- All users can read in category.
- Only Admins can write in category.

## Widgets

### Category List View

Category List View can be used to display the list of categories in list tiles.
To use, follow this simple code:

```dart
CategoryListView(),
```

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

### Category List Dialog

Category List Dialog is a full screen dialog that displays the list of categories.
To use, simply follow these code:

```dart
CategoryListDialog(),
```

The onTapCategory parameter can be used to modify the action if the user tapped the category. By dafault, it will go to the list of posts.

```dart
ElevatedButton(
  onPressed: () => CategoryService.instance.showListDialog(
    context,
    onTapCategory: (category) =>
      showGeneralDialog(
        context: context,
        pageBuilder: (context, _, __) {
          return CategoryListDialog(
            onTapCategory: (category) {
              CategoryService.instance.showUpdateDialog(context, category);
            },
          );
        },
      ),
    ),
  child: const Text('Categories'),
),
```

See [Displaying Category List using CategoryService](#displaying-category-list-using-categoryservice) to check how to display the list using service.

### Category Create Dialog

Category Create Dialog is for a dialog that will ask for a category name and create the category.

Cancel Text Button will simply close the dialog by default.

To use, follow this code:

```dart
IconButton(
  icon: const Icon(Icons.add),
  onPressed: () {
    CategoryService.instance.showCreateCategoryDialog(
      context,
      success: (val) {
        Navigator.pop(context);
      },
    );
  },
),
```

## Category Service Usage

### Displaying Category List using CategoryService

This is an example of applying a Categories list that will open the update category dialog
for every category on tap:

```dart
ElevatedButton(
  onPressed: () => CategoryService.instance.showListDialog(
    context,
    onTapCategory: (category) =>
        CategoryService.instance.showUpdateDialog(context, category),
  ),
  child: const Text('Categories'),
),
```

### Updating the category details

To update the category details use [updateCategory] in the service.

Check the sample code:

```dart
() {
    Map<String, dynamic> updatedCategory = {
        'name': categoryName.text,
        'description': description.text,
    };
    CategoryService.instance.updateCategory(widget.category.id, updatedCategory);
},
```

## Tests

Testing Category Service
