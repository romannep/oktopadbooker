

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktopadupshot/app.dart';

class Accounts extends StatefulWidget {
  final AppState appState;

  Accounts({ required this.appState, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new AccountsState(appState: appState);
  }

}

class AccountsState extends State<Accounts> {
  final AppState appState;

  AccountsState({ required this.appState });

  openAccount() {
    appState.navigate(Screen.Account);
  }

  newAccount() {
    appState.navigate(Screen.Account, ScreenParams(newItem: true));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        createButton('Добавить новый счет', newAccount),
        marginWidget,
        Expanded(
          child: ListView(
            children: [
              Text('acc 1'),
              Text('acc 2'),
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
