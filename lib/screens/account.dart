
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:oktopadupshot/db.dart';

import '../app.dart';

class Account extends StatefulWidget {
  final AppState appState;
  final int? itemId;
  final ScreenController controller;

  Account({
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

enum AccountType {
  Active,
  Passive,
}

class AccountState extends State<Account> with AutomaticKeepAliveClientMixin<Account> {

  late int? itemId;
  late TextEditingController textNameController;
  List<String> subAccounts = [];
  List<TextEditingController> textSubAccountsControllers = [];
  AccountType type = AccountType.Active;

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

    final newId = await Db.instance.saveAccount(itemId, {
      'name': textNameController.text,
      'active': type == AccountType.Active ? 1 : 0,
      'sub': jsonEncode(textSubAccountsControllers.map((e) => e.text).toList())
    });
    itemId = newId;
  }

  _loadData() async {
    if (itemId == null) {
      return;
    }
    final data = await Db.instance.getAccount(itemId!);
    setState(() {
      textNameController.text = data['name'];
      type = data['active'] == 1 ? AccountType.Active : AccountType.Passive;
      subAccounts = (jsonDecode(data['sub']) as List<dynamic>).cast<String>();
      textSubAccountsControllers.clear();
      subAccounts.forEach((element) {
        textSubAccountsControllers.add(TextEditingController(text: element));
      });
      print('got sub $subAccounts from ${data['sub']}');
    });
  }

  @override
  void initState() {
    textNameController = TextEditingController();
    textNameController.addListener(_dataChange);
    itemId = widget.itemId;
    widget.controller.onLeave = () => _saveData();
    _loadData();
    super.initState();
  }

  void addSubAccount() {
    setState(() {
      subAccounts.add('');
      final controller = TextEditingController();
      controller.addListener(_dataChange);
      textSubAccountsControllers.add(controller);
      _dataChange();
    });

  }

  void removeSubAccount(int index) {
    setState(() {
      subAccounts.removeAt(index);
      textSubAccountsControllers.removeAt(index);
      _dataChange();
    });
  }

  changeAccountType(AccountType? newType) {
    setState(() {
      type = newType == null ? AccountType.Active : newType;
      _dataChange();
    });
  }

  @override
  Widget build(BuildContext context) {
    final widget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(labelText: 'Название'),
          controller: textNameController,
        ),
        marginWidget,
        Row(
          children: [
            Radio<AccountType>(value: AccountType.Active, groupValue: type, onChanged: (value) => changeAccountType(value)),
            Text('Активный'),
            Radio<AccountType>(value: AccountType.Passive, groupValue: type, onChanged: (value) => changeAccountType(value)),
            Text('Пассивный'),
          ],
        ),
        marginWidget,
        Text('Субсчета'),
        marginWidget,
        createButton('Добавить', addSubAccount),
        marginWidget,
        Expanded(child: SingleChildScrollView(
          child: Column(
            children: [
              ...subAccounts.mapIndexed((index, subAccount) => Row(
                  children: [
                    IconButton(onPressed: () => removeSubAccount(index), icon: Icon(Icons.close)),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(labelText: 'Субсчет'),
                        controller: textSubAccountsControllers[index],
                      ),
                    ),
                  ]
              )).toList(),

            ],
          ),
        )),
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
