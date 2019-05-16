import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:task_logger_flutter/db/database.dart';
import 'package:task_logger_flutter/models/logModel.dart';
import 'package:task_logger_flutter/models/taskModel.dart';

class LogList extends StatefulWidget {
  LogList({this.parentTask});
  Task parentTask;

  @override
  State<StatefulWidget> createState() => _LogListState();
}

class _LogListState extends State<LogList> {
  TextEditingController alertDialogContentTextController =
      TextEditingController();
  TextEditingController alertDialogTimeTextController = TextEditingController();
  bool overrideTime = false;

  @override
  void dispose() {
    alertDialogContentTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text(widget.parentTask.title),
      ),
      body: FutureBuilder<List<Log>>(
        future: DBProvider.db.getAllLogsForTask(widget.parentTask),
        builder: (BuildContext context, AsyncSnapshot<List<Log>> snapshot) {
          if (snapshot.hasData) {
            // Reverse the logListByDate, so that the most recent day is first, for UI purposes
            List<List<Log>> logListByDate =
                _splitListIntoListByDate(snapshot.data).reversed.toList();
            // ListView for the Card Widgets; Each unique date builds a Card Widget,
            // to then put individual Logs for that day inside (inside another ListView)
            return ListView.builder(
              itemCount: logListByDate.length,
              itemBuilder: (context, index) {
                // List of Logs for a single day
                List<Log> singleDayLogs = logListByDate[index];
                // If we're at the last Card widget, we'll set bottomMargin to 8,
                // since we're only doing top,left,right margins for all other Cards
                double bottomMargin = index == logListByDate.length - 1? 8.0 : 0.0;
                // Card Widget to represent a single day's logs, with date in top right
                return Container(
                  margin:  EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0, bottom: bottomMargin),
                  child: Card(
                    child: Column(
                      children: <Widget>[
                        // Date Text, Aligned to right side
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                              margin: EdgeInsets.only(top: 12.0, right: 12.0),
                              child: Text(
                                singleDayLogs[0].getFormattedDate(),
                                style: TextStyle(
                                    fontSize: 14.0,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold),
                              )),
                        ),
                        ListView.builder(
                            // Shrink wrap is needed, since ListView is nested inside another ListView
                            shrinkWrap: true,
                            // Since we don't want to scroll inside Card widget, set physics
                            physics: const NeverScrollableScrollPhysics(),
                            // For each iteration of ListView.builder, a Row to show each Log is created
                            itemCount: singleDayLogs.length,
                            itemBuilder: (context, index) {
                              Log currentLog = singleDayLogs[index];
                              return Container(
                                margin: const EdgeInsets.all(12.0),
                                // Row with individual Log info
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      // Main Log text/content
                                      child: Container(
                                        child: Text(currentLog.content),
                                        margin: EdgeInsets.only(right: 8.0),
                                      ),
                                    ),
                                    // Log time
                                    Text(currentLog.getFormattedTime()),
                                  ],
                                ),
                              );
                            }),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Container(
              child: Text("No Logs to show"),
            );
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewLogDialog(
            alertDialogContentTextController, alertDialogTimeTextController),
        child: Icon(Icons.add),
      ),
    );
  }

  _showNewLogDialog(TextEditingController contentTextController,
      TextEditingController timeTextController) async {
    print("showNewLogDialog has ran");
    await showDialog<String>(
      context: context,
      builder: (context) {
        print("showDialog builder");
        return LogDialog(widget.parentTask);
      },
    );
    // After dialog is finished, set the state of Log List screen, to update UI
    setState((){});
    print("leaving showNewLogDialog");
  }

  List<List<Log>> _splitListIntoListByDate(List<Log> logList) {
    // this might be sorted backwards lul I always froget how compareTo works
    logList.sort((log1, log2) => log1.dateTime.compareTo(log2.dateTime));
    // Get a set of unique dates
    Set<String> dateSet = logList.map((log) => log.getFormattedDate()).toSet();

    List<List<Log>> separatedByDatesLogList = [];

    // For every unique date in dateSet, add all logs with that date to a List. Add listByDate to List of Lists
    // TODO Need to put a cap on how many logs we can sort/show on UI/ load in memory at once, otherwise after 1+ year of logs, we will load up hundreds at once | Might want to start at queing the database for less Logs at a time
    for (var i in dateSet) {
      List<Log> listByDate =
          logList.where((log) => log.getFormattedDate() == i).toList();
      separatedByDatesLogList.add(listByDate);
    }

    return separatedByDatesLogList;
  }

}

// Log Dialog class. Is needed so checkbox widget will be updated when setState is called
class LogDialog extends StatefulWidget {

  LogDialog(this.parentTask);

  Task parentTask;

  @override
  State<StatefulWidget> createState() => _LogDialogState();
}

class _LogDialogState extends State<LogDialog> {

  // THIS IS OVERRIDDEN FOR TESTING PURPOSES; GET RID OF AFTER
  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  TextEditingController contentTextController = TextEditingController();
  DateTime nowDateTime = DateTime.now();
  bool overrideTime = false;


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("New Log"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: contentTextController,
            decoration: InputDecoration(hintText: "Enter a new log here!"),
            maxLines: 1,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
          ),
          // Row for time field. Will have current time, but ability to override
          Row(
            children: <Widget>[
              Text("Override Time "),
              Checkbox(
                value: overrideTime,
                onChanged: (value) => _checkboxOnChanged(value),
              ),
              Expanded(
                // Text showing time which will be logged
                child: Text(formatDate(nowDateTime, [h, ':', nn, am])),
              )
            ],
          )
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: const Text("CANCEL"),
          onPressed: () => _cancelAlertDialog(contentTextController),
        ),
        FlatButton(
          child: const Text("OK"),
          onPressed: () => _insertNewLog(contentTextController),
        )
      ],
    );
  }

  _insertNewLog(TextEditingController textController) {
    if (textController.text.isNotEmpty) {
      Log newLog = Log(textController.text, widget.parentTask.id);
      // Since user can override a Log's time, we'll set the Log's dateTime to whatever the
      // member variable "nowDateTime" is set to (either the current time, or a user-specified time)
      newLog.dateTime = nowDateTime.toString();
      setState(() {
        textController.clear();
        DBProvider.db.insertLog(newLog);
      });
    }
    Navigator.pop(context);
  }

  _cancelAlertDialog(TextEditingController textController) {
    textController.clear();
    Navigator.pop(context);
  }

  _checkboxOnChanged(bool value) {
    // If value (overriding Time) is true
    if (value) {
      // Only show clock to override time if checkbox is not currently checked
      _showTimePicker(context);
      // Try setting state here instead, while gett
    } else {
      // If checkbox is unchecked, reset "nowDateTime", which is used to display time (to be logged) inside AlertDialog
      setState(() {
        nowDateTime = DateTime.now();
        // If value == false, set overrideTime to the same ("value" is value of checkbox for overriding time)
        overrideTime = false;
      });
    }
  }

    _showTimePicker(BuildContext context) async {
    TimeOfDay pickedTime =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (pickedTime != null) {
      // Merge newly created DateTime with user selected TimeOfDay, to create a custom DateTime obj
      DateTime overriddenTime = DateTime(nowDateTime.year, nowDateTime.month,
          nowDateTime.day, pickedTime.hour, pickedTime.minute);
        // If time selected in TimePicker is the same as current time, don't change anything
        if (timeHasChanged(overriddenTime)) {
          setState(() {
            overrideTime = true;
            nowDateTime = overriddenTime;
          });
        }
    }
  }

  bool timeHasChanged(DateTime overriddenTime) {
    if (overriddenTime.hour != nowDateTime.hour ||
        overriddenTime.minute != nowDateTime.minute)
      return true;
  }



}
