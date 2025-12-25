bool isSelectQuery(String sql) {
  return sql.trim().toLowerCase().startsWith('select');
}
