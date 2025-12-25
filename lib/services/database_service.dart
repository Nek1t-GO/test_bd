import 'package:postgres/postgres.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Connection? _connection;
  bool _isConnected = false;

  bool get isConnected => _connection != null && _isConnected;

  Future<void> connect({
    required String host,
    required int port,
    required String databaseName,
    required String username,
    required String password,
  }) async {
    print('Подключение к БД: $host:$port/$databaseName как $username');
    if (_isConnected) await disconnect();
    final endpoint = Endpoint(
      host: host,
      port: port,
      database: databaseName,
      username: username,
      password: password,
    );

    _connection = await Connection.open(
      endpoint,
      settings: ConnectionSettings(sslMode: SslMode.disable),
    );
    _isConnected = true;
    print('Подключение к БД успешно');
  }

  Connection get connection {
    if (!isConnected) {
      throw Exception('Нет подключения к БД');
    }
    return _connection!;
  }

  Future<void> disconnect() async {
    print('Отключение от БД');
    await _connection?.close();
    _connection = null;
    _isConnected = false;
    print('Отключение от БД завершено');
  }
}
