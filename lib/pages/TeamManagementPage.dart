import 'package:flutter/material.dart';
import 'package:cptclient/material/AppBody.dart';
import 'package:cptclient/material/AppButton.dart';
import 'package:cptclient/material/AppListView.dart';
import 'package:cptclient/material/tiles/AppTeamTile.dart';

import 'TeamAdminPage.dart';

import '../static/serverTeamAdmin.dart' as server;
import '../json/session.dart';
import '../json/team.dart';

class TeamManagementPage extends StatefulWidget {
  final Session session;

  TeamManagementPage({Key? key, required this.session}) : super(key: key);

  @override
  TeamManagementPageState createState() => TeamManagementPageState();
}

class TeamManagementPageState extends State<TeamManagementPage> {
  List<Team> _teams = [];

  TeamManagementPageState();

  @override
  void initState() {
    super.initState();
    _update();
  }

  void _update() {
    _getTeamList();
  }

  Future<void> _getTeamList() async {
    List<Team> teams = await server.team_list(widget.session);

    setState(() {
      _teams = teams;
    });
  }

  Future<void> _selectTeam(Team team, bool isDraft) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamAdminPage(
          session: widget.session,
          team: team,
          isDraft: isDraft,
        ),
      ),
    );

    _update();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Team Overview"),
      ),
      body: AppBody(
        children: <Widget>[
          AppButton(
            leading: Icon(Icons.add),
            text: "New team",
            onPressed: () => _selectTeam(Team.fromVoid(), true),
          ),
          AppListView(
            items: _teams,
            itemBuilder: (Team team) {
              return InkWell(
                onTap: () => _selectTeam(team, false),
                child: AppTeamTile(
                  team: team,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
