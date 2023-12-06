import 'branch.dart';

class Course implements Comparable {
  final int id;
  String key;
  String title;
  bool active;
  bool public;
  Branch? branch;
  int threshold;

  Course(this.id, this.key, this.title, this.active, this.public, this.branch, this.threshold);

  Course.fromVoid() :
    id = 0,
    key = "",
    title = "Course Title",
    active = true,
    public = true,
    branch = null,
    threshold = 0;

  Course.fromCourse(Course course) :
    id = 0,
    key = "",
    title = course.title,
    active = course.active,
    public = course.public,
    branch = course.branch,
    threshold = course.threshold;

  Course.fromJson(Map<String, dynamic> json) :
    id = json['id'],
    key = json['key'],
    title = json['title'],
    active = json['active'],
    public = json['public'],
    branch = Branch.fromJson(json['branch']),
    threshold = json['threshold'];

  Map<String, dynamic> toJson() =>
  {
    'id': id,
    'key': key,
    'title': title,
    'active': active,
    'public': public,
    'branch': branch?.toJson(),
    'threshold': threshold,
  };

  MapEntry<String, String> toEntry() => MapEntry(key, title);

  @override
  bool operator == (other) => other is Course && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  int compareTo(other) {
    return title.compareTo(other.title);
  }
}
