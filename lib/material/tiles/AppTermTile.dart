import 'package:cptclient/json/term.dart';
import 'package:cptclient/material/RoundBox.dart';
import 'package:cptclient/static/datetime.dart';
import 'package:flutter/material.dart';

class AppTermTile extends StatelessWidget {
  final Term term;
  final List<Widget> trailing;

  const AppTermTile({
    super.key,
    required this.term,
    this.trailing = const [],
  });

  @override
  Widget build(BuildContext context) {
    return RoundBox(
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Tooltip(message: "${term.id}", child: Icon(Icons.info)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${term.user!.firstname} ${term.user!.lastname}", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("${term.begin!.fmtDate(context)} - ${term.end!.fmtDate(context)}"),
              ],
            ),
          ),
          ...trailing,
        ],
      )
    );
  }

}
