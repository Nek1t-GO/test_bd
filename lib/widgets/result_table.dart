import 'package:flutter/material.dart';

class ResultTable extends StatelessWidget {
  final List<Map<String, dynamic>> rows;

  const ResultTable({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const Text('Нет данных');

    final columns = rows.first.keys.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns.map((c) => DataColumn(label: Text(c))).toList(),
        rows: rows
            .map(
              (row) =>
                  DataRow(cells: columns.map((c) => DataCell(Text(row[c].toString()))).toList()),
            )
            .toList(),
      ),
    );
  }
}
