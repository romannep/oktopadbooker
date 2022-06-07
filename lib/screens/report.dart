

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
DateTime endOfDay(DateTime date) => DateTime(date.year, date.month, date.day, 23, 59, 999);

class ReportState extends State<Report> {
  final AppState appState;

  ReportState({ required this.appState });

  final List<DataRow> reportData = [];
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  @override
  initState() {
    startDate = startOfDay(startDate);
    endDate = endOfDay(endDate);
    onActivate();
  }

  onActivate() async {
    final data = await Db.instance.getBalance(startDate);
    print('got records $data');
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

  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        createButton('Добавить новую проводку', newAccount),
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
