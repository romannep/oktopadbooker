

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oktopadupshot/screens/account.dart';
import 'package:oktopadupshot/screens/accounts.dart';
import 'package:oktopadupshot/screens/records.dart';
import 'package:oktopadupshot/screens/start.dart';

import 'db.dart';

const PAGE_SCROLL_TIME_MS = 200;

final BUTTON_STYLE = TextButton.styleFrom(
  backgroundColor: Colors.blue,
);

const BUTTON_TEXT_STYLE = const TextStyle(color: Colors.white);

const DEBOUNCE_TIMEOUT_MS = 1000;

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
  Records,
}

class ScreenParams {
  bool newItem;
  String? id;

  ScreenParams({
    this.newItem = false,
    this.id,
  });
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
  ScreenWrapper(this.child, [Key? key]): super(key: key);

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
  final List<String> titles = [];
  final List<Widget> buttons = [];
  String title = '';

  void Function()? onNavigationChange;

  back() {
    animateTo(pageController, pageController.page!.toInt() - 1);
    setTitleButtons(pageController.page!.toInt() - 1);
    if (onNavigationChange != null) {
      onNavigationChange!();
      onNavigationChange = null;
    }
  }

  forward() {
    animateTo(pageController, pageController.page!.toInt() + 1);
    setTitleButtons(pageController.page!.toInt() + 1);
    if (onNavigationChange != null) {
      onNavigationChange!();
      onNavigationChange = null;
    }
  }

  setTitleButtons([newPage = -1]) {
    setState(() {
      int page = newPage > -1 ? newPage : pageController.page!.toInt();
      title = titles[page];
      int pageCount = screens.length - 2;
      buttons.clear();
      buttons.add(IconButton(onPressed: page > 0 ? back : null, icon: Icon(Icons.arrow_back)));
      buttons.add(IconButton(onPressed: page < pageCount ? forward : null, icon: Icon(Icons.arrow_forward)));
      buttons.add(Text(title));
    });
  }

  @override
  void initState() {
    screens.add(ScreenWrapper(StartScreen(appState: this)));
    titles.add('');
    screens.add(ScreenWrapper(StartScreen(appState: this)));
    buttons.add(IconButton(onPressed: null, icon: Icon(Icons.arrow_back)));
    buttons.add(IconButton(onPressed: null, icon: Icon(Icons.arrow_forward)));
    super.initState();

    Db.instance.init();
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
        children: [...screens],
      ),
    );
  }

  navigate(Screen? screen, [ScreenParams? params]) {
    if (screen == null) {
      return;
    }
    int page = pageController.page!.toInt();
    screens.removeRange(page + 1, screens.length);
    titles.removeRange(page + 1, titles.length);
    page++;
    setState(() {
      switch (screen) {
        case Screen.Accounts: {
          screens.add(ScreenWrapper(Accounts(appState: this)));
          titles.add('Счета');
          break;
        }
        case Screen.Account: {
          Key? key = null;
          if (params != null && params.newItem) {
            key = UniqueKey();
          }
          screens.add(ScreenWrapper(Account(appState: this, key: key)));
          titles.add('Счет');
          break;
        }
        case Screen.Records: {
          screens.add(ScreenWrapper(Records(appState: this)));
          titles.add('Проводки');
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
