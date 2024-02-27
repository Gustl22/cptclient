// ignore_for_file: non_constant_identifier_names

import 'package:cptclient/json/right.dart';
import 'package:diacritic/diacritic.dart';

class Team implements Comparable {
  final int id;
  String name;
  String description;
  Right? right;

  Team(this.id, this.name, this.description);

  Team.fromVoid()
      : id = 0,
        name = "",
        description = "",
        right = Right();

  Team.fromTeam(Team team)
      : id = 0,
        name = "${team.name} (Copy)",
        description = team.description,
        right = (team.right == null) ? null : Right.fromRight(team.right!);

  Team.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        description = json['description'],
        right = (json['right'] == null) ? null : Right.fromJson(json['right']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'right': right?.toJson(),
      };

  @override
  bool operator ==(other) => other is Team && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  int compareTo(other) {
    return removeDiacritics(name).compareTo(removeDiacritics(other.name));
  }
}

List<Team> filterTeams(List<Team> teams, String filter) {
  List<Team> filtered = teams.where((Team team) {
    Set<String> fragments = filter.toLowerCase().split(' ').toSet();
    List<String> searchspace = [team.name, team.description];

    for (var fragment in fragments) {
      bool matchedAny = false;
      for (var space in searchspace) {
        matchedAny = matchedAny || space.toLowerCase().contains(fragment);
      }
      if (!matchedAny) return false;
    }

    return true;
  }).toList();

  return filtered;
}