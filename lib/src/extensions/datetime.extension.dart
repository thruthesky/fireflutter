import 'package:intl/intl.dart';

extension FireshipDateTimeExtension on DateTime {
  String get toShortDate {
    final dt = this;

    /// Returns a string of "yyyy-MM-dd" or "HH:mm:ss"

    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return DateFormat.jm().format(dt);
    } else {
      return DateFormat('yy.MM.dd').format(dt);
    }
  }

  String get toYmd {
    return DateFormat('yyyy-MM-dd').format(this);
  }

  String get toHis {
    return DateFormat('HH:mm:ss').format(this);
  }
}
