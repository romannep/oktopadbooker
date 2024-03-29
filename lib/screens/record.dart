
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:oktopadbooker/db.dart';

import '../app.dart';

formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2,'0')}.${date.month.toString().padLeft(2,'0')}.${date.year}';
}


// date, dt, kt, sum, comment

class Record extends StatefulWidget {
  final AppState appState;
  final int? itemId;
  final ScreenController controller;

  Record({
    required this.appState,
    this.itemId,
    required this.controller,
    Key? key,
  }): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AccountState();
  }

}


class AccountState extends State<Record> with AutomaticKeepAliveClientMixin<Record> {

  late int? itemId;
  DateTime date = DateTime.now();
  int? dt;
  int? dtSubIndex;
  int? kt;
  int? ktSubIndex;
  late TextEditingController textCommentController;
  late TextEditingController textSumController;

  Timer? _changeTimer;

  _dataChange() {
    if (_changeTimer != null) {
      _changeTimer!.cancel();
      _changeTimer = null;
    }
    _changeTimer = new Timer(Duration(milliseconds: DEBOUNCE_TIMEOUT_MS), _saveData);
  }

  Future<void> _saveData() async {
    if (_changeTimer != null) {
      _changeTimer!.cancel();
      _changeTimer = null;
    }

    final newId = await Db.instance.saveRecord(itemId, {
      'date': date.toIso8601String(),
      'sum':  int.parse(textSumController.text == '' ? '0' : textSumController.text),
      'comment': textCommentController.text,
      'dt': dt,
      'dtsub': (dtSubIndex ?? -1) > -1 ? _dtSubs[dtSubIndex!] : '',
      'kt': kt,
      'ktsub': (ktSubIndex ?? -1) > -1 ? _ktSubs[ktSubIndex!] : '',
    });
    itemId = newId;
  }

  _loadData() async {
    if (itemId == null) {
      return;
    }
    final data = await Db.instance.getRecord(itemId!);
    setState(() {
      textSumController.text = (data['sum'] as int).toString();
      textCommentController.text = data['comment'];
      dt = data['dt'];
      kt = data['kt'];
      if (dt != null) {
        _updateDtSubAccounts(data['dtsub'] ?? '');
      }
      if (kt != null) {
        _updateKtSubAccounts(data['ktsub'] ?? '');
      }
      date = DateTime.parse(data['date']);
    });
  }

  @override
  void initState() {
    itemId = widget.itemId;
    textCommentController = TextEditingController();
    textSumController = TextEditingController();
    widget.controller.onLeave = _saveData;
    asyncInit();
    super.initState();
  }

  asyncInit() async {
    await _loadAccounts();
    await _loadData();
    textCommentController.addListener(_dataChange);
    textSumController.addListener(_dataChange);
  }

  List<Map<String, dynamic>> _accounts = [];
  List<String> _dtSubs = [];
  List<String> _ktSubs = [];

  _loadAccounts() async {
    final accountsData = await Db.instance.getAccounts();
    setState(() {
      _accounts = accountsData;
    });
  }

  _updateDtSubAccounts([String sub = '']) {
    final dtAcc = _accounts.firstWhereOrNull((e) => e['rowid'] == dt);
    setState(() {
      dtSubIndex = null;
      if (dtAcc != null && dtSubIndex == null) {
        _dtSubs = (jsonDecode(dtAcc['sub']) as List<dynamic>).cast<String>();
        if (sub != '') {
          final index = _dtSubs.indexWhere((element) => element == sub);
          if (index > -1) {
            dtSubIndex = index;
          }
        }
      }
    });
  }

  _updateKtSubAccounts([String sub = '']) {
    final ktAcc = _accounts.firstWhereOrNull((e) => e['rowid'] == kt);
    setState(() {
      ktSubIndex = null;
      if (ktAcc != null && ktSubIndex == null) {
        _ktSubs = (jsonDecode(ktAcc['sub']) as List<dynamic>).cast<String>();
        if (sub != '') {
          final index = _ktSubs.indexWhere((element) => element == sub);
          if (index > -1) {
            ktSubIndex = index;
          }
        }
      }
    });
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200)
    );
    if (picked != null && picked != date) {
      setState(() {
        date = picked;
        _dataChange();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        createButton('← к Списку проводок', () => widget.appState.back()),
        marginWidget, marginWidget,
        Row(
          children: [
            Flexible(
              flex: 1,
              child: Row(
                children: [
                  Text(formatDate(date.toLocal())),
                  IconButton(onPressed: () => _selectDate(context), icon: Icon(Icons.calendar_month)),
                ],
              ),
            ),
            marginWidget,
            Flexible(
              flex: 1,
              child: TextField(
                controller: textSumController,
                decoration: InputDecoration(labelText: 'Сумма'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'-?[0-9]')),
                ],
              ),
            ),
            marginWidget,
            Flexible(
              flex: 3,
              child: TextField(
                controller: textCommentController,
                decoration: InputDecoration(labelText: 'Комментарий'),
              ),
            ),
          ],
        ),
        marginWidget,marginWidget,
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text('Дт', style: titleStyle),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(labelText: 'Счет'),
                    value: dt,
                    items: _accounts.map((e) => DropdownMenuItem(
                      value: e['rowid'] as int,
                      child: Text(e['name']),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        dt = value;
                      });
                      _updateDtSubAccounts();
                      _dataChange();
                    },
                  ),
                  marginWidget,
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(labelText: 'Субсчет'),
                    value: dtSubIndex,
                    items: _dtSubs.mapIndexed((index, e) => DropdownMenuItem(
                      value: index,
                      child: Text(e),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        dtSubIndex = value;
                      });
                      _dataChange();
                    },
                  ),

                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
            marginWidget,marginWidget,
            Expanded(
              child: Column(
                children: [
                  Text('Кт', style: titleStyle),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(labelText: 'Счет'),
                    value: kt,
                    items: _accounts.map((e) => DropdownMenuItem(
                      value: e['rowid'] as int,
                      child: Text(e['name']),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        kt = value;
                      });
                      _updateKtSubAccounts();
                      _dataChange();
                    },
                  ),
                  marginWidget,
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(labelText: 'Субсчет'),
                    value: ktSubIndex,
                    items: _ktSubs.mapIndexed((index, e) => DropdownMenuItem(
                      value: index,
                      child: Text(e),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        ktSubIndex = value;
                      });
                      _dataChange();
                    },
                  ),

                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _saveData();
    super.dispose();
  }
}
