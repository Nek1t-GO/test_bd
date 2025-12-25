import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final _hostController = TextEditingController(text: 'localhost');
  final _portController = TextEditingController(text: '5432');
  final _dbController = TextEditingController(text: 'postgres');
  final _userController = TextEditingController(text: '');
  final _passwordController = TextEditingController(text: '');

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    print('Открыт экран: ConnectionScreen');
  }

  Future<void> _connect() async {
    print('Действие: Подключение к БД в ConnectionScreen');
    setState(() {
      _loading = true;
      _error = null;
    });

    final port = int.tryParse(_portController.text);
    if (port == null) {
      print('Ошибка: Неверный порт');
      setState(() {
        _error = 'Неверный порт';
        _loading = false;
      });
      return;
    }

    try {
      await DatabaseService().connect(
        host: _hostController.text,
        port: port,
        databaseName: _dbController.text,
        username: _userController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;
      print('Действие: Переход на SQL Console');
      Navigator.pushReplacementNamed(context, '/sql');
    } catch (e) {
      print('Ошибка подключения: $e');
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Подключение к PostgreSQL')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _field('Host', _hostController),
            _field('Port', _portController),
            _field('Database', _dbController),
            _field('User', _userController),
            _field('Password', _passwordController, obscure: true),
            const SizedBox(height: 16),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _connect,
                child: _loading ? const CircularProgressIndicator() : const Text('Подключиться'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }
}
