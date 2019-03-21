import 'package:chris_zeitplan/data.dart';
import 'package:chris_zeitplan/utils.dart';
import 'package:flutter/material.dart';

class ResetContent extends StatefulWidget {
  final Data data;

  ResetContent({Key key, this.data}) : super(key: key);

  _ResetContentState createState() => _ResetContentState();
}

class _ResetContentState extends State<ResetContent> {
  TextEditingController _controller = TextEditingController();

  void initState() {
    super.initState();
    _controller.text = '${widget.data.pages}';
  }

  String get startTime {
    return widget.data.start == null
        ? 'Auswählen'
        : Utils.getFormattedDateTime(widget.data.start);
  }

  String get endTime {
    return widget.data.end == null
        ? 'Auswählen'
        : Utils.getFormattedDateTime(widget.data.end);
  }

  _changePages(String text) {
    if (text.isEmpty) return;

    int pages = int.parse(text);

    setState(() {
      widget.data.pages = pages;
    });
  }

  _pickStart() {
    showDatePicker(
            context: context,
            initialDate: widget.data.start,
            firstDate: DateTime(2019, 1, 1),
            lastDate: DateTime.now().add(Duration(days: 1000)))
        .then((start) {
      print(start);

      if (start != null) {
        setState(() {
          widget.data.start = start;
        });
      }
    });
  }

  _pickEnd() {
    showDatePicker(
            context: context,
            initialDate: widget.data.end,
            firstDate: widget.data.start.add(Duration(days: 1)),
            lastDate: DateTime.now().add(Duration(days: 1000)))
        .then((end) {
      print(end);

      if (end != null) {
        setState(() {
          widget.data.end = end;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Gesamtanzahl Seiten:',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
        ),
        TextField(
          controller: _controller,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
          keyboardType: TextInputType.number,
          onChanged: (text) => _changePages(text),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Text(
            'Startdatum:',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
          ),
        ),
        FlatButton(
          child: Text(
            startTime,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          color: Colors.blue.shade600,
          textColor: Colors.white,
          onPressed: () => _pickStart(),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Text(
            'Enddatum:',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
          ),
        ),
        FlatButton(
          child: Text(
            endTime,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          color: Colors.blue.shade600,
          textColor: Colors.white,
          onPressed: () => _pickEnd(),
        )
      ],
    );
  }
}
