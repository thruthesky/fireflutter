# Category

Categories are used for posts. This can be access by Admin.

## Features

- Admins can do basic create, update, or delete categories functions.

## Model

Category class is the model for categories.
It has:

- id
- name
- description
- createdAt

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
