import 'package:flutter/material.dart';

class ZenConsoleLine extends StatelessWidget {
  const ZenConsoleLine({super.key, required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(value);
  }
}
