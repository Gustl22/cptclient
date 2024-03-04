import 'package:cptclient/json/session.dart';
import 'package:cptclient/json/team.dart';
import 'package:cptclient/json/user.dart';
import 'package:cptclient/material/AppBody.dart';
import 'package:cptclient/material/panels/SelectionPanel.dart';
import 'package:cptclient/material/tiles/AppTeamTile.dart';
import 'package:cptclient/material/tiles/AppUserTile.dart';
import 'package:cptclient/static/server_team_admin.dart' as api_admin;
import 'package:cptclient/static/server_user_regular.dart' as server;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TeamMemberPage extends StatefulWidget {
  final Session session;
  final Team team;

  TeamMemberPage({super.key, required this.session, required this.team});

  @override
  TeamMemberPageState createState() => TeamMemberPageState();
}

class TeamMemberPageState extends State<TeamMemberPage> {
  List<User> _available = [];
  List<User> _selected = [];

  TeamMemberPageState();

  @override
  void initState() {
    super.initState();
    _update();
  }

  void _update() async {
    List<User> users = await server.user_list(widget.session);
    users.sort();

    List<User> members = await api_admin.team_member_list(widget.session, widget.team.id);
    members.sort();

    setState(() {
      _available = users;
      _selected = members;
    });
  }

  void _addMember(User user) async {
    if (!await api_admin.team_member_add(widget.session, widget.team.id, user.id)) return;
    _update();
  }

  void _removeMember(User user) async {
    if(!await api_admin.team_member_remove(widget.session, widget.team.id, user.id)) return;
    _update();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.pageTeamEdit),
      ),
      body: AppBody(
        children: [
          AppTeamTile(
            team: widget.team,
          ),
          SelectionPanel<User>(
            available: _available,
            selected: _selected,
            onSelect: _addMember,
            onDeselect: _removeMember,
            filter: filterUsers,
            builder: (User user) => AppUserTile(user: user),
          ),
        ],
      ),
    );
  }
}
