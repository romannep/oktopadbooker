

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktopadupshot/app.dart';

class Records extends StatefulWidget {
  final AppState appState;

  Records({ required this.appState, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new RecordsState(appState: appState);
  }

}

class RecordsState extends State<Records> {
  final AppState appState;

  RecordsState({ required this.appState });

  openAccount() {
    appState.navigate(Screen.Account);
  }

  newAccount() {
    appState.navigate(Screen.Record, ScreenParams(newItem: true));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        createButton('Добавить новую проводку', newAccount),
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
