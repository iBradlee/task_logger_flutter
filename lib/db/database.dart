import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:task_logger_flutter/models/logModel.dart';
import 'package:task_logger_flutter/models/taskModel.dart';

class DBProvider {
  // Private constructor
  DBProvider._();

  // Singleton
  static final DBProvider db = DBProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null) {
      // If not null, just return already instantiated database
      return _database;
    }
    else {
      // Else instantiate database
      _database = await initDB();
      return _database;
    }
  }

  // Get the path for storing the database and create the desired tables
  Future<Database> initDB() async {
    // Path for storing iOS/Android documents
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    // Using base document path, amend "TestDB.db" to finish the path the DB will use
    String path = join(documentsDirectory.path, "TestDB.db");
    return await openDatabase(path, version: 2, onOpen: (db) {},
    onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE ${TaskDbSchema.TABLE_NAME} ("
        "${TaskDbSchema.COL_ID} INTEGER PRIMARY KEY,"
        "${TaskDbSchema.COL_TITLE} TEXT,"
        "${TaskDbSchema.COL_LAST_DATETIME} TEXT"
        ")");
      await db.execute("CREATE TABLE ${LogDbSchema.TABLE_NAME}("
          "${LogDbSchema.COL_ID} INTEGER PRIMARY KEY,"
          "${LogDbSchema.COL_PARENT_ID} INTEGER,"
          "${LogDbSchema.COL_CONTENT} TEXT,"
          "${LogDbSchema.COL_DATETIME} TEXT"
          ")");
    });
  }

  // Task DB queries
  insertTask(Task task) async {
    final db = await database;
    db.insert(TaskDbSchema.TABLE_NAME, task.toMap());
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    var result = await db.query(TaskDbSchema.TABLE_NAME);
    // If result (query) isn't empty, convert stored maps to Tasks, and return list; if is empty, return empty list
    List<Task> taskList = result.isNotEmpty ? result.map((map) => Task.fromMap(map)).toList() : [];
    return taskList;
  }

  updateTask(Task task) async {
    final db = await database;
    db.update(TaskDbSchema.TABLE_NAME, task.toMap(), where: "id = ?", whereArgs: [task.id]);
  }

  // Will need to also delete all logs with appropriate parentTaskId, when a task is deleted
  deleteTask(Task task) async {
    final db = await database;
    db.delete(TaskDbSchema.TABLE_NAME, where: "${TaskDbSchema.COL_ID} = ?", whereArgs: [task.id]);
  }

  /// Must enter string "delete all Tasks" as argument, in order to actually delete;
  /// this is just a preventative measure
  deleteAllTasks(String confirmationString) async {
    if (confirmationString.toLowerCase() == "delete all tasks") {
      final db = await database;
      db.delete(TaskDbSchema.TABLE_NAME);
    }
    else {
      print('Confirmation string not entered correctly. It must be: "delete all tasks');
    }
  }

  // Log DB queries
  insertLog(Log log) async {
    final db = await database;
    db.insert(LogDbSchema.TABLE_NAME, log.toMap());
  }

  Future<List<Log>> getAllLogsForTask(Task task) async {
    print("getAllLogsForTask() has ran");
    final db = await database;
    var result = await db.query(LogDbSchema.TABLE_NAME, where: "${LogDbSchema.COL_PARENT_ID} = ?", whereArgs: [task.id]);
    List<Log> logList = result.isNotEmpty ? result.map((map) => Log.fromMap(map)).toList() : [];
    return logList;
  }

  updateLog(Log log) async {
    final db = await database;
    db.update(LogDbSchema.TABLE_NAME, log.toMap(), where: "${LogDbSchema.COL_ID} = ?", whereArgs: [log.id]);
  }

  deleteLog(Log log) async {
    final db = await database;
    db.delete(LogDbSchema.TABLE_NAME, where: "${LogDbSchema.COL_ID} = ?", whereArgs: [log.id]);
  }

  deleteAllLogsFromTask(Task task) async {
    final db = await database;
    db.delete(LogDbSchema.TABLE_NAME, where: "${LogDbSchema.COL_PARENT_ID} = ?", whereArgs: [task.id]);
  }

}

class TaskDbSchema {
  static const String TABLE_NAME = "Task";
  static const String COL_ID = "id";
  static const String COL_TITLE = "title";
  static const String COL_LAST_DATETIME = "lastUpdatedDateTime";
}

class LogDbSchema {
  static const String TABLE_NAME = "Log";
  static const String COL_ID = "id";
  static const String COL_PARENT_ID = "parentTaskId";
  static const String COL_CONTENT = "content";
  static const String COL_DATETIME = "dateTime";
}

