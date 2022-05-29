
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:oktopadbooker/db.dart';

import '../app.dart';

formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2,'0')}.${date.month.toString().padLeft(2,'0')}.${date.year}';
}


// date, dt, kt, sum, comment

class Record extends StatefulWidget {
  final AppState appState;
  final int? itemId;
  final ScreenController controller;

  Record({
    required this.appState,
    this.itemId,
    required this.controller,
    Key? key,
  }): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AccountState();
  }

}


class AccountState extends State<Record> with AutomaticKeepAliveClientMixin<Record> {

  late int? itemId;
  DateTime date = DateTime.now();
  // late TextEditingController textNameController;
  // List<String> subAccounts = [];
  // List<TextEditingController> textSubAccountsControllers = [];

  Timer? _changeTimer;

  _dataChange() {
    if (_changeTimer != null) {
      _changeTimer!.cancel();
      _changeTimer = null;
    }
    _changeTimer = new Timer(Duration(milliseconds: DEBOUNCE_TIMEOUT_MS), _saveData);
  }

  _saveData() async {
    if (_changeTimer != null) {
      _changeTimer!.cancel();
      _changeTimer = null;
    }

    // final newId = await Db.instance.saveAccount(itemId, {
    //   'name': textNameController.text,
    //   'active': type == AccountType.Active ? 1 : 0,
    //   'sub': jsonEncode(textSubAccountsControllers.map((e) => e.text).toList())
    // });
    // itemId = newId;
  }

  _loadData() async {
    if (itemId == null) {
      return;
    }
    // final data = await Db.instance.getAccount(itemId!);
    // setState(() {
    //   textNameController.text = data['name'];
    //   type = data['active'] == 1 ? AccountType.Active : AccountType.Passive;
    //   subAccounts = (jsonDecode(data['sub']) as List<dynamic>).cast<String>();
    //   textSubAccountsControllers.clear();
    //   subAccounts.forEach((element) {
    //     textSubAccountsControllers.add(TextEditingController(text: element));
    //   });
    //   print('got sub $subAccounts from ${data['sub']}');
    // });
  }

  @override
  void initState() {
    itemId = widget.itemId;
    // textNameController = TextEditingController();
    // textNameController.addListener(_dataChange);
    widget.controller.onLeave = () => _saveData();
    _loadData();
    super.initState();
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200)
    );
    if (picked != null && picked != date) {
      setState(() {
        date = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final widget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              flex: 1,
              child: Row(
                children: [
                  Text(formatDate(date.toLocal())),
                  IconButton(onPressed: () => _selectDate(context), icon: Icon(Icons.calendar_month)),
                ],
              ),
            ),
            marginWidget,
            Flexible(
              flex: 1,
              child: TextField(
                decoration: InputDecoration(labelText: 'Сумма'),
              ),
            ),
            marginWidget,
            Flexible(
              flex: 3,
              child: TextField(
                decoration: InputDecoration(labelText: 'Комментарий'),
              ),
            ),
          ],
        ),
        TextField(
          decoration: InputDecoration(labelText: 'Название'),
        ),
        marginWidget,
      ],
    );

    return widget;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _saveData();
    super.dispose();
  }
}
