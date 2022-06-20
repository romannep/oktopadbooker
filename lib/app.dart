

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:oktopadbooker/screens/account.dart';
import 'package:oktopadbooker/screens/accounts.dart';
import 'package:oktopadbooker/screens/record.dart';
import 'package:oktopadbooker/screens/records.dart';
import 'package:oktopadbooker/screens/report.dart';
import 'package:oktopadbooker/screens/start.dart';

import 'db.dart';

const PRIMARY_COLOR_VALUE = 0xFF088596;
const PRIMARY_COLOR_DARK_VALUE = 0xFF055863;

const PRIMARY_COLOR = Color(PRIMARY_COLOR_VALUE);
const PRIMARY_COLOR_DARK = Color(PRIMARY_COLOR_DARK_VALUE);

const PRIMARY_COLOR_MATERIAL = MaterialColor(PRIMARY_COLOR_VALUE, const <int, Color>{
  50:  const Color(0xFFe0e0e0),
  100: const Color(0xFFb3b3b3),
  200: const Color(0xFF808080),
  300: const Color(0xFF4d4d4d),
  400: const Color(0xFF262626),
  500: const Color(PRIMARY_COLOR_VALUE),
  600: const Color(0xFF000000),
  700: const Color(0xFF000000),
  800: const Color(0xFF000000),
  900: const Color(0xFF000000),
},);

const PAGE_SCROLL_TIME_MS = 200;

final BUTTON_STYLE = TextButton.styleFrom(
  backgroundColor: PRIMARY_COLOR,
);

final BUTTON_STYLE_MENU = TextButton.styleFrom(
  backgroundColor: PRIMARY_COLOR,
  elevation: 0,
);

final BUTTON_STYLE_MENU_DARK = TextButton.styleFrom(
  backgroundColor: PRIMARY_COLOR_DARK,
  elevation: 0,
);

const BUTTON_TEXT_STYLE = const TextStyle(color: Colors.white);

const DEBOUNCE_TIMEOUT_MS = 1000;

Widget createButton(String label, void Function() onPressed, [bool? selected]) => ElevatedButton(
  onPressed: onPressed,
  style: selected == null ? BUTTON_STYLE : (selected ? BUTTON_STYLE_MENU_DARK : BUTTON_STYLE_MENU),
  child: Text(label, style: BUTTON_TEXT_STYLE),
);

final marginWidget = SizedBox(
  height: 15,
  width: 15,
);

const titleStyle = TextStyle(fontWeight: FontWeight.bold);

enum Screen {
  Start,
  Accounts,
  Account,
  Records,
  Record,
  Report,
}

class ScreenParams {
  bool newItem;
  int? id;

  ScreenParams({
    this.newItem = false,
    this.id,
  });
}

animateTo(PageController pageController, int page) async {
  await pageController.animateToPage(page, duration: Duration(milliseconds: PAGE_SCROLL_TIME_MS), curve: Curves.linear);
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
            // decoration: BoxDecoration(border: Border.all()),
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
  Future<void> Function()? onLeave;
}

class ScreenItem {
  Widget widget;
  String title;
  ScreenController controller;
  Screen screen;
  ScreenItem({
    required this.screen,
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

  back() async {
    final page = pageController.page!.toInt();
    if (screens[page].controller.onLeave != null) {
      print('awaiting leave');
      await screens[page].controller.onLeave!();
    }
    animateTo(pageController, page - 1);
    processNavigate(page - 1);
  }

  forward() async {
    final page = pageController.page!.toInt();
    if (screens[page].controller.onLeave != null) {
      await screens[page].controller.onLeave!();
    }
    animateTo(pageController, page + 1);
    processNavigate(page + 1);
  }

  move(int toPage) async {
    final page = pageController.page!.toInt();
    if (screens[page].controller.onLeave != null) {
      await screens[page].controller.onLeave!();
    }
    animateTo(pageController, toPage);
    processNavigate(toPage);
  }


  processNavigate([newPage = -1]) {
    setState(() {
      int page = newPage > -1 ? newPage : pageController.page!.toInt();
      if (screens[page].controller.onActivate != null) {
        screens[page].controller.onActivate!();
      }
      title = screens[page].title;
      final screen = screens[page].screen;
      buttons.clear();
      // buttons.add(IconButton(onPressed: page > 0 ? back : null, icon: Icon(Icons.arrow_back)));
      // buttons.add(IconButton(onPressed: page < pageCount ? forward : null, icon: Icon(Icons.arrow_forward)));

      // for (int i = 0; i < screens.length - 1; i++) {
      //   buttons.add(createButton(screens[i].title, () => move(i), i == page));
      //   buttons.add(marginWidget);
      // }

      buttons.add(createButton('План счетов', () => navigate(Screen.Accounts), screen == Screen.Accounts));
      buttons.add(marginWidget);
      buttons.add(createButton('Проводки', () => navigate(Screen.Records), screen == Screen.Records));
      buttons.add(marginWidget);
      buttons.add(createButton('Отчет', () => navigate(Screen.Report), screen == Screen.Report));

    });
  }

  @override
  void initState() {
    final item = ScreenItem(
      screen: Screen.Start,
      widget: ScreenWrapper(StartScreen(appState: this)),
      title: 'Главное',
      controller: ScreenController(),
    );
    screens.add(item);
    screens.add(item);
    processNavigate(0);
    super.initState();

    Db.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
            screen: Screen.Accounts,
            widget: ScreenWrapper(Accounts(appState: this, screenController: controller)),
            title: 'Счета',
            controller: controller,
          );
          screens.add(item);
          break;
        }
        case Screen.Account: {
          final key = UniqueKey();
          final controller = ScreenController();
          final item = ScreenItem(
            screen: Screen.Account,
            widget: ScreenWrapper(Account(appState: this, key: key, itemId: params?.id, controller: controller)),
            title: 'Счет',
            controller: controller,
          );
          screens.add(item);
          break;
        }
        case Screen.Records: {
          final item = ScreenItem(
            screen: Screen.Records,
            widget: Records(appState: this),
            title: 'Проводки',
            controller: ScreenController(),
          );
          screens.add(item);
          break;
        }
        case Screen.Record: {
          final key = UniqueKey();
          final controller = ScreenController();
          final item = ScreenItem(
            screen: Screen.Record,
            widget: ScreenWrapper(Record(appState: this, key: key, itemId: params?.id, controller: controller)),
            title: 'Проводка',
            controller: controller,
          );
          screens.add(item);
          break;
        }
        case Screen.Report: {
          final item = ScreenItem(
            screen: Screen.Report,
            widget: Report(appState: this),
            title: 'Результат',
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
        screen: Screen.Start,
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
