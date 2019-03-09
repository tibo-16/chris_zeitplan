import 'package:chris_zeitplan/data.dart';
import 'package:chris_zeitplan/day.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Repo {
  static Future<Data> readData() async {
    final prefs = await SharedPreferences.getInstance();

    final days = prefs.getStringList('days') ?? [];
    final book = prefs.getString('book') ?? "";
    final page = prefs.getString('page') ?? "";

    return Data(dayStrings: days, book: book, page: page);
  }

  static saveData(Data data) async {
    final prefs = await SharedPreferences.getInstance();

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
