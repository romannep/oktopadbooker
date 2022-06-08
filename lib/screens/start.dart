
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oktopadbooker/app.dart';

class StartScreen extends StatelessWidget {
  final AppState appState;
  StartScreen({
    required this.appState,
  });

  changeData() {
    appState.navigate(Screen.Records);
  }

  seeResults() {
    appState.navigate(Screen.Report);
  }

  setupAccounts() {
    appState.navigate(Screen.Accounts);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        createButton('Посмотреть результаты', seeResults),
        marginWidget,
        createButton('Добавить или изменить проводки', changeData),
        marginWidget,
        createButton('Настроить счета', setupAccounts),
      ],
    );
  }
}
