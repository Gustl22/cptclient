import 'package:flutter/material.dart';
import 'material/app/AppBody.dart';
import 'material/app/AppIconButton.dart';

import 'static/navigation.dart' as navi;
import 'json/session.dart';

import 'CalendarPage.dart';
import 'MemberProfilePage.dart';
import 'EventOverview.dart';
import 'CourseOverviewPage.dart';

import 'UserOverviewPage.dart';
import 'TeamOverviewPage.dart';
import 'RankingManagement.dart';
import 'EventManagement.dart';

class MemberLandingPage extends StatelessWidget {
  final Session session;

  MemberLandingPage({Key? key, required this.session}) : super(key: key) {
    print("how often");
    if (session.user == null) {
      throw new Exception("The member landing page requires a logged-in user.");
    }
  }

  @override
  Widget build (BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Welcome ${session.user!.firstname}"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () => navi.refresh(),
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
          Wrap(
            alignment: WrapAlignment.center,
            runSpacing: 5.0,
            spacing: 5.0,
            children: [
              AppIconButton(
                icon: Image.asset('icons/icon_calendar.png'),
                text: "Calendar",
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CalendarPage())),
              ),
              AppIconButton(
                icon: Image.asset('icons/icon_course.png'),
                text: "Courses",
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CourseOverviewPage(session: session))),
              ),
              AppIconButton(
                icon: Image.asset('icons/icon_individual.png'),
                text: "Events",
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EventOverview(session: session))),
              ),
            ],
          ),
          Divider(
            height: 30,
            thickness: 5,
            color: Colors.black,
          ),
          Wrap(
            alignment: WrapAlignment.center,
            runSpacing: 5.0,
            spacing: 5.0,
            children: [
              if (session.user!.admin_users) AppIconButton(
                icon: Image.asset('icons/icon_membership.png'),
                text: "Membership",
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UserOverviewPage(session: session))),
              ),
              if (session.user!.admin_users) AppIconButton(
                icon: Image.asset('icons/icon_teams.png'),
                text: "Teams",
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TeamOverviewPage(session: session))),
              ),
              if (session.user!.admin_rankings) AppIconButton(
                icon: Image.asset('icons/icon_rankings.png'),
                text: "Rankings",
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RankingManagementPage(session: session))),
              ),
              if (session.user!.admin_reservations) AppIconButton(
                icon: Image.asset('icons/icon_reservations.png'),
                text: "Reservations",
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ReservationManagementPage(session: session))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}