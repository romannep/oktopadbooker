import 'package:oktopadbooker/app.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:desktop_window/desktop_window.dart';


void main() {
  runApp(const MyApp());
  DesktopWindow.setWindowSize(Size(900, 750));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oktopad Booker',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: PRIMARY_COLOR_MATERIAL,
      ),
      localizationsDelegates:
        GlobalMaterialLocalizations.delegates
      ,
      supportedLocales: [
        const Locale('ru'),
        const Locale('en'),
      ],
      home: App(),
    );
  }
}
