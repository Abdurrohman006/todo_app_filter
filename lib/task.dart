class Task {
  int? id;
  String? title;
  DateTime date;
  String? priority;
  int status = 0;

  Task({
    required this.title,
    required this.date,
    required this.priority,
  });

  Task.withId(
      {this.id,
      required this.title,
      required this.date,
      required this.priority,
      required this.status});

//  Bu funksiya db uchun Task ni Map ko'rinishiga o'zgartiradi
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (id != null) map["id"] = id;

    map["title"] = title;
    map["date"] = date.toIso8601String();
    map["priority"] = priority;
    map["status"] = status;
    return map;
  }

//  Bu funksiya model uchun db dagi Map ni Task ko'rinishiga qaytaradi(o'zgartiradi)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task.withId(
      id: map["id"],
      title: map["title"],
      date: DateTime.parse(map["date"]),
      priority: map["priority"],
      status: map["status"],
    );
  }
}
