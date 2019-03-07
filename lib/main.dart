import 'package:flutter/material.dart';
import 'package:task_logger_flutter/logList.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Logger',
      theme: ThemeData(
          primarySwatch: Colors.purple,
          dividerColor: Colors.purpleAccent.withOpacity(0.5)),
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
  List<String> _tasks = <String>[];

  @override
  void initState() {
    // temporary code for setting up temp UI
    _tasks..add("Task1")..add("Task2")..add("Task3")..add("Task4");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TaskLogger"),
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) => Divider(
              height: 1.5,
              color: Theme.of(context).dividerColor,
            ),
        itemBuilder: (context, index) {
          return InkWell(
            child: Container(
              margin: const EdgeInsets.all(18.0),
              child: Center(
                child: Text(
                  _tasks[index],
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LogList(title: _tasks[index])));
            },
          );
        },
        itemCount: _tasks.length,
      ),
      bottomNavigationBar: BottomAppBar(
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => null,
        child: Icon(Icons.add),
      ),
    );
  }
}
