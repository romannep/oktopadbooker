

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktopadupshot/app.dart';

import '../db.dart';

class Accounts extends StatefulWidget {
  final AppState appState;
  final ScreenController screenController;

  Accounts({ required this.appState, required this.screenController, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new AccountsState(appState: appState, screenController: screenController);
  }

}

class AccountItem {
  int id;
  String name;

  AccountItem(this.id, this.name);
}

class AccountsState extends State<Accounts> {
  final AppState appState;
  final ScreenController screenController;
  List<AccountItem> activeAccounts = [];
  List<AccountItem> passiveAccounts = [];

  AccountsState({ required this.appState, required this.screenController });

  @override
  initState() {
    // state is created on each activation
    // screenController.onActivate = onActivate;
    onActivate();
    super.initState();
  }

  onActivate() async {
    final accountsData = await Db.instance.getAccounts();
    print('got accounts $accountsData');
    setState(() {
      // accounts = accountsData;
      activeAccounts.clear();
      passiveAccounts.clear();
      accountsData.forEach((element) {
        final account = AccountItem(element['rowid'], ' - ${element['name']}');
        final sub = (jsonDecode(element['sub']) as List<dynamic>).cast<String>();
        final listToAdd = element['active'] == 1 ? activeAccounts : passiveAccounts;
        listToAdd.add(account);
        sub.forEach((subAccountName) {
          final subAccount = AccountItem(element['rowid'], ' - - $subAccountName');
          listToAdd.add(subAccount);
        });
      });
    });
  }

  openAccount() {
    appState.navigate(Screen.Account);
  }

  newAccount() {
    appState.navigate(Screen.Account, ScreenParams(newItem: true));
  }

  @override
  Widget build(BuildContext context) {
    final actives = activeAccounts.map((e) => createListItem(e.name, e.id)).toList();
    final passives = passiveAccounts.map((e) => createListItem(e.name, e.id)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        createButton('Добавить новый счет', newAccount),
        marginWidget,
        Expanded(
          child: ListView(
            children: [
              createListItem('Активные', -1),
              ...actives,
              createListItem('Пассивные', -1),
              ...passives,
              Container(
                child: Text('acc 3'),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ],
    );

  }
}

Widget createListItem(String name, int id) {
  return ListTile(
    title: Text(name),
    visualDensity: VisualDensity(vertical:  -4),
    hoverColor: id > -1 ? Colors.blue : null,
    onTap: id == -1 ? null : () {
      print('tap on $id');
    },
  );
}
