
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
          await db.execute(
            'CREATE TABLE flows(record INTEGER, date TEXT, account INTEGER, sub TEXT, do INTEGER, ko INTEGER)',
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

  Future<int> saveRecord(int? id, Map<String, dynamic> record) async {
    print('db saving $record');
    int newId = 0;
    if (id == null) {
      newId = await db.insert(
        'records',
        record,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('inserted to $newId');
    } else {
      await db.update(
        'records',
        record,
        where: 'rowid = ?',
        whereArgs: [id],
      );
      print('updated to $id');
      newId = id;
    }

    await db.delete('flows', where: 'record = ?', whereArgs: [newId]);

    if (record['dt'] != null && record['dt'] > 0 && record['kt'] != null && record['kt'] > 0) {
      await db.insert(
        'flows',
        {
          'record': newId,
          'date': record['date'],
          'account': record['dt'],
          'sub': record['dtsub'],
          'do': record['sum'],
          'ko': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await db.insert(
        'flows',
        {
          'record': newId,
          'date': record['date'],
          'account': record['kt'],
          'sub': record['ktsub'],
          'do': 0,
          'ko': record['sum'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    return newId;
  }

  Future<List<Map<String, dynamic>>> getRecords() async {
    return db.rawQuery('SELECT r.rowid, r.date, r.sum, r.comment, dtsub, ktsub, a.name as dtname, b.name as ktname FROM records r LEFT JOIN accounts a ON r.dt = a.rowid LEFT JOIN accounts b ON r.kt = b.rowid ORDER BY r.date DESC');
  }

  Future<Map<String, dynamic>> getRecord(int id) async {
    final data = await db.query('records', columns: ['date', 'sum', 'comment', 'dt', 'dtsub', 'kt', 'ktsub'], where: 'rowid = ?', whereArgs: [id]);
    return data[0];
  }

  Future<List<Map<String, dynamic>>> getSumFlows(DateTime date, [DateTime? startDate]) async {
    List<Map<String, dynamic>> data;
    if (startDate == null) {
      data = await db.rawQuery('SELECT account, sub, SUM(do), SUM(ko) FROM flows WHERE date < ? GROUP BY account, sub', [date.toIso8601String()]);
    } else {
      data = await db.rawQuery('SELECT account, sub, SUM(do), SUM(ko) FROM flows WHERE date < ? AND date > ? GROUP BY account, sub', [date.toIso8601String(), startDate.toIso8601String()]);
    }
    return data;
  }

  Future<List<Map<String, dynamic>>> getFlows(DateTime startDate, DateTime endDate) async {
    final data = await db.query('flows');
    return data;
  }
}

