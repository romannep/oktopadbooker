

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

class ScreenController {
  // may be it's overkill, as in PageView every page creates state on activate
  // unless using AutomaticKeepAliveClientMixin
  void Function()? onActivate;
}

class ScreenItem {
  Widget widget;
  String title;
  ScreenController controller;
  ScreenItem({
    required this.widget,
    required this.title,
    required this.controller,
  });
}

class AppState extends State<App> {

  final pageController = PageController(initialPage: 0);
  final List<ScreenItem> screens = []; // has extra screen (Start) to have ability to scroll after setState
  final List<void Function()> onActivate = [];
  final List<Widget> buttons = [];
  String title = '';

  back() {
    animateTo(pageController, pageController.page!.toInt() - 1);
    processNavigate(pageController.page!.toInt() - 1);
  }

  forward() {
    animateTo(pageController, pageController.page!.toInt() + 1);
    processNavigate(pageController.page!.toInt() + 1);
  }

  processNavigate([newPage = -1]) {
    setState(() {
      int page = newPage > -1 ? newPage : pageController.page!.toInt();
      if (screens[page].controller.onActivate != null) {
        screens[page].controller.onActivate!();
      }
      title = screens[page].title;
      int pageCount = screens.length - 2;
      buttons.clear();
      buttons.add(IconButton(onPressed: page > 0 ? back : null, icon: Icon(Icons.arrow_back)));
      buttons.add(IconButton(onPressed: page < pageCount ? forward : null, icon: Icon(Icons.arrow_forward)));
      buttons.add(Text(title));
    });
  }

  @override
  void initState() {
    final item = ScreenItem(
      widget: ScreenWrapper(StartScreen(appState: this)),
      title: '',
      controller: ScreenController(),
    );
    screens.add(item);
    screens.add(item);
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
        children: screens.map((e) => e.widget).toList(),
      ),
    );
  }

  navigate(Screen? screen, [ScreenParams? params]) {
    if (screen == null) {
      return;
    }
    int page = pageController.page!.toInt();
    screens.removeRange(page + 1, screens.length);
    page++;
    setState(() {
      switch (screen) {
        case Screen.Accounts: {
          final controller = ScreenController();
          final item = ScreenItem(
            widget: ScreenWrapper(Accounts(appState: this, screenController: controller)),
            title: 'Счета',
            controller: controller,
          );
          screens.add(item);
          break;
        }
        case Screen.Account: {
          Key? key = null;
          if (params != null && params.newItem) {
            key = UniqueKey();
          }
          final item = ScreenItem(
            widget: ScreenWrapper(Account(appState: this, key: key)),
            title: 'Счет',
            controller: ScreenController(),
          );
          screens.add(item);
          break;
        }
        case Screen.Records: {
          final item = ScreenItem(
            widget: ScreenWrapper(Records(appState: this)),
            title: 'Проводки',
            controller: ScreenController(),
          );
          screens.add(item);
          break;
        }
        default: {
          page = 0;
        }
      }
      final item = ScreenItem(
        widget: ScreenWrapper(StartScreen(appState: this)),
        title: '',
        controller: ScreenController(),
      );
      screens.add(item); // To have ability to scroll after setState for next screen
      processNavigate(page);
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        animateTo(pageController, page);
      });
    });
  }
}
