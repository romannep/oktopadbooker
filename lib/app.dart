

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

enum Screen {
  Start,
  Accounts,
  Account,
}

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
  final List<Widget> screens = []; // has extra screen (Start) to have ability to scroll after setState

  back() {
    pageController.animateToPage(pageController.page!.toInt() - 1, duration: Duration(milliseconds: PAGE_SCROLL_TIME_MS), curve: Curves.linear);
  }

  forward() {
    pageController.animateToPage(pageController.page!.toInt() + 1, duration: Duration(milliseconds: PAGE_SCROLL_TIME_MS), curve: Curves.linear);
  }

  @override
  void initState() {
    screens.add(ScreenWrapper(StartScreen(appState: this)));
    screens.add(ScreenWrapper(StartScreen(appState: this)));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        children: screens,
      ),
    );
  }

  navigate(Screen? screen) {
    if (screen == null) {
      return;
    }
    print('navigate to $screen cur page ${pageController.page!.toInt()}');
    int page = pageController.page!.toInt();
    screens.removeRange(page + 1, screens.length);
    page++;
    setState(() {
      switch (screen) {
        case Screen.Accounts: {
          screens.add(ScreenWrapper(Accounts(appState: this)));
          break;
        }
        case Screen.Account: {
          screens.add(ScreenWrapper(Account(appState: this)));
          break;
        }
        default: {
          page = 0;
        }
      }
      screens.add(ScreenWrapper(StartScreen(appState: this))); // To have ability to scroll after setState for next screen
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        pageController.animateToPage(page, duration: Duration(milliseconds: PAGE_SCROLL_TIME_MS), curve: Curves.linear);
      });
    });
  }
}
