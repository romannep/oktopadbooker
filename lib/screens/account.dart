
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

class AccountState extends State<Account> {
  final AppState appState;
  late TextEditingController textNameController;
  List<String> subAccounts = [];
  List<TextEditingController> textSubAccountsControllers = [];

  AccountState({ required this.appState });

  @override
  void initState() {
    textNameController = TextEditingController();
    textNameController.text = 'asd 123';
    super.initState();
  }

  void addSubAccount() {
    setState(() {
      subAccounts.add('');
      textSubAccountsControllers.add(TextEditingController());
    });

  }

  void removeSubAccount(int index) {
    setState(() {
      subAccounts.removeAt(index);
      textSubAccountsControllers.removeAt(index);
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
