import 'package:date_format/date_format.dart';

class Task {
  int _id;
  String title;
  // When displaying time/date, it can be formatted for UI with helper methods in this class
  String lastUpdatedDateTime;

  Task(this.title) {
    lastUpdatedDateTime = DateTime.now().toString();
  }

  Task._(this._id, this.title, this.lastUpdatedDateTime);

  factory Task.fromMap(Map<String, dynamic> json) => Task._(
    json["id"],
    json["title"],
    json["lastUpdatedDateTime"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "title": title,
    "lastUpdatedDateTime": lastUpdatedDateTime,
  };

  int get id => _id;

  String getFormattedDate() {
    var dateFormat = [mm, '/', dd, '/', yyyy];
    print(lastUpdatedDateTime);
    try {
      DateTime parsedDateTime = DateTime.parse(lastUpdatedDateTime);
      return formatDate(parsedDateTime, dateFormat);
    } catch (Exception) {
    return "date time could not be parsed";
    }
  }

  String getFormattedTime() {
    var timeFormat = [h, ':', nn, am];
    DateTime parsedDateTime = DateTime.parse(lastUpdatedDateTime);
    return formatDate(parsedDateTime, timeFormat);
  }
}