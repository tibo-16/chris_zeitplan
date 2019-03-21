import 'package:chris_zeitplan/data.dart';
import 'package:chris_zeitplan/day.dart';
import 'package:chris_zeitplan/repo.dart';
import 'package:chris_zeitplan/reset.dart';
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

      // Erster Start?
      if (data.start == null) {
        _data.start = DateTime.now();
        _data.end = DateTime.now().add(Duration(days: 30));
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
      barrierDismissible: false,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: ResetContent(data: _data),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'SPEICHERN',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              textColor: Colors.redAccent,
              onPressed: () {
                setState(() {
                  Repo.saveData(_data);
                  Navigator.pop(context);
                });
              },
            )
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
              color: readToday ? Colors.green.shade500 : Colors.redAccent,
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
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
      ),
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
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
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
          width: 80,
          child: TextField(
            controller: _bookController,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                // Colors are easy thanks to Flutter's Colors class.
                Colors.black,
                Colors.blue.shade400,
                Colors.blue.shade600,
                Colors.black
              ],
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.build),
                color: Colors.grey.shade50,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onPressed: () => _reset(),
              )
            ],
          ),
          body: SafeArea(
            top: true,
            child: GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
              behavior: HitTestBehavior.opaque,
              child: ListView(
                children: <Widget>[
                  SizedBox(
                    height: 80,
                  ),
                  _buildToday(),
                  SizedBox(
                    height: 50,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[_buildExtra(), _buildAll()],
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[_buildBook(), _buildPage()],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
