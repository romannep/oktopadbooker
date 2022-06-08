

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:oktopadbooker/app.dart';
import 'package:oktopadbooker/screens/record.dart';

import '../db.dart';

class Report extends StatefulWidget {
  final AppState appState;

  Report({ required this.appState, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new ReportState(appState: appState);
  }

}

DataCell createCell (String text, [TextStyle? style= null]) =>
    DataCell(Text(text, style: style));


DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);
DateTime endOfDay(DateTime date) => DateTime(date.year, date.month, date.day +1).subtract(Duration(milliseconds: 1));
DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month, 1);
DateTime endOfMont(DateTime date) => DateTime(date.year, date.month + 1, 0).add(Duration(days: 1)).subtract(Duration(milliseconds: 1));

class ReportRow {
  String account;
  int accountId;
  bool active;
  bool isSubAccount;

  int? snd;
  int? snk;
  int? dto;
  int? kto;
  int? skd;
  int? skk;

  ReportRow(this.accountId, this.account, this.active, this.isSubAccount);
}


class ReportState extends State<Report> {
  final AppState appState;

  ReportState({ required this.appState });

  final List<DataRow> reportData = [];
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  @override
  initState() {
    startDate = startOfMonth(startDate);
    endDate = endOfMont(endDate);
    formReport();
  }

  formReport() async {
    final saldo = await Db.instance.getSumFlows(startDate);
    final flows = await Db.instance.getSumFlows(endDate, startDate);
    print('got saldo $saldo');
    print('got flows $flows');

    final List<ReportRow> data = [];
    final accountsData = await Db.instance.getAccounts();
    accountsData.forEach((element) {
      data.add(ReportRow(element['rowid'], element['name'], element['active'] == 1, false));
      final sub = (jsonDecode(element['sub']) as List<dynamic>).cast<String>();
      sub.forEach((subName) => data.add(ReportRow(element['rowid'], subName, element['active'] == 1, true)));
    });

    data.sort((a, b) => (a.active == b.active ? 0 : (a.active ? -1 : 1)));

    flows.forEach((flow) {
      final row = data.firstWhere((element) => element.accountId == flow['account'] && (flow['sub'] == '' || flow['sub'] == element.account));
      row.dto = flow['SUM(do)'];
      row.kto = flow['SUM(ko)'];
      if (row.isSubAccount) {
        final parent = data.firstWhere((element) => element.accountId == row.accountId && element.isSubAccount == false);
        parent.dto = (parent.dto ?? 0) + row.dto!;
        parent.kto = (parent.kto ?? 0) + row.kto!;
      }
    });

    saldo.forEach((item) {
      final row = data.firstWhere((element) => element.accountId == item['account'] && (item['sub'] == '' || item['sub'] == element.account));
      int result = item['SUM(do)'] - item['SUM(ko)'];
      if (row.active) {
        row.snd = result;
      } else {
        row.snk = -result;
      }

      if (row.isSubAccount) {
        final parent = data.firstWhere((element) => element.accountId == row.accountId && element.isSubAccount == false);
        if (row.active) {
          parent.snd = (parent.snd ?? 0) + result;
        } else {
          parent.snk = (parent.snk ?? 0) - result;
        }
      }
    });

    setState(() {
      reportData.clear();
      data.forEachIndexed((index, element) {
        final style = data[index].isSubAccount ? null : titleStyle;
        reportData.add(DataRow(
          cells: [
            createCell('${data[index].isSubAccount ? '- ' : ''}${data[index].account}', style),
            createCell('${data[index].snd ?? ''}', style),
            createCell('${data[index].snk ?? ''}', style),
            createCell('${data[index].dto ?? ''}', style),
            createCell('${data[index].kto ?? ''}', style),
            createCell('${data[index].skd ?? ''}', style),
            createCell('${data[index].skk ?? ''}', style),
          ],
        ));
      });
    });
  }

  openRecord(int id) {
    appState.navigate(Screen.Record, ScreenParams(id: id));
  }

  newAccount() {
    appState.navigate(Screen.Record, ScreenParams(newItem: true));
  }

  _selectDate(BuildContext context, bool setStartDate) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: (setStartDate ? startDate : endDate),
        firstDate: DateTime(1900),
        lastDate: DateTime(2200)
    );
    if (picked != null && picked != (setStartDate ? startDate : endDate)) {
      setState(() {
        if (setStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
        formReport();
      });
    }
  }

  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        marginWidget,
        marginWidget,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Период с:'),
            marginWidget,
            Text(formatDate(startDate.toLocal())),
            IconButton(onPressed: () => _selectDate(context, true), icon: Icon(Icons.calendar_month)),
            marginWidget,
            Text('по:'),
            marginWidget,
            Text(formatDate(endDate.toLocal())),
            IconButton(onPressed: () => _selectDate(context, false), icon: Icon(Icons.calendar_month)),
          ],
        ),
        marginWidget,
        Expanded(
          child: Scrollbar(controller: scrollController, isAlwaysShown: true, child: SingleChildScrollView(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(child: DataTable(
              showCheckboxColumn: false,
              columns: [
                DataColumn(label: Text('Счет', style: titleStyle)),
                DataColumn(label: Text('СНД', style: titleStyle)),
                DataColumn(label: Text('СНК', style: titleStyle)),
                DataColumn(label: Text('ДО', style: titleStyle)),
                DataColumn(label: Text('КО', style: titleStyle)),
                DataColumn(label: Text('СКД', style: titleStyle)),
                DataColumn(label: Text('СКК', style: titleStyle)),
              ],
              // defaultColumnWidth: const IntrinsicColumnWidth(),
              rows: reportData,
            )),
          )),
        ),
      ],
    );

  }
}
