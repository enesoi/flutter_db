import 'dart:math';
import 'package:flutter/material.dart';
import 'Employee.dart';

Map<String, dynamic> clickedRow = {
  'index': "",
  'id': "",
  'firstName': "",
  'lastName': "",
  'role': "",
  'email': ""
};

bool isRowClicked = false;

class BareData extends DataTableSource {
  List<Employee> _bData = [];

  BareData(this._bData);
  @override
  DataRow? getRow(int index) {
    return DataRow(
      cells: [
        DataCell(
          Text(_bData[index].id),
          onTap: () => rowClickAction(index),
        ),
        DataCell(Text(_bData[index].firstName),
            onTap: () => rowClickAction(index)),
        DataCell(Text(_bData[index].lastName),
            onTap: () => rowClickAction(index)),
        DataCell(Text(_bData[index].role), onTap: () => rowClickAction(index)),
        DataCell(Text(_bData[index].email), onTap: () => rowClickAction(index)),
      ],
      onSelectChanged: (value) => print("row selected!! $value"),
    );
  }

  void rowClicked(int index) {
    clickedRow = {
      'index': index,
      'id': _bData[index].id,
      'firstName': _bData[index].firstName,
      'lastName': _bData[index].lastName,
      'role': _bData[index].role,
      'email': _bData[index].email
    };

    notifyListeners();
  }

  void rowClickAction(int index) {
    rowClicked(index);
    isRowClicked = true;
  }

  void addData(Employee emp) {
    _bData.add(emp);
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }

  void deleteEntry() {
    if (clickedRow['index'] != "") {
      _bData.removeWhere((emp) =>
          emp.firstName == clickedRow['firstName'] &&
          emp.lastName == clickedRow['lastName'] &&
          emp.email == clickedRow['email']);
    }
    notifyListeners();
  }

  void addList(List<Employee> elist) {
    resetList();
    elist.forEach((element) {
      _bData.add(element);
    });
    notifyListeners();
  }

  List<Employee> getList() {
    return _bData;
  }

  void resetList() {
    _bData.clear();
    notifyListeners();
  }

  void addRole(String? name, String role) {
    if (name == null || role == "") return;

    for (int i = 0; i < _bData.length; i++) {
      if (_bData[i].firstName == name) {
        _bData[i].role = role;
        notifyListeners();
        return;
      }
    }
    notifyListeners();
  }

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;

  @override
  // TODO: implement rowCount
  int get rowCount => _bData.length;

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;
}
