import 'package:flutter/material.dart';
import '../../services/query_service.dart';
import '../../widgets/result_table.dart';

class InjectionScreen extends StatefulWidget {
  const InjectionScreen({super.key});

  @override
  State<InjectionScreen> createState() => _InjectionScreenState();
}

class _InjectionScreenState extends State<InjectionScreen> {
  final QueryService _service = QueryService();
  final TextEditingController _productIdController = TextEditingController();

  dynamic result;
  String? error;

  String _selectedInjection = 'Без инъекции';

  @override
  void initState() {
    super.initState();
    print('Открыт экран: InjectionScreen');
  }

  final Map<String, String> injections = {
    'Без инъекции': '',

    // 1. Получение скрытых данных
    'Получение скрытых данных': "1 OR 1=1",

    // 2. Подрыв логики приложения
    'Подрыв логики приложения': "1 OR price > 0",

    // 3. UNION-инъекция
    'UNION-инъекция': "1 UNION SELECT customerid, firstname, lastname, NULL FROM customers",

    // 4. Изучение структуры БД
    'Изучение БД': "1 UNION SELECT NULL, version(), NULL, NULL",
  };

  Future<void> _getProduct() async {
    print('Получение продукта в InjectionScreen');
    setState(() {
      error = null;
      result = null;
    });

    final input = _selectedInjection == 'Без инъекции'
        ? _productIdController.text
        : injections[_selectedInjection]!;

    final sql =
        '''
SELECT productid, brand, model, price
FROM products
WHERE productid = $input;
''';

    try {
      final res = await _service.execute(sql);
      setState(() => result = res);
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  void _resetProduct() {
    setState(() {
      _productIdController.clear();
      _selectedInjection = 'Без инъекции';
      result = null;
      error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _productIdController,
                decoration: const InputDecoration(
                  labelText: 'ID продукта',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              DropdownButton<String>(
                value: _selectedInjection,
                items: injections.keys
                    .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedInjection = value!);
                },
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  ElevatedButton(onPressed: _getProduct, child: const Text('Получить продукт')),
                  const SizedBox(width: 12),
                  ElevatedButton(onPressed: _resetProduct, child: const Text('Сбросить продукт')),
                ],
              ),

              const SizedBox(height: 24),

              if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),

              if (result?.rows != null) ResultTable(rows: result.rows),

              if (result?.message != null) Text(result.message!),
            ],
          ),
        ),
      ),
    );
  }
}
