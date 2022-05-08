
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import '../app.dart';

class Account extends StatefulWidget {
  final AppState appState;

  Account({ required this.appState });

  @override
  State<StatefulWidget> createState() {
    return AccountState( appState: appState);
  }

}

enum AccountType {
  Active,
  Passive,
}

class AccountState extends State<Account> {
  final AppState appState;
  late TextEditingController textNameController;
  List<String> subAccounts = [];
  List<TextEditingController> textSubAccountsControllers = [];
  AccountType type = AccountType.Active;

  AccountState({ required this.appState });

  Timer? _changeTimer;
  _dataChange() {
    if (_changeTimer != null) {
      _changeTimer!.cancel();
      _changeTimer = null;
    }
    _changeTimer = new Timer(Duration(milliseconds: DEBOUNCE_TIMEOUT_MS), _saveData);
  }
  _saveData() {
    if (_changeTimer != null) {
      _changeTimer!.cancel();
      _changeTimer = null;
    }
    print('saving....');
  }


  @override
  void initState() {
    textNameController = TextEditingController();
    textNameController.addListener(_dataChange);
    appState.onNavigationChange = () {
      _saveData();
    };
    super.initState();
  }

  void addSubAccount() {
    setState(() {
      subAccounts.add('');
      final controller = TextEditingController();
      controller.addListener(_dataChange);
      textSubAccountsControllers.add(controller);
    });

  }

  void removeSubAccount(int index) {
    setState(() {
      subAccounts.removeAt(index);
      textSubAccountsControllers.removeAt(index);
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
    return Column(children: [Expanded(child: SingleChildScrollView(
      child: widget
    ))]);
  }

}
