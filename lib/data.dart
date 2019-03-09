import 'package:chris_zeitplan/day.dart';

class Data {
  int pages = 552;

  List<Day> days = [];
  List<String> dayStrings = [];

  String book = "";
  String page = "";

  Data({this.dayStrings, this.book, this.page}) {
    for (String dayString in dayStrings) {
      days.add(Day.fromString(dayString));
    }
  }

  static Data init() {
    return Data(dayStrings: []);
  }
}
