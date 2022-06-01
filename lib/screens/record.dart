
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
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
  int? dt;
  int? dtSubIndex;
  int? kt;
  int? ktSubIndex;
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
    _loadAccounts();
    super.initState();
  }

  List<Map<String, dynamic>> _accounts = [];
  List<String> _dtSubs = [];
  List<String> _ktSubs = [];

  _loadAccounts() async {
    final accountsData = await Db.instance.getAccounts();
    setState(() {
      _accounts = accountsData;
    });
  }

  _updateDtSubAccounts() {
    final dtAcc = _accounts.firstWhereOrNull((e) => e['rowid'] == dt);
    setState(() {
      dtSubIndex = null;
      if (dtAcc != null && dtSubIndex == null) {
        _dtSubs = (jsonDecode(dtAcc['sub']) as List<dynamic>).cast<String>();
      }
    });
  }

  _updateKtSubAccounts() {
    final ktAcc = _accounts.firstWhereOrNull((e) => e['rowid'] == kt);
    setState(() {
      ktSubIndex = null;
      if (ktAcc != null && ktSubIndex == null) {
        _ktSubs = (jsonDecode(ktAcc['sub']) as List<dynamic>).cast<String>();
      }
    });
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
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
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
        marginWidget,marginWidget,
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text('Дт', style: titleStyle),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(labelText: 'Счет'),
                    value: dt,
                    items: _accounts.map((e) => DropdownMenuItem(
                      value: e['rowid'] as int,
                      child: Text(e['name']),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        dt = value;
                      });
                      _updateDtSubAccounts();
                    },
                  ),
                  marginWidget,
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(labelText: 'Субсчет'),
                    value: dtSubIndex,
                    items: _dtSubs.mapIndexed((index, e) => DropdownMenuItem(
                      value: index,
                      child: Text(e),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        dtSubIndex = value;
                      });
                    },
                  ),

                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
            marginWidget,marginWidget,
            Expanded(
              child: Column(
                children: [
                  Text('Кт', style: titleStyle),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(labelText: 'Счет'),
                    value: kt,
                    items: _accounts.map((e) => DropdownMenuItem(
                      value: e['rowid'] as int,
                      child: Text(e['name']),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        kt = value;
                      });
                      _updateKtSubAccounts();
                    },
                  ),
                  marginWidget,
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(labelText: 'Субсчет'),
                    value: ktSubIndex,
                    items: _ktSubs.mapIndexed((index, e) => DropdownMenuItem(
                      value: index,
                      child: Text(e),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        ktSubIndex = value;
                      });
                    },
                  ),

                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
          ],
        ),
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
