import 'package:date_format/date_format.dart';

class Log {
  int _parentTaskId;
  int _id;
  String content;
  // When displaying time/date, it can be formatted for UI with helper methods in this class
  String dateTime;
  int deleted;
  int dateDeleted;

  Log(this.content, this._parentTaskId) {
    dateTime = DateTime.now().toString();
    deleted = 0;
  }

  Log._(this._parentTaskId, this._id, this.content, this.dateTime, this.deleted, this.dateDeleted);

  factory Log.fromMap(Map<String, dynamic> json) => Log._(
    json["parentTaskId"],
    json["id"],
    json["content"],
    json["dateTime"],
    json["deleted"],
    json["dateDeleted"]
  );

  Map<String, dynamic> toMap() => {
    "parentTaskId": _parentTaskId,
    "id": id,
    "content": content,
    "dateTime": dateTime,
    "deleted": deleted,
    "dateDeleted": dateDeleted
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