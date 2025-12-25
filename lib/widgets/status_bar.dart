import 'package:flutter/material.dart';

class StatusBar extends StatelessWidget {
  final String text;
  const StatusBar({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(8), child: Text(text));
  }
}
