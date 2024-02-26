import 'package:intl/intl.dart';

extension FireshipIntExtension on int {
  String get toHex => '0x${toRadixString(16)}';

  String get toShortDate {
    final dt = DateTime.fromMillisecondsSinceEpoch(this);

    /// Returns a string of "yyyy-MM-dd" or "HH:mm:ss"

    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return DateFormat.jm().format(dt);
    } else {
      return DateFormat('yy.MM.dd').format(dt);
    }
  }

  String get toHis {
    final dt = DateTime.fromMillisecondsSinceEpoch(this);

    return DateFormat('HH:mm:ss').format(dt);
  }
}
