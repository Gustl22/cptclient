import 'package:flutter/material.dart';
import 'package:cptclient/material/PanelSwiper.dart';
import 'package:cptclient/material/DropdownController.dart';
import 'package:cptclient/material/app/AppBody.dart';
import 'package:cptclient/material/app/AppInfoRow.dart';
import 'package:cptclient/material/app/AppButton.dart';
import 'package:cptclient/material/app/AppListView.dart';
import 'package:cptclient/material/app/AppDropdown.dart';
import 'package:cptclient/material/app/AppCourseTile.dart';
import 'package:cptclient/material/app/AppSlotTile.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'ClassMemberPage.dart';

import 'static/navigation.dart' as navi;
import 'static/db.dart' as db;

import 'package:cptclient/json/session.dart';
import 'package:cptclient/json/course.dart';
import 'package:cptclient/json/slot.dart';
import 'package:cptclient/json/user.dart';
import 'package:cptclient/json/branch.dart';
import 'package:cptclient/json/access.dart';

class CourseInfoPage extends StatefulWidget {
  final Session session;
  final Course course;
  final void Function() onUpdate;

  CourseInfoPage({Key? key, required this.session, required this.course, required this.onUpdate}) : super(key: key);

  @override
  CourseInfoPageState createState() => CourseInfoPageState();
}

class CourseInfoPageState extends State<CourseInfoPage> {
  List <Slot> _slots = [];
  List <User> _moderators = [];

  TextEditingController _ctrlCourseKey = TextEditingController();
  TextEditingController _ctrlCourseTitle = TextEditingController();
  bool                  _ctrlCourseActive = true;
  DropdownController<Access> _ctrlCourseAccess = DropdownController<Access>(items: db.cacheAccess);
  DropdownController<Branch> _ctrlCourseBranch = DropdownController<Branch>(items: db.cacheBranches);
  int                        _pickThresholdValue = 0;

  CourseInfoPageState();

  @override
  void initState() {
    super.initState();
    _update();
  }

  void _update() {
    _getCourseSlots();
    _getCourseModerators();
    if (widget.session.right!.admin_courses) _applyCourse();
  }

  void _deleteCourse() async {
    final response = await http.head(
      Uri.http(navi.server, 'course_delete', {'course_id': widget.course.id.toString()}),
      headers: {
        'Token': widget.session.token,
      },
    );

    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete course')));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully deleted course')));
    widget.onUpdate();
    Navigator.pop(context);
  }

  void _duplicateCourse() {
    Course _course = Course.fromCourse(widget.course);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CourseInfoPage(session: widget.session, course: _course, onUpdate: _update)));
  }

  Future<void> _getCourseSlots() async {
    final response = await http.get(
      Uri.http(navi.server, 'course_slot_list', {'course_id': widget.course.id.toString()}),
      headers: {
        'Token': widget.session.token,
        'Accept': 'application/json; charset=utf-8',
      },
    );

    if (response.statusCode != 200) return;

    Iterable l = json.decode(utf8.decode(response.bodyBytes));

    setState(() {
      _slots = List<Slot>.from(l.map((model) => Slot.fromJson(model)));
    });
  }

  void _selectCourseSlot(Slot slot) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ClassMemberPage(session: widget.session, slot: slot, onUpdate: _getCourseSlots, isDraft: false,)));
  }

  void _createCourseSlot() async {
    _selectCourseSlot(Slot.fromCourse(widget.course));
  }

  Future<void> _getCourseModerators() async {
    final response = await http.get(
      Uri.http(navi.server, 'course_moderator_list', {'course_id': widget.course.id.toString()}),
      headers: {
        'Token': widget.session.token,
        'Accept': 'application/json; charset=utf-8',
      },
    );

    if (response.statusCode != 200) return;

    Iterable list = json.decode(utf8.decode(response.bodyBytes));

    setState(() {
      _moderators = List<User>.from(list.map((model) => User.fromJson(model)));
    });
  }

  void _modMember(User user) async {
    final response = await http.head(
      Uri.http(navi.server, 'course_mod', {
        'course_id': widget.course.id.toString(),
        'user_id' : user.id.toString(),
      }),
      headers: {
        'Token': widget.session.token,
      },
    );

    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add moderator')));
      return;
    }

    _getCourseModerators();
  }

  void _unmodMember(User user) async {
    final response = await http.head(
      Uri.http(navi.server, 'course_unmod', {
        'course': widget.course.id.toString(),
        'user' : user.id.toString(),
      }),
      headers: {
        'Token': widget.session.token,
      },
    );

    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to remove moderator')));
      return;
    }

    _getCourseModerators();
  }

  void _applyCourse() {
    _ctrlCourseKey.text = widget.course.key;
    _ctrlCourseTitle.text = widget.course.title;
    _ctrlCourseActive = widget.course.active;
    _ctrlCourseAccess.value = widget.course.access;
    _ctrlCourseBranch.value = widget.course.branch;
    _pickThresholdValue = widget.course.threshold;
  }

  void _gatherCourse() {
    widget.course.key = _ctrlCourseKey.text;
    widget.course.title = _ctrlCourseTitle.text;
    widget.course.active = _ctrlCourseActive;
    widget.course.access = _ctrlCourseAccess.value;
    widget.course.branch = _ctrlCourseBranch.value;
    widget.course.threshold = _pickThresholdValue;
  }

  void _submitCourse() async {
    _gatherCourse();

    final response = await http.post(
      Uri.http(navi.server, widget.course.id == 0 ? 'course_create' : 'course_edit'),
      headers: {
        'Token': widget.session.token,
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: json.encode(widget.course),
    );

    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to edit course')));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully edited course')));
    widget.onUpdate();
    Navigator.pop(context);
  }

  @override
  Widget build (BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Course Details"),
      ),
      body: AppBody(
        children: <Widget>[
          if (widget.course.id != 0) Row(
            children: [
              Expanded(
                child: AppCourseTile(
                  onTap: (course) => {},
                  course: widget.course,
                ),
              ),
              if (widget.session.right!.admin_courses) IconButton(
                icon: const Icon(Icons.copy),
                onPressed: _duplicateCourse,
              ),
              if (widget.session.right!.admin_courses) IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _deleteCourse,
              ),
            ],
          ),
          PanelSwiper(
            panels: [
              Panel("Slots", _buildSlotPanel()),
              Panel("Moderators", _buildModeratorPanel()),
            ]
          ),
        ],
      ),
    );
  }

  Widget _buildSlotPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          leading: Icon(Icons.add),
          text: "New slot",
          onPressed: _createCourseSlot,
        ),
        AppListView<Slot>(
          items: _slots,
          itemBuilder: (Slot slot) {
            return AppSlotTile(
              onTap: _selectCourseSlot,
              slot: slot,
            );
          },
        ),
      ],
    );
  }

  Widget _buildModeratorPanel() {
    return Column(
      children: [
        AppListView<User>(
          items: _moderators,
          itemBuilder: (User user) {
            return InkWell(
              child: ListTile(
                title: Text("${user.lastname}, ${user.firstname}"),
                subtitle: Text("${user.key}"),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildEditPanel() {
    return Column(
      children: [
        AppInfoRow(
          info: Text("Key"),
          child: TextField(
            maxLines: 1,
            controller: _ctrlCourseKey,
          ),
        ),
        AppInfoRow(
          info: Text("Title"),
          child: TextField(
            maxLines: 1,
            controller: _ctrlCourseTitle,
          ),
        ),
        AppInfoRow(
          info: Text("Active"),
          child: Checkbox(
            value: _ctrlCourseActive,
            onChanged: (bool? active) =>  setState(() => _ctrlCourseActive = active!),
          ),
        ),
        AppInfoRow(
          info: Text("Access"),
          child: AppDropdown<Access>(
            hint: Text("Access"),
            controller: _ctrlCourseAccess,
            builder: (Access access) => Text(access.title),
            onChanged: (Access? access) => setState(() => _ctrlCourseAccess.value = access),
          ),
        ),
        AppInfoRow(
          info: Text("Branch"),
          child: AppDropdown<Branch>(
            hint: Text("Branch"),
            controller: _ctrlCourseBranch,
            builder: (Branch branch) => Text(branch.title),
            onChanged: (Branch? branch) => setState(() => _ctrlCourseBranch.value = branch),
          ),
        ),
        AppInfoRow(
            info: Text("Level"),
            child: Slider(
              value: _pickThresholdValue.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: (double value) {
                setState(() => _pickThresholdValue = value.toInt());
              },
              label: "$_pickThresholdValue",
            )
        ),
        AppButton(
          text: "Save",
          onPressed: _submitCourse,
        ),
      ],
    );
  }

}
