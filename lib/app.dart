

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oktopadupshot/screens/account.dart';
import 'package:oktopadupshot/screens/accounts.dart';
import 'package:oktopadupshot/screens/start.dart';

const PAGE_SCROLL_TIME_MS = 200;

final BUTTON_STYLE = TextButton.styleFrom(
  backgroundColor: Colors.blue,
);

const BUTTON_TEXT_STYLE = const TextStyle(color: Colors.white);

Widget createButton(String label, void Function() onPressed) => ElevatedButton(
  onPressed: onPressed,
  style: BUTTON_STYLE,
  child: Text(label, style: BUTTON_TEXT_STYLE),
);

final marginWidget = SizedBox(
  height: 15,
);


class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AppState();
  }

}

class ScreenWrapper extends StatelessWidget {
  Widget child;
  ScreenWrapper(this.child);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            constraints: BoxConstraints(
              minHeight: 0,
              maxHeight:  450,
              minWidth: 0,
              maxWidth: 600,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class AppState extends State<App> {

  final pageController = PageController(initialPage: 0);

  back() {
    pageController.animateToPage(pageController.page!.toInt() - 1, duration: Duration(milliseconds: PAGE_SCROLL_TIME_MS), curve: Curves.linear);
  }

  forward() {
    pageController.animateToPage(pageController.page!.toInt() + 1, duration: Duration(milliseconds: PAGE_SCROLL_TIME_MS), curve: Curves.linear);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        // title: Text('Otkopad Upshot'),
        title: Row(
          children: [
            IconButton(onPressed: back, icon: Icon(Icons.arrow_back)),
            IconButton(onPressed: forward, icon: Icon(Icons.arrow_forward)),
          ],
        ),
      ),
      // body: StartScreen(appState: this),
      body: PageView(
        controller: pageController,
        children: [
          ScreenWrapper(StartScreen(appState: this)),
          ScreenWrapper(Accounts(appState: this)),
          ScreenWrapper(Account(appState: this)),
        ],
      ),
    );
  }

  navigate() {
    print('navigate');
  }
}
