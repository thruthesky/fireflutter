# Comment

## Features

- Create comments under posts

## Model

Comment Class is the model for comments.
It has:

- id
- postId
- content
- uid
  - the uid of the creator of the comment
- files
  - the list of file URLs.
- createdAt
- updatedAt
- likes
- deleted

## Widgets

### CommentListView

A List View of Comments on top of FirestoreListView.

### Comment Box

A form for commenting for a post.
