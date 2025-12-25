import 'package:flutter/material.dart';
import '../../services/query_service.dart';
import '../../widgets/result_table.dart';

class JoinDemoScreen extends StatefulWidget {
  const JoinDemoScreen({super.key});

  @override
  State<JoinDemoScreen> createState() => _JoinDemoScreenState();
}

class _JoinDemoScreenState extends State<JoinDemoScreen> {
  final QueryService _service = QueryService();
  dynamic result;
  String? error;
  String _joinSql = '''
SELECT
  c.firstname,
  c.lastname,
  p.brand,
  p.model,
  o.price
FROM orders o
JOIN customers c ON o.customerid = c.customerid
JOIN products p ON o.productid = p.productid;
''';

  String _searchText = '';
  String? _sortColumn;
  bool _sortAsc = true;
  List<Map<String, dynamic>> _filteredRows = [];

  @override
  void initState() {
    super.initState();
    print('Открыт экран: JoinDemoScreen');
  }

  Future<void> _run(String sql) async {
    print('Выполнение запроса в JoinDemoScreen');
    setState(() {
      error = null;
      result = null;
      _filteredRows = [];
    });

    try {
      final res = await _service.execute(sql);
      setState(() => result = res);
      _updateFilteredRows();
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  Future<void> _changeQuery() async {
    final controller = TextEditingController(text: _joinSql);
    final newSql = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выполнить запрос'),
        content: TextField(
          controller: controller,
          maxLines: 10,
          decoration: const InputDecoration(hintText: 'Введите SQL запрос'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Отмена')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    if (newSql != null && newSql.isNotEmpty) {
      setState(() => _joinSql = newSql);
    }
  }

  void _resetFilters() {
    setState(() {
      _searchText = '';
      _sortColumn = null;
      _sortAsc = true;
      _updateFilteredRows();
    });
  }

  void _resetPage() {
    setState(() {
      result = null;
      error = null;
      _searchText = '';
      _sortColumn = null;
      _sortAsc = true;
      _filteredRows = [];
    });
  }

  void _updateFilteredRows() {
    if (result?.rows == null) {
      _filteredRows = [];
      return;
    }
    List<Map<String, dynamic>> rows = List.from(result.rows);

    // Фильтр по поиску
    if (_searchText.isNotEmpty) {
      rows = rows.where((row) {
        return row.values.any(
          (value) => value.toString().toLowerCase().contains(_searchText.toLowerCase()),
        );
      }).toList();
    }

    // Сортировка
    if (_sortColumn != null) {
      rows.sort((a, b) {
        final aVal = a[_sortColumn];
        final bVal = b[_sortColumn];
        if (aVal == null && bVal == null) return 0;
        if (aVal == null) return _sortAsc ? -1 : 1;
        if (bVal == null) return _sortAsc ? 1 : -1;
        if (aVal is String && bVal is String) {
          return _sortAsc ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
        }
        if (aVal is num && bVal is num) {
          return _sortAsc ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
        }
        return 0;
      });
    }

    _filteredRows = rows;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20), // Отступ сверху
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: () {
                    print('Действие: Извлечение данных в JoinDemoScreen');
                    _run(_joinSql);
                  },
                  child: const Text('Извлечь данные'),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        print('Действие: Изменение запроса в JoinDemoScreen');
                        _changeQuery();
                      },
                      child: const Text('Изменить запрос'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        print('Действие: Сброс запроса в JoinDemoScreen');
                        _resetPage();
                      },
                      child: const Text('Сбросить запрос'),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Поиск
            TextField(
              decoration: const InputDecoration(labelText: 'Поиск', prefixIcon: Icon(Icons.search)),
              onChanged: (value) {
                print('Действие: Поиск в JoinDemoScreen: $value');
                setState(() => _searchText = value);
                _updateFilteredRows();
              },
            ),

            const SizedBox(height: 16),

            // Сортировка
            Row(
              children: [
                const Text('Сортировать по: '),
                DropdownButton<String>(
                  value: _sortColumn,
                  items: result?.rows?.isNotEmpty ?? false
                      ? result.rows.first.keys
                            .map<DropdownMenuItem<String>>(
                              (col) => DropdownMenuItem<String>(value: col, child: Text(col)),
                            )
                            .toList()
                      : <DropdownMenuItem<String>>[],
                  onChanged: (value) {
                    print('Действие: Сортировка по колонке в JoinDemoScreen: $value');
                    setState(() => _sortColumn = value);
                    _updateFilteredRows();
                  },
                ),
                const SizedBox(width: 16),
                ToggleButtons(
                  isSelected: [_sortAsc, !_sortAsc],
                  onPressed: (index) {
                    print(
                      'Действие: Изменение порядка сортировки в JoinDemoScreen: ${index == 0 ? "asc" : "desc"}',
                    );
                    setState(() => _sortAsc = index == 0);
                    _updateFilteredRows();
                  },
                  children: const [Text('↑'), Text('↓')],
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {
                    print('Действие: Сброс фильтров в JoinDemoScreen');
                    _resetFilters();
                  },
                  icon: Icon(Icons.restore),
                ),
              ],
            ),

            const SizedBox(height: 24),

            if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),

            if (result?.rows != null) ResultTable(rows: _filteredRows),

            if (result?.message != null) Text(result.message!),
          ],
        ),
      ),
    );
  }
}
