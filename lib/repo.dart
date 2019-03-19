import 'package:chris_zeitplan/data.dart';
import 'package:chris_zeitplan/day.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Repo {
  static Future<Data> readData() async {
    final prefs = await SharedPreferences.getInstance();

    final pages = prefs.getInt('pages') ?? 100;
    final start = prefs.getString('start') ?? '';
    final end = prefs.getString('end') ?? '';
    final days = prefs.getStringList('days') ?? [];
    final book = prefs.getString('book') ?? "";
    final page = prefs.getString('page') ?? "";

    DateTime startTime = start.isNotEmpty ? DateTime.parse(start) : null;
    DateTime endTime = end.isNotEmpty ? DateTime.parse(end) : null;

    return Data(
        pages: pages,
        start: startTime,
        end: endTime,
        dayStrings: days,
        book: book,
        page: page);
  }

  static saveData(Data data) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setInt('pages', data.pages);

    if (data.start == null) {
      removeKey('start');
    } else {
      prefs.setString('start', data.start.toIso8601String());
    }

    if (data.end == null) {
      removeKey('end');
    } else {
      prefs.setString('end', data.end.toIso8601String());
    }

    if (data.days.length == 0) {
      removeKey('days');
    } else {
      List<String> dayStrings = [];
      data.days.forEach((day) => dayStrings.add(Day.toRepoString(day)));

      prefs.setStringList('days', dayStrings);
    }

    if (data.book == "") {
      removeKey('book');
    } else {
      prefs.setString('book', data.book);
    }

    if (data.page == "") {
      removeKey('page');
    } else {
      prefs.setString('page', data.page);
    }
  }

  static removeKey(String key) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.remove(key);
  }
}
