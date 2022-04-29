
import 'package:flutter/cupertino.dart';

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

  AccountState({ required this.appState });

  @override
  Widget build(BuildContext context) {
    return Text('Hello world');
  }

}
