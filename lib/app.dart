

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

void animateTo(PageController pageController, int page) {
  pageController.animateToPage(page, duration: Duration(milliseconds: PAGE_SCROLL_TIME_MS), curve: Curves.linear);
}

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
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
              maxHeight:  435,
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
  final List<Widget> buttons = [];

  back() {
    animateTo(pageController, pageController.page!.toInt() - 1);
    setTitleButtons(pageController.page!.toInt() - 1);
  }

  forward() {
    animateTo(pageController, pageController.page!.toInt() + 1);
    setTitleButtons(pageController.page!.toInt() + 1);
  }

  setTitleButtons([newPage = -1]) {
    setState(() {
      int page = newPage > -1 ? newPage : pageController.page!.toInt();
      int pageCount = screens.length - 2;
      buttons.clear();
      buttons.add(IconButton(onPressed: page > 0 ? back : null, icon: Icon(Icons.arrow_back)));
      buttons.add(IconButton(onPressed: page < pageCount ? forward : null, icon: Icon(Icons.arrow_forward)));
    });
  }

  @override
  void initState() {
    screens.add(ScreenWrapper(StartScreen(appState: this)));
    screens.add(ScreenWrapper(StartScreen(appState: this)));
    buttons.add(IconButton(onPressed: null, icon: Icon(Icons.arrow_back)));
    buttons.add(IconButton(onPressed: null, icon: Icon(Icons.arrow_forward)));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: buttons,
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
      setTitleButtons(page);
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        animateTo(pageController, page);
      });
    });
  }
}
