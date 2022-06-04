

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktopadbooker/app.dart';

import '../db.dart';

class Accounts extends StatefulWidget {
  final AppState appState;
  final ScreenController screenController;

  Accounts({ required this.appState, required this.screenController, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new AccountsState(screenController: screenController);
  }

}

class AccountItem {
  int id;
  String name;

  AccountItem(this.id, this.name);
}

class AccountsState extends State<Accounts> {
  final ScreenController screenController;
  List<AccountItem> activeAccounts = [];
  List<AccountItem> passiveAccounts = [];

  AccountsState({ required this.screenController });

  @override
  initState() {
    // state is created on each activation
    // screenController.onActivate = onActivate;
    onActivate();
    super.initState();
  }

  onActivate() async {
    final accountsData = await Db.instance.getAccounts();
    // print('got accounts $accountsData');
    setState(() {
      // accounts = accountsData;
      activeAccounts.clear();
      passiveAccounts.clear();
      accountsData.forEach((element) {
        final account = AccountItem(element['rowid'], ' ${element['name']}');
        final sub = (jsonDecode(element['sub']) as List<dynamic>).cast<String>();
        final listToAdd = element['active'] == 1 ? activeAccounts : passiveAccounts;
        listToAdd.add(account);
        sub.forEach((subAccountName) {
          final subAccount = AccountItem(element['rowid'], ' - $subAccountName');
          listToAdd.add(subAccount);
        });
      });
    });
  }

  void openAccount(int id) {
    widget.appState.navigate(Screen.Account, ScreenParams(id: id));
  }

  newAccount() {
    widget.appState.navigate(Screen.Account, ScreenParams(newItem: true));
  }

  @override
  Widget build(BuildContext context) {
    final actives = activeAccounts.map((e) => createListItem(e.name, e.id, openAccount)).toList();
    final passives = passiveAccounts.map((e) => createListItem(e.name, e.id, openAccount)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        createButton('Добавить новый счет', newAccount),
        marginWidget,
        Expanded(
          child: Row(
            children: [
              Expanded(child: Column(
                children: [
                  Text('Активные', style: titleStyle),
                  Expanded(child: ListView(
                    children: [
                      ...actives,
                    ],
                  )),
                ],
              )),
              marginWidget, marginWidget,
              Expanded(child: Column(
                children: [
                  Text('Пассивные', style: titleStyle),
                  Expanded(child: ListView(
                    children: [
                      ...passives,
                    ],
                  )),
                ],
              )),
            ],
          ),
        ),
      ],
    );

  }
}

Widget createListItem(String name, id, void handler(int itemId)) {
  return ListTile(
    title: Text(name, style: id == -1 ? titleStyle : null),
    visualDensity: VisualDensity(vertical:  -4),
    hoverColor: id > -1 ? PRIMARY_COLOR : null,
    onTap: id == -1 ? null : () {
      print('tap on $id');
      handler(id);
    },
  );
}
