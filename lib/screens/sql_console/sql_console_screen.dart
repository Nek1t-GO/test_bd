import 'package:flutter/material.dart';
import '../../services/query_service.dart';
import '../../widgets/sql_input.dart';
import '../../widgets/result_table.dart';
import '../join_demo/join_demo_screen.dart';
import '../injection/injection_screen.dart';
import '../../services/database_service.dart';
import '../../utils/password_encryptor.dart';

class SqlConsoleScreen extends StatefulWidget {
  const SqlConsoleScreen({super.key});

  @override
  State<SqlConsoleScreen> createState() => _SqlConsoleScreenState();
}

class _SqlConsoleScreenState extends State<SqlConsoleScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    print('Открыт экран: SqlConsoleScreen');
  }

  void _disconnectAndNavigate() async {
    print('Действие: Выход из приложения');
    await DatabaseService().disconnect();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PostgreSQL Client')),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              if (index == 3) {
                _disconnectAndNavigate();
              } else {
                setState(() => _selectedIndex = index);
              }
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.code), label: Text('SQL Console')),
              NavigationRailDestination(icon: Icon(Icons.table_chart), label: Text('Data Base')),
              NavigationRailDestination(icon: Icon(Icons.vaccines), label: Text('Injection')),
              NavigationRailDestination(icon: Icon(Icons.logout), label: Text('Выход')),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _selectedIndex == 0
                ? const _SqlConsoleView()
                : _selectedIndex == 1
                ? const JoinDemoScreen()
                : const InjectionScreen(),
          ),
        ],
      ),
    );
  }
}

class _SqlConsoleView extends StatefulWidget {
  const _SqlConsoleView();

  @override
  State<_SqlConsoleView> createState() => _SqlConsoleViewState();
}

class _SqlConsoleViewState extends State<_SqlConsoleView> {
  final controller = TextEditingController();
  final service = QueryService();
  dynamic result;
  String? error;

  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  String? generatedHash;

  @override
  void initState() {
    super.initState();
    print('Открыт подэкран: SqlConsoleView');
  }

  Future<void> run() async {
    print('Выполнение запроса в SQL Console');
    setState(() {
      error = null;
      result = null;
    });

    try {
      final res = await service.execute(controller.text);
      setState(() => result = res);
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  void generateMd5Hash() {
    final password = passwordController.text;
    final username = usernameController.text;
    if (password.isNotEmpty && username.isNotEmpty) {
      final hash = PasswordEncryptor.md5PasswordHash(password, username);
      setState(() => generatedHash = hash);
    }
  }

  void generateScramHash() {
    final password = passwordController.text;
    if (password.isNotEmpty) {
      final hash = PasswordEncryptor.scramSha256PasswordHash(password);
      setState(() => generatedHash = hash);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SQL Консоль', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SqlInput(controller: controller),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(onPressed: run, child: const Text('Выполнить')),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    print('Действие: Стирание текста в SQL Console');
                    controller.clear();
                  },
                  child: const Text('Стереть'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const Text(
              'Генератор хэшей паролей',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Пароль'),
              obscureText: true,
            ),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Имя пользователя (для MD5)'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(onPressed: generateMd5Hash, child: const Text('MD5 Хэш')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: generateScramHash, child: const Text('SCRAM Хэш')),
              ],
            ),
            if (generatedHash != null) ...[
              const SizedBox(height: 8),
              SelectableText('Сгенерированный хэш: $generatedHash'),
            ],
            const SizedBox(height: 16),
            const Divider(),
            if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
            if (result?.rows != null) ResultTable(rows: result.rows),
            if (result?.message != null) Text(result.message),
          ],
        ),
      ),
    );
  }
}
