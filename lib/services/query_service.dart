import 'database_service.dart';
import '../models/query_result.dart';

class QueryService {
  Future<QueryResult> execute(String sql) async {
    print('Выполнение SQL запроса: $sql');
    final conn = DatabaseService().connection;

    if (sql.trim().toLowerCase().startsWith('select')) {
      final result = await conn.execute(sql);
      final rows = result.map((row) => row.toColumnMap()).toList();
      print('Результат SELECT: ${rows.length} строк');
      return QueryResult.table(rows);
    } else {
      final count = await conn.execute(sql);
      print('Результат команды: $count затронутых строк');
      return QueryResult.message('Affected rows: $count');
    }
  }
}
