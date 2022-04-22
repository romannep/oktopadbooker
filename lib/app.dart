

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oktopadupshot/screens/start.dart';

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AppState();
  }

}

class AppState extends State<App> {

  final pageController = PageController(initialPage: 0);

  back() {
    pageController.animateToPage(pageController.page!.toInt() - 1, duration: Duration(milliseconds: 500), curve: Curves.linear);
  }

  forward() {
    pageController.animateToPage(pageController.page!.toInt() + 1, duration: Duration(milliseconds: 500), curve: Curves.linear);
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
          StartScreen(appState: this),
          StartScreen(appState: this),
        ],
      ),
    );
  }

  navigate() {
    print('navigate');
  }
}
