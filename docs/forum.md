# Forum


## Database strucuture

- `/posts-summary/<category>` is for listing posts in a category list. It will have a summary of the post.
  - It includes `64 letters of title`, `128 letters of content`, `category`, `id`, `uid`, `createdAt`, `order`.
  - it does not include `no of likes`, `no of comments`. It needs to get those information from `/posts`.
- `posts` is for saving all the post data.
- `posts/<category>/comments` is for saving the comments for the post.




/posts/<category>
{ all posts data }

/posts/<category>/comments
{ all comment data }


```


## Coding Guideline

- `category` cannot be changed due to the node structure.