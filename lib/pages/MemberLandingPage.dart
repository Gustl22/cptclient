import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:cptclient/material/AppBody.dart';
import 'package:cptclient/material/AppIconButton.dart';

import '../material/AppButton.dart';
import '../material/AppModuleSection.dart';
import '../static/server.dart' as server;
import '../static/navigation.dart' as navi;
import '../json/session.dart';

import 'CalendarPage.dart';
import 'MemberProfilePage.dart';
import 'RankingOverviewPage.dart';
import 'EventOverviewPage.dart';
import 'CourseAvailablePage.dart';
import 'CourseResponsiblePage.dart';

import 'UserManagementPage.dart';
import 'TeamManagementPage.dart';
import 'TermManagementPage.dart';
import 'RankingManagementPage.dart';
import 'EventManagement.dart';
import 'CourseManagementPage.dart';

class MemberLandingPage extends StatelessWidget {
  final Session session;

  MemberLandingPage({Key? key, required this.session}) : super(key: key) {
    if (session.user == null) {
      throw new Exception("The member landing page requires a logged-in user.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Welcome ${session.user!.firstname}"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () => server.refresh(),
          ),
          IconButton(
            icon: Icon(Icons.perm_identity, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MemberProfilePage(session: session))),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => navi.logout(),
          ),
        ],
      ),
      body: AppBody(
        children: <Widget>[
          AppIconButton(
            image: const AssetImage('assets/icons/icon_calendar.png'),
            text: AppLocalizations.of(context)!.labelCalendar,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CalendarPage())),
          ),
          Divider(),
          AppModuleSection(
            image: const AssetImage('assets/icons/icon_inventory.png'),
            text: AppLocalizations.of(context)!.labelInventory,
          ),
          AppButton(
            text: AppLocalizations.of(context)!.pageInventoryPersonal,
            onPressed: () => {},
          ),
          if (session.right!.admin_inventory)
            AppButton(
              text: AppLocalizations.of(context)!.pageInventoryManagement,
              onPressed: () => {},
            ),
          Divider(),
          AppModuleSection(
            image: const AssetImage('assets/icons/icon_course.png'),
            text: AppLocalizations.of(context)!.labelCourse,
          ),
          AppButton(
            text: AppLocalizations.of(context)!.pageCourseAvailable,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CourseAvailablePage(session: session))),
          ),
          AppButton(
            text: AppLocalizations.of(context)!.pageCourseResponsible,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CourseResponsiblePage(session: session))),
          ),
          if (session.right!.admin_courses)
            AppButton(
              text: AppLocalizations.of(context)!.pageCourseManagement,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CourseManagementPage(session: session))),
            ),
          Divider(),
          AppModuleSection(
            image: const AssetImage('assets/icons/icon_event.png'),
            text: AppLocalizations.of(context)!.labelEvent,
          ),
          AppButton(
            text: AppLocalizations.of(context)!.pageEventOwned,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EventOverviewPage(session: session))),
          ),
          if (session.right!.admin_event)
            AppButton(
              text: AppLocalizations.of(context)!.pageEventManagement,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EventManagementPage(session: session))),
            ),
          Divider(),
          AppModuleSection(
            image: const AssetImage('assets/icons/icon_rankings.png'),
            text: AppLocalizations.of(context)!.labelRanking,
          ),
          AppButton(
            text: AppLocalizations.of(context)!.pageRankingPersonal,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RankingOverviewPage(session: session))),
          ),
          if (session.right!.admin_rankings)
            AppButton(
              text: AppLocalizations.of(context)!.pageRankingManagement,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RankingManagementPage(session: session))),
            ),
          Divider(),
          AppModuleSection(
            image: const AssetImage('assets/icons/icon_teams.png'),
            text: AppLocalizations.of(context)!.labelTeam,
          ),
          if (session.right!.admin_teams)
            AppButton(
              text: AppLocalizations.of(context)!.pageTeamManagement,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TeamManagementPage(session: session))),
            ),
          Divider(),
          AppModuleSection(
            image: const AssetImage('assets/icons/icon_membership.png'),
            text: AppLocalizations.of(context)!.labelTerm,
          ),
          if (session.right!.admin_term)
            AppButton(
              text: AppLocalizations.of(context)!.pageTermManagement,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TermManagementPage(session: session))),
            ),
          Divider(),
          AppModuleSection(
            image: const AssetImage('assets/icons/icon_user.png'),
            text: AppLocalizations.of(context)!.labelUser,
          ),
          if (session.right!.admin_users)
            AppButton(
              text: AppLocalizations.of(context)!.pageUserManagement,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UserManagementPage(session: session))),
            ),
        ],
      ),
    );
  }
}
