import 'package:flutter/material.dart';
import 'package:zen/modules/ui/screens/home_page.dart';

class ZenTerminal extends StatefulWidget {
  const ZenTerminal({super.key});

  @override
  State<ZenTerminal> createState() => _ZenTerminalState();
}

class _ZenTerminalState extends State<ZenTerminal> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ZenHomePage(),
    );
  }
}
