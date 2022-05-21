
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
    db = await openDatabase(
      dbPath,
      onCreate: (db, version) {
        print('on create');
        return () async {
          await db.execute(
            'CREATE TABLE accounts(name TEXT, active INTEGER, sub TEXT)',
          );
        }();
      },
      onUpgrade: (db, oldVersion, newVersion) {
        // return () async {
        //   await db.execute(
        //     'CREATE TABLE accounts(name TEXT, active INTEGER, sub TEXT)',
        //   );
        // }();
      },
      version: 1,
    );
    print('Db open success');
  }

  close() async {
    await db.close();
  }

  saveAccount(Map<String, dynamic> account) async {
    print('db saving $account');
    final id = await db.insert(
      'accounts',
      account,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('saved to $id');
  }

  Future<List<Map<String, dynamic>>> getAccounts() async {
    return db.query('accounts', columns: ['name', 'active', 'sub', 'rowid'], orderBy: 'name');
  }
}


class DbAccount {
  // final int id;
  final String name;
  final bool active;
  final String subAccounts;

  DbAccount({
    // required this.id,
    required this.name,
    required this.active,
    required this.subAccounts,
  });

  Map<String, dynamic> toMap() {
    return {
      // 'id': id,
      'name': name,
      'active': active ? 1 : 0,
      'sub': subAccounts,
    };
  }
}
