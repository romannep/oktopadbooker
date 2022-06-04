
import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const APP_FOLDER = 'Oktopad Booker';
const DB_FILENAME = 'booker.db';

class Db {
  static final instance = Db();

  late Database db;
  init() async {
    Map<String, String> envVars = Platform.environment;
    print('User homedir: ${envVars['UserProfile']}');
    final path= Directory('${envVars['UserProfile']}/$APP_FOLDER');
    if ((await path.exists())){
      print('Path exist');
    }else{
      await path.create();
      print('Path created');
    }
    final dbPath = '${envVars['UserProfile']}/$APP_FOLDER/$DB_FILENAME';
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    db = await openDatabase(
      dbPath,
      onCreate: (db, version) {
        print('on create');
        return () async {
          await db.execute(
            'CREATE TABLE accounts(name TEXT, active INTEGER, sub TEXT, hidesubbalance INTEGER)',
          );
          await db.execute(
            'CREATE TABLE records(date TEXT, sum INTEGER, comment TEXT, dt INTEGER, dtsub TEXT, kt INTEGER, ktsub TEXT)',
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

  Future<int> saveAccount(int? id, Map<String, dynamic> account) async {
    print('db saving $account');
    if (id == null) {
      final newId = await db.insert(
        'accounts',
        account,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('inserted to $newId');
      return newId;
    } else {
      await db.update(
        'accounts',
        account,
        where: 'rowid = ?',
        whereArgs: [id],
      );
      print('updated to $id');
      return id;
    }
  }

  Future<List<Map<String, dynamic>>> getAccounts() async {
    return db.query('accounts', columns: ['name', 'active', 'sub', 'rowid'], orderBy: 'name');
  }

  Future<Map<String, dynamic>> getAccount(int id) async {
    final data = await db.query('accounts', columns: ['name', 'active', 'sub', 'hidesubbalance'], where: 'rowid = ?', whereArgs: [id]);
    return data[0];
  }
}

