
import 'package:flutter/material.dart';
import 'package:task_logger_flutter/globals.dart' as globals;

class LogList extends StatefulWidget {

  LogList({this.title});
  String title;

  @override
  State<StatefulWidget> createState() => _LogListState();
}

class _LogListState extends State<LogList> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(globals.APP_TITLE),
      ),
      body: Container(
        child: Center(
          child: Text("${widget.title}"),
        ),
      ),
    );
  }

}