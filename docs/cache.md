# Cache

## Overview

The cache is a simple key-value store that is used to store some data that is used frequently. The cache is stored in memory and is not persisted to disk. We use it with `CacheService` class.

## Usage

To cache some data, you can use the `CacheService.cache` function:

```dart
CacheService().cache('key', 'value');
```

To retrieve the cached data, you can use the `CacheService.get` function:

```dart
CacheService().get('key');
```

To remove the cached data, you can use the `CacheService.clean` function:

```dart
CacheService().clean('key');
```

To remove a list of cached data, you can use the `CacheService.cleanList` function:

```dart
CacheService().cleanList(['key1', 'key2']);
```

To clear the entire cache, you can use the `CacheService.clear` function:

```dart
CacheService().clear();
```

## Widgets that use the cache

The following widgets use the cache service:

- [CommentColumnStreamBuilder](../widgets/comment_column_stream_builder.md)
