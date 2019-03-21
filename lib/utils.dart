import 'package:chris_zeitplan/data.dart';
import 'package:chris_zeitplan/day.dart';

class Utils {
  static int _getDayLimit(Data data) {
    if (data.start == null || data.end == null)
      return 6;
    else {
      int days = data.end.difference(data.start).inDays;
      return (data.pages / days).round();
    }
  }

  static int getNumberOfReadPages(Data data) {
    int pages = 0;

    for (Day day in data.days) {
      pages += (day.dayLimitReached) ? _getDayLimit(data) : 0;
      pages += day.extraPages;
    }

    return pages;
  }

  static int getNumberOfPagesToRead(Data data) {
    int should = _getNumberOfPagesWhichShouldHaveBeenRead(data);
    int read = getNumberOfReadPages(data);

    return should - read;
  }

  static int _getNumberOfPagesWhichShouldHaveBeenRead(Data data) {
    if (data.start == null) return _getDayLimit(data);

    int dayDifference = DateTime.now().difference(data.start).inDays + 1;

    return dayDifference * _getDayLimit(data);
  }

  static bool isToday(DateTime compare) {
    DateTime now = DateTime.now();
    return compare.year == now.year &&
        compare.month == now.month &&
        compare.day == now.day;
  }

  static Day getToday(Data data) {
    if (data.days.isEmpty) return null;

    List<Day> possibleToday =
        data.days.where((day) => isToday(day.date)).toList();
    if (possibleToday.isEmpty)
      return null;
    else
      return possibleToday.first;
  }

  static bool todayRead(Data data) {
    if (data.days.isEmpty) return false;

    Day today = getToday(data);

    if (today == null) return false;
    if (!today.dayLimitReached) return false;

    return true;
  }

  static String getFormattedDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
