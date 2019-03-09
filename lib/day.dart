class Day {
  DateTime date;
  bool dayLimitReached;
  int extraPages;

  Day({this.date, this.dayLimitReached, this.extraPages});

  static Day fromString(String dayString) {
    List<String> split = dayString.split('#');
    DateTime date = DateTime.parse(split[0]);
    bool dayLimitReached = split[1] == "true" ? true : false;
    int extraPages = int.parse(split[2]);

    return Day(
        date: date, dayLimitReached: dayLimitReached, extraPages: extraPages);
  }

  static String toRepoString(Day day) {
    return '${day.date.toIso8601String()}#${day.dayLimitReached}#${day.extraPages}';
  }
}
