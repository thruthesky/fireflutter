/// [sortCharLenth] is the length of each block in the sort string.
/// Each block is a base32 number. If it is 2, then it supports up to
/// 32^2 = 1024 comments in that depth.
/// If it is 3, then it supports up to 32^4 = 1,048,576 comments in that depth.
/// If the number of comments exceeds, then it will start with 0.
const int sortCharLenth = 4;

/// [sortBlocks] is the number of blocks in the sort string. If it's 10,
/// It will support 10 depth of comments.
/// if the [sortCharLength] is 4, then it will support up to 1,048,576 comments
/// on each depth.
const int sortBlocks = 10;

/// Return a string which order the comments
///
/// [sortString] is the sort string of the comment. If it is null, it will be
/// generated. If it is not null, it will be increased by 1 on its depth.
/// [sortString] can be set to null for the first comment of a post.
///
/// [depth] is the depth of the comment. It starts with 0.
///
///
/// @param sortString a sort string of last sibling comment. If the sibiling comments are not exist, then it must be the parents sort string.
/// If there is parent(or parentId) of the comment, then return the sort of last first-level-comment's sort.
/// @param depth parents depth.
/// @returns
String generateCommentSort({String? sortString, int depth = 0}) {
  //
  sortString = fillBlocksIfEmpty(order: sortString, blocks: sortBlocks);
  // exceed the limit of blocks?
  if (depth >= sortBlocks) return sortString;
  final List<String> parts = splitBy(inputString: sortString, len: sortCharLenth);
  final String base32Str = parts[depth];
  parts[depth] = increaseBase32By(str: base32Str).padLeft(sortCharLenth, '0');
  sortString = parts.join('');
  return sortString;
}

String increaseBase32By({required String str, int by = 1}) {
  final num = base32ToNum(str: str) + by;
  return numToBase32(num: num);
}

/// Returns a string which order the comments
///
/// @param str string of base32
/// @returns number
int base32ToNum({required String str}) {
  if (str.isEmpty) return 0;
  const base32Chars = '0123456789ABCDEFGHIJKLMNOPQRSTUV';
  const base = 32;

  // Convert base32 string to decimal number
  int num = 0;
  str = str.toUpperCase().trim();
  for (int i = 0; i < str.length; i++) {
    final char = str[i];
    final digit = base32Chars.indexOf(char);
    num = num * base + digit;
  }
  return num;
}

/// Returns a string which order the comments
///
/// @param str string of base32
/// @returns number
String numToBase32({int? num}) {
  if (num == null) return '0';
  const base32Chars = '0123456789ABCDEFGHIJKLMNOPQRSTUV';
  const base = 32;

  // Convert decimal number to base32 string
  String result = '';
  while (num! > 0) {
    final digit = num % base;
    result = base32Chars[digit] + result;
    num = (num / base).floor();
  }
  return result;
}

/// Returns a string which order the comments
///
/// @param inputString input string
/// @param len length of each part
/// @returns array of string
List<String> splitBy({required String inputString, int? len}) {
  len ??= sortCharLenth;
  List<String> result = [];
  inputString = inputString.trim();

  for (int i = 0; i < inputString.length; i += len) {
    result.add(inputString.substring(i, i + len));
  }
  return result;
}

/// Fills the sort string with 0 if it is empty.
///
/// [order] is the sort stirng. if it has value, then it will be returned as it
/// is. If it is null, then it will be filled with 0.
String fillBlocksIfEmpty({String? order, int blocks = 8}) {
  return order ?? List.filled(blocks, ''.padLeft(sortCharLenth, '0')).join("");
}
