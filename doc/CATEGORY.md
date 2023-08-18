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
- createdBy

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
