///
///
String generateCommentSort({String? sortString, int depth = 0}) {
  const int charLength = 3;
  const int blocks = 8;
  sortString = fillBlocksIfEmpty(order: sortString, blocks: blocks);
  if (depth >= blocks) return sortString;
  final List<String> parts = splitBy(inputString: sortString, len: charLength);
  final String base32Str = parts[depth];
  parts[depth] = increaseBase32By(str: base32Str).padLeft(charLength, '0');
  sortString = parts.join('');
  return sortString;
}

String increaseBase32By({required String str, int by = 1}) {
  final num = base32ToNum(str: str) + by;
  return numToBase32(num: num);
}

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

List<String> splitBy({required String inputString, int? len}) {
  // TODO make it in a Config
  const int charLength = 3;
  len ??= charLength;
  List<String> result = [];
  inputString = inputString.trim();

  for (int i = 0; i < inputString.length; i += len) {
    result.add(inputString.substring(i, i + len));
  }
  return result;
}

String fillBlocksIfEmpty({String? order, int blocks = 8}) {
  // TODO make it in a config
  const int charLength = 3;
  if (order == null) {
    order = List.filled(blocks, '0'.padLeft(charLength, '0')).join("");
  } else {
    order = order.trim();
    if (order.isEmpty) {
      order = List.filled(blocks, '0'.padLeft(charLength, '0')).join("");
    }
  }
  return order;
}
