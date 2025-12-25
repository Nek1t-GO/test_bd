class QueryResult {
  final List<Map<String, dynamic>>? rows;
  final String? message;

  QueryResult._({this.rows, this.message});

  factory QueryResult.table(List<Map<String, dynamic>> raw) {
    return QueryResult._(rows: raw);
  }

  factory QueryResult.message(String msg) {
    return QueryResult._(message: msg);
  }
}
