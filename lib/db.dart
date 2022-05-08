
import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Db {
  static final instance = Db();

  late Database db;
  init() async {
    Map<String, String> envVars = Platform.environment;
    print('User homedir: ${envVars['UserProfile']}');
    final path= Directory('${envVars['UserProfile']}/Oktopad Upshot');
    if ((await path.exists())){
      print('Path exist');
    }else{
      await path.create();
      print('Path created');
    }
    final dbPath = '${envVars['UserProfile']}/Oktopad Upshot/upshot.db';
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    db = await openDatabase(dbPath);
    print('Db open success');
  }

  close() async {
    await db.close();
  }
}
