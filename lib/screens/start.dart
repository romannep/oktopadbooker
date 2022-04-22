
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oktopadupshot/app.dart';

class StartScreen extends StatelessWidget {
  final AppState appState;
  StartScreen({
    required this.appState,
  });

  changeData() {
    appState.navigate();
  }

  seeResults() {
    appState.navigate();
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: changeData,
          style: TextButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
          child: Text('Ввести или изменить данные', style: TextStyle(color: Colors.white)),
        ),
        SizedBox(
          height: 15,
        ),
        ElevatedButton(
          onPressed: seeResults,
          style: TextButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
          child: Text('Посмотреть результаты', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }
}
