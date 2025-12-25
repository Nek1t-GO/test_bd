import 'package:flutter/material.dart';

class SqlInput extends StatelessWidget {
  final TextEditingController controller;
  const SqlInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 5,
      decoration: const InputDecoration(labelText: 'SQL запрос', border: OutlineInputBorder()),
    );
  }
}
