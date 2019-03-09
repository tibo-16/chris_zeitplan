import 'package:chris_zeitplan/data.dart';
import 'package:chris_zeitplan/day.dart';

class Utils {
  static int getNumberOfReadPages(Data data) {
    int pages = 0;

    for (Day day in data.days) {
      pages += (day.dayLimitReached) ? 6 : 0;
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
    if (data.days.isEmpty) return 6;

    Day firstDay = data.days.first;
    int dayDifference = DateTime.now().difference(firstDay.date).inDays + 1;

    return dayDifference * 6;
  }

  static bool isToday(DateTime compare) {
    DateTime now = DateTime.now();
    return compare.year == now.year &&
        compare.month == now.month &&
        compare.day == now.day;
  }

  static Day getToday(Data data) {
    if (data.days.isEmpty) return null;

    return data.days.firstWhere((day) => isToday(day.date), orElse: null);
  }

  static bool todayRead(Data data) {
    if (data.days.isEmpty) return false;

    Day today = getToday(data);

    if (today == null) return false;
    if (!today.dayLimitReached) return false;

    return true;
  }
}
