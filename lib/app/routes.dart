import 'package:flutter/material.dart';
import '../screens/connection/connection_screen.dart';
import '../screens/sql_console/sql_console_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (_) => const ConnectionScreen(),
  '/sql': (_) => const SqlConsoleScreen(),
};
