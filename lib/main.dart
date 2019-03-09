import 'package:chris_zeitplan/data.dart';
import 'package:chris_zeitplan/day.dart';
import 'package:chris_zeitplan/repo.dart';
import 'package:chris_zeitplan/utils.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lesestand',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Data _data = Data.init();
  TextEditingController _controller = TextEditingController();
  TextEditingController _bookController = TextEditingController();
  TextEditingController _pageController = TextEditingController();

  @override
  void initState() {
    Repo.readData().then((data) {
      setState(() {
        this._data = data;
      });

      // Fixer Startzeitpunkt
      if (_data.days.isEmpty) {
        _data.days.add(Day(
            date: DateTime(2019, 3, 1), dayLimitReached: false, extraPages: 0));
        Repo.saveData(_data);
      }

      Day today = Utils.getToday(_data);
      if (today != null && today.extraPages > 0)
        _controller.text = '${today.extraPages}';

      if (data.book != "") _bookController.text = data.book;
      if (data.page != "") _pageController.text = data.page;
    });

    super.initState();
  }

  // Getter & Setter

  int get today {
    return Utils.getNumberOfPagesToRead(_data);
  }

  bool get readToday {
    return Utils.todayRead(_data);
  }

  Color get todayColor {
    if (today == 0) return Colors.black;
    if (today < 0)
      return Colors.green.shade500;
    else
      return Colors.redAccent;
  }

  String get all {
    return '${_data.pages - Utils.getNumberOfReadPages(_data)}';
  }

  // Functions

  _todayButton() {
    if (readToday) {
      Day today = Utils.getToday(_data);
      today.dayLimitReached = false;
    } else {
      Day today = Utils.getToday(_data);
      if (today == null) {
        today = Day(date: DateTime.now(), dayLimitReached: true, extraPages: 0);
        _data.days.add(today);
      } else {
        today.dayLimitReached = true;
      }
    }

    setState(() {
      Repo.saveData(_data);
    });
  }

  _extra(String text) {
    int extraPages = 0;

    if (text.isNotEmpty) {
      extraPages += int.parse(text);
    }

    Day today = Utils.getToday(_data);
    if (today == null) {
      today = Day(
          date: DateTime.now(), dayLimitReached: false, extraPages: extraPages);
      _data.days.add(today);
    } else {
      today.extraPages = extraPages;
    }

    setState(() {
      Repo.saveData(_data);
    });
  }

  _book(String text) {
    _data.book = text;
    Repo.saveData(_data);
  }

  _page(String text) {
    _data.page = text;
    Repo.saveData(_data);
  }

  _reset() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Reset"),
          content:
              new Text("Möchtest du wirklich deinen Lesefortschritt löschen?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(
                "Ja",
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                setState(() {
                  Repo.removeKey('days');
                  _data = Data.init();
                  _controller.clear();
                  _bookController.clear();
                  _pageController.clear();
                  FocusScope.of(context).requestFocus(new FocusNode());
                });
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text(
                "Nein",
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Build Functions

  Widget _buildToday() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Heutiges Ziel',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic),
        ),
        SizedBox(
          height: 10,
        ),
        Column(
          children: <Widget>[
            Text(
              '$today Seiten',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: todayColor, fontWeight: FontWeight.bold, fontSize: 30),
            ),
            SizedBox(
              height: 10,
            ),
            FlatButton(
              color:
                  readToday ? Theme.of(context).primaryColor : Colors.redAccent,
              child: Text(
                readToday
                    ? 'Heute schon gelesen!'
                    : 'Heute noch nicht gelesen!',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: _todayButton,
            )
          ],
        )
      ],
    );
  }

  Widget _buildExtra() {
    return Expanded(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text('Zusätzlich\ngelesen',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold)),
        Container(
          width: 100,
          child: TextField(
            controller: _controller,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
            keyboardType: TextInputType.number,
            onChanged: (text) => _extra(text),
          ),
        )
      ],
    ));
  }

  Widget _buildAll() {
    return Expanded(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          'Gesamt',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          all,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        )
      ],
    ));
  }

  Widget _buildBook() {
    return Column(
      children: <Widget>[
        Text(
          'Aktuelles Buch',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.75,
          child: TextField(
            controller: _bookController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.multiline,
            maxLines: 2,
            onChanged: (text) => _book(text),
          ),
        )
      ],
    );
  }

  Widget _buildPage() {
    return Column(
      children: <Widget>[
        Text(
          'Aktuelle Seite',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold),
        ),
        Container(
          width: 80,
          child: TextField(
            controller: _pageController,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
            keyboardType: TextInputType.number,
            onChanged: (text) => _page(text),
          ),
        )
      ],
    );
  }

  Widget _buildReset() {
    return Row(
      children: <Widget>[
        Expanded(
          child: FlatButton(
            color: Colors.redAccent,
            textColor: Colors.white,
            child: Text('RESET', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: _reset,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              // Colors are easy thanks to Flutter's Colors class.
              Colors.blue.shade50,
              Colors.blue.shade600
            ],
          ),
        ),
        child: SafeArea(
          top: true,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(
                      height: 30,
                    ),
                    _buildToday(),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[_buildExtra(), _buildAll()],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    _buildBook(),
                    SizedBox(
                      height: 20,
                    ),
                    _buildPage(),
                  ],
                ),
                // Positioned(
                //     child: Align(
                //         alignment: FractionalOffset.bottomCenter,
                //         child: _buildReset()))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
