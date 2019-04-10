import 'package:flutter/material.dart';
import 'package:task_logger_flutter/db/database.dart';
import 'package:task_logger_flutter/logList.dart';
import 'package:task_logger_flutter/models/taskModel.dart';
import 'package:flutter/rendering.dart';

void main() {
  // Debug setting for viewing Widget bounds (Just like Android's view layout bounds)
  debugPaintSizeEnabled = false;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Logger',
      theme: ThemeData(dividerColor: Colors.purpleAccent.withOpacity(0.5)),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Task> _tasks = <Task>[];
  TextEditingController alertDialogTextController = TextEditingController();

  @override
  void initState() {
    // temporary code for setting up temp UI
  }

  @override
  void dispose() {
    alertDialogTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text("TaskLogger"),
      ),
      body: FutureBuilder<List<Task>>(
        future: DBProvider.db.getAllTasks(),
        builder: (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemBuilder: (context, index) {
                // TODO Need to: snapshot.reversed.toList() , so most recently used Task is on top. This also means I need to update the DateTime of a Task when a Log from that Task is added/changed
                // TODO Need to: add delete functionality to Task list, as well as Log lists
                var currTask = snapshot.data[index];
                return ListTile(
                    title: Text(currTask.title),
                    leading: Text(currTask.id.toString()),
                    trailing: Text(currTask.getFormattedDate()),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                LogList(parentTask: currTask))),
                  onLongPress: () => {},
                );
              },
              itemCount: snapshot.data.length,
            );
          } else {
            return Container(
              child: Text("Nothing to show"),
            );
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewTaskDialog(alertDialogTextController),
        child: Icon(Icons.add),
      ),
    );
  }

  // I think this method, or just showDialog, is returning a Future obj that isn't being handled right, becasue i get constant
  // exceptions after running this method (when creating a new Task)
  _showNewTaskDialog(TextEditingController textController) async {
    await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("New Task"),
          content: TextField(
            controller: textController,
            decoration: InputDecoration(hintText: "Enter a new task here!"),
            maxLines: 1,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text("CANCEL"),
              onPressed: () => _cancelAlertDialog(textController),
            ),
            FlatButton(
              child: const Text("OK"),
              onPressed: () => _insertNewTask(textController),
            )
          ],
        );
      },
    );
  }

  _insertNewTask(TextEditingController textController) {
    if (textController.text.isNotEmpty) {
      Task newTask = Task(textController.text);
      setState(() {
        DBProvider.db.insertTask(newTask);
      });
    }
    textController.clear();
    Navigator.pop(context);
  }

  _cancelAlertDialog(TextEditingController textController) {
    textController.clear();
    Navigator.pop(context);
  }
}
