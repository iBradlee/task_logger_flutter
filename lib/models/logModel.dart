import 'package:date_format/date_format.dart';

class Log {
  int parentTaskId;
  int id;
  String content;
  // When displaying time/date, it can be formatted for UI with helper methods in this class
  String dateTime = DateTime.now().toString();

  Log({this.parentTaskId, this.id, this.content, this.dateTime});

  factory Log.fromMap(Map<String, dynamic> json) => Log(
    parentTaskId: json["parentTaskId"],
    id: json["id"],
    content: json["content"],
    dateTime: json["dateTime"],
  );

  Map<String, dynamic> toMap() => {
    "parentTaskId": parentTaskId,
    "id": id,
    "content": content,
    "dateTime": dateTime,
  };

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