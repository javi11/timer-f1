import 'package:intl/intl.dart';

final DateFormat formatter = DateFormat('EEEE, dd MMMM yyyy');

String dateTitleFormatter(DateTime date) {
  var now = DateTime.now();
  if (now.day == date.day && now.month == date.month && now.year == date.year) {
    return 'Today';
  } else if (now.day == date.day + 1 &&
      now.month == date.month &&
      now.year == date.year) {
    return 'Yesterday';
  }

  return formatter.format(date);
}
