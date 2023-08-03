import 'dart:math';
import 'package:flutter/material.dart';
import 'Employee.dart';

class MyData extends DataTableSource {
  final List<Employee> _sdata = List.generate(
      200,
      (index) => Employee(
          id: "$index",
          firstName: "Ad ${Random().nextInt(100)}",
          lastName: "Ad ${Random().nextInt(1000)}",
          role: Random().nextBool() ? "Admin" : "User",
          email: "${Random().nextInt(1393)}@gmail.com"));
  @override
  DataRow? getRow(int index) {
    return DataRow(cells: [
      DataCell(Text(_sdata[index].id)),
      DataCell(Text(_sdata[index].firstName)),
      DataCell(Text(_sdata[index].lastName)),
      DataCell(Text(_sdata[index].role)),
      DataCell(Text(_sdata[index].email)),
    ]);
  }

  @override
  // todo: implement isRowCountApproximate
  bool get isRowCountApproximate => false;

  @override
  // todo: implement rowCount
  int get rowCount => _sdata.length;

  @override
  // todo: implement selectedRowCount
  int get selectedRowCount => 0;
}
