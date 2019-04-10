import 'package:date_format/date_format.dart';

class Log {
  int _parentTaskId;
  int _id;
  String content;
  // When displaying time/date, it can be formatted for UI with helper methods in this class
  String dateTime;

  Log(this.content, this._parentTaskId) {
    dateTime = DateTime.now().toString();
  }

  Log._(this._parentTaskId, this._id, this.content, this.dateTime);

  factory Log.fromMap(Map<String, dynamic> json) => Log._(
    json["parentTaskId"],
    json["id"],
    json["content"],
    json["dateTime"],
  );

  Map<String, dynamic> toMap() => {
    "parentTaskId": _parentTaskId,
    "id": id,
    "content": content,
    "dateTime": dateTime,
  };

  int get parentTaskId => _parentTaskId;

  int get id => _id;

  String getFormattedDate() {
    var dateFormat = [mm, '/', dd, '/', yyyy];
    DateTime parsedDateTime = DateTime.parse(dateTime);
    return formatDate(parsedDateTime, dateFormat);
  }

  String getFormattedTime() {
    var timeFormat = [h, ':', nn, am];
    DateTime parsedDateTime = DateTime.parse(dateTime);
    return formatDate(parsedDateTime, timeFormat);
  }
}