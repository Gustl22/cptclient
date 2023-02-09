import 'package:cptclient/material/AppButton.dart';
import 'package:cptclient/material/UserFilter.dart';
import 'package:flutter/material.dart';
import 'package:cptclient/material/AppListView.dart';
import 'package:cptclient/material/AppBody.dart';

import 'package:cptclient/json/user.dart';

void showUserPicker({
  required BuildContext context,
  required List<User> usersAvailable,
  List<User> usersHidden = const [],
  required Function(User) onSelect,

}) async {
  Widget dialog = UserPicker(
    usersAvailable: usersAvailable,
    usersHidden: usersHidden,
    onSelect: onSelect,
  );

  return showDialog(
    context: context,
    useSafeArea: false,
    builder: (BuildContext context) {
      return AppBody(
        children: [dialog],
      );
    },
  );
}

class UserPicker extends StatefulWidget {
  final List<User> usersAvailable;
  final List<User> usersHidden;
  final Function(User user) onSelect;

  UserPicker({
    Key? key,
    required this.usersAvailable,
    this.usersHidden = const [],
    required this.onSelect,
  }) : super(key: key);

  @override
  _UserPickerState createState() => new _UserPickerState();
}

class _UserPickerState extends State<UserPicker> {
  List<User> _usersVisible = [];
  List<User> _usersLimited = [];

  TextEditingController _ctrlUserFilter = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usersVisible = widget.usersAvailable.toSet().difference(widget.usersHidden.toSet()).toList();
    _usersVisible.sort();
  }

  void _handleSelect(User user) {
    _usersVisible.remove(user);
    setState(() {
      _usersLimited.remove(user);
    });
    widget.onSelect(user);
  }

  void _limitUsers(List<User> users) {
    users.sort();
    setState(() {
      _usersLimited = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    var textfield = UserFilter(users: _usersVisible.toList(), controller: _ctrlUserFilter, onChange: _limitUsers);

    var list = AppListView<User>(
      items: _usersLimited,
      itemBuilder: (User user) {
        return InkWell(
          child: ListTile(
            title: Text("${user.lastname}, ${user.firstname}"),
            subtitle: Text("${user.key}"),
            trailing: IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _handleSelect(user),
            ),
          ),
        );
      },
    );

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 500,
        width: 430,
        child: Column(
          children: [
            AppButton(text: "Close", onPressed: () => Navigator.pop(context)),
            textfield,
            list,
          ],
        ),
      ),
    );
  }
}
