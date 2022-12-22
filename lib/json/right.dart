// ignore_for_file: non_constant_identifier_names

class Right {
  final bool admin_courses;
  final bool admin_inventory;
  final bool admin_event;
  final bool admin_rankings;
  final bool admin_users;

  Right({
    this.admin_courses = false,
    this.admin_inventory = false,
    this.admin_event = false,
    this.admin_rankings = false,
    this.admin_users = false,
  });

  Right.fromJson(Map<String, dynamic> json)
      : admin_courses = json['admin_courses'],
        admin_inventory = json['admin_inventory'],
        admin_event = json['admin_event'],
        admin_rankings = json['admin_rankings'],
        admin_users = json['admin_users'];

  Map<String, dynamic> toJson() => {
        'admin_courses': admin_courses,
        'admin_inventory': admin_inventory,
        'admin_event': admin_event,
        'admin_rankings': admin_rankings,
        'admin_users': admin_users,
      };
}
