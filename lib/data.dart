import 'package:chris_zeitplan/day.dart';

class Data {
  int pages;

  DateTime start;
  DateTime end;
  List<Day> days = [];
  List<String> dayStrings = [];

  String book = "";
  String page = "";

  Data(
      {this.pages,
      this.start,
      this.end,
      this.dayStrings,
      this.book,
      this.page}) {
    for (String dayString in dayStrings) {
      days.add(Day.fromString(dayString));
    }
  }

  static Data init() {
    return Data(pages: 100, start: null, end: null, dayStrings: []);
  }
}
