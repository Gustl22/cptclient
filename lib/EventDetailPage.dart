import 'package:flutter/material.dart';
import 'package:cptclient/material/PanelSwiper.dart';
import 'package:cptclient/material/DropdownController.dart';

import 'json/member.dart';
import 'material/app/AppBody.dart';
import 'material/app/AppDropdown.dart';
import 'material/app/AppInfoRow.dart';
import 'material/app/AppButton.dart';
import 'material/app/AppListView.dart';
import 'material/app/AppMemberTile.dart';
import 'material/app/AppSlotTile.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'static/navigation.dart' as navi;
import 'static/db.dart' as db;
import 'json/session.dart';
import 'json/slot.dart';
import 'json/location.dart';

class EventDetailPage extends StatefulWidget {
  final Session session;
  final Slot slot;
  final void Function() onUpdate;
  final bool draft;

  EventDetailPage({Key? key, required this.session, required this.slot, required this.onUpdate, required this.draft}) : super(key: key);

  @override
  SlotDetailPageState createState() => SlotDetailPageState();
}

class SlotDetailPageState extends State<EventDetailPage> {
  TextEditingController _ctrlSlotPassword = TextEditingController();
  TextEditingController _ctrlSlotBegin = TextEditingController();
  TextEditingController _ctrlSlotEnd = TextEditingController();
  TextEditingController _ctrlSlotTitle = TextEditingController();

  DropdownController<Location> _ctrlCourseLocation = DropdownController<Location>(items: db.cacheLocations);
  String? _confirmAction;

  DropdownController<Member> _ctrlDropdownMember = DropdownController<Member>(items: db.cacheMembers);

  SlotDetailPageState();

  @override
  void initState() {
    super.initState();

    _applySlot();
    widget.slot.owners = [];
    _getSlotOwners();

    _confirmAction = widget.draft ? 'event_create' : 'event_edit';
  }

  void _deleteSlot() async {
    final response = await http.head(
      Uri.http(navi.server, 'event_delete', {'slot_id': widget.slot.id.toString()}),
      headers: {
        'Token': widget.session.token,
      },
    );

    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete time slot')));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully deleted time slot')));
    widget.onUpdate();
    Navigator.pop(context);
  }

  void _duplicateSlot() {
    Slot _slot = Slot.fromSlot(widget.slot);
    _slot.status = Status.DRAFT;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailPage(
          session: widget.session,
          slot: _slot,
          onUpdate: widget.onUpdate,
          draft: true,
        ),
      ),
    );
  }

  void _applySlot() {
    _ctrlSlotPassword.text = "";
    _ctrlSlotBegin.text = DateFormat("yyyy-MM-dd HH:mm").format(widget.slot.begin);
    _ctrlSlotEnd.text = DateFormat("yyyy-MM-dd HH:mm").format(widget.slot.end);
    _ctrlSlotTitle.text = widget.slot.title;
    _ctrlCourseLocation.value = widget.slot.location;
  }

  void _gatherSlot() {
    widget.slot.pwd = _ctrlSlotPassword.text;
    widget.slot.location = _ctrlCourseLocation.value;
    widget.slot.begin = DateFormat("yyyy-MM-dd HH:mm").parse(_ctrlSlotBegin.text, false);
    widget.slot.end = DateFormat("yyyy-MM-dd HH:mm").parse(_ctrlSlotEnd.text, false);
    widget.slot.title = _ctrlSlotTitle.text;
  }

  void _submitSlot() async {
    _gatherSlot();

    final response = await http.post(
      Uri.http(navi.server, _confirmAction!),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Token': widget.session.token,
      },
      body: json.encode(widget.slot),
    );

    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to modify slot')));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Succeeded to modify slot')));
    widget.onUpdate();
    Navigator.pop(context);
  }

  void _getSlotOwners() async {
    final response = await http.get(
      Uri.http(navi.server, '/event_owner_list', {
        'slot_id': widget.slot.id.toString(),
      }),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Token': widget.session.token,
      },
    );

    if (response.statusCode != 200) {
      return;
    }

    setState(() {
      widget.slot.owners = List<Member>.from(json.decode(utf8.decode(response.bodyBytes)).map((data) => Member.fromJson(data)));
    });
  }

  void _addSlotOwner(Member? member) async {
    if (member == null) return;

    final response = await http.head(
      Uri.http(navi.server, '/event_owner_add', {
        'slot_id': widget.slot.id.toString(),
        'user_id': member.id.toString(),
      }),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Token': widget.session.token,
      },
    );

    if (response.statusCode != 200) {
      return;
    }

    _getSlotOwners();
  }

  void _removeSlotOwner(Member? member) async {
    if (member == null) return;

    final response = await http.head(
      Uri.http(navi.server, '/event_owner_remove', {
        'slot_id': widget.slot.id.toString(),
        'user_id': member.id.toString(),
      }),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Token': widget.session.token,
      },
    );

    if (response.statusCode != 200) {
      return;
    }

    _getSlotOwners();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Slot configuration"),
      ),
      body: AppBody(
        children: [
          if (widget.slot.id != 0)
            Row(
              children: [
                Expanded(
                  child: AppSlotTile(
                    onTap: (slot) => {},
                    slot: widget.slot,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: _duplicateSlot,
                ),
                if (widget.slot.status == Status.DRAFT)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _deleteSlot,
                  ),
              ],
            ),
          //Text(widget.slot.status!.toString()),
          PanelSwiper(panels: [
            Panel("Edit", _buildEditPanel()),
            if (widget.slot.id != 0) Panel("Group Invites", Container()),
            if (widget.slot.id != 0) Panel("Personal Invites", Container()),
            if (widget.slot.id != 0) Panel("Level Invites", Container()),
            if (widget.slot.id != 0) Panel("Owners", _buildOwnerPanel()),
          ]),
        ],
      ),
    );
  }

  Widget _buildEditPanel() {
    return Column(
      children: [
        AppInfoRow(
          info: Text("Title"),
          child: TextField(
            maxLines: 1,
            controller: _ctrlSlotTitle,
          ),
        ),
        AppInfoRow(
          info: Text("Password"),
          child: TextField(
            obscureText: true,
            maxLines: 1,
            controller: _ctrlSlotPassword,
            decoration: InputDecoration(
              hintText: "Reset password (leave empty to keep current)",
            ),
          ),
        ),
        AppInfoRow(
          info: Text("Start Time"),
          child: TextField(
            maxLines: 1,
            controller: _ctrlSlotBegin,
          ),
        ),
        AppInfoRow(
          info: Text("End Time"),
          child: TextField(
            maxLines: 1,
            controller: _ctrlSlotEnd,
          ),
        ),
        AppInfoRow(
          info: Text("Location"),
          child: AppDropdown<Location>(
            hint: Text("Select location"),
            controller: _ctrlCourseLocation,
            builder: (Location location) {
              return Text(location.title);
            },
            onChanged: (Location? location) {
              setState(() {
                _ctrlCourseLocation.value = location;
              });
            },
          ),
        ),
        AppButton(
          text: "Save",
          onPressed: _submitSlot,
        ),
      ],
    );
  }

  Widget _buildOwnerPanel() {
    return Column(
      children: [
        AppInfoRow(
          info: Text("User"),
          child: AppDropdown<Member>(
            controller: _ctrlDropdownMember,
            builder: (Member member) {
              return Text("${member.firstname} ${member.lastname}");
            },
            onChanged: _addSlotOwner,
          ),
          trailing: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () => setState(() => _ctrlDropdownMember.value = null),
          ),
        ),
        AppListView(
          items: widget.slot.owners,
          itemBuilder: (Member member) {
            return Row(
              children: [
                Expanded(
                  child: AppMemberTile(
                    onTap: (Member member) => {},
                    item: member,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeSlotOwner(member),
                ),
              ],
            );
          },
        )
      ],
    );
  }
}