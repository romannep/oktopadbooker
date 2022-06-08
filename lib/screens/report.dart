

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    // setState(() {
    //   records.clear();
    //   data.forEach((element) {
    //     records.add(DataRow(
    //       onSelectChanged: (_) => openRecord(element['rowid']),
    //       cells: [
    //         createCell(formatDate(DateTime.parse(element['date']))),
    //         createCell('${(element['dtname'] ?? '')}${(element['dtsub'] ?? '') == '' ? '' : '\n[${element['dtsub']}]'}'),
    //         createCell('${(element['ktname'] ?? '')}${(element['ktsub'] ?? '') == '' ? '' : '\n[${element['ktsub']}]'}'),
    //         createCell((element['sum'] as int).toString()),
    //         createCell(element['comment'] ?? ''),
    //       ],
    //     ));
    //   });
    // });
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                DataColumn(label: Text('Дата', style: titleStyle)),
                DataColumn(label: Text('Дт', style: titleStyle)),
                DataColumn(label: Text('Кт', style: titleStyle)),
                DataColumn(label: Text('Сумма', style: titleStyle)),
                DataColumn(label: Text('Комментарий', style: titleStyle)),
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
