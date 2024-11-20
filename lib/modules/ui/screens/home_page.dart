import 'dart:io';

import 'package:flutter/material.dart';

class ZenHomePage extends StatefulWidget {
  const ZenHomePage({super.key});

  @override
  State<ZenHomePage> createState() => ZenHomePageState();
}

class ZenHomePageState extends State<ZenHomePage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> outs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < outs.length; i++)
                      Text(
                        outs[i],
                        style: TextStyle(
                          fontFamily: "Jetbrains Mono",
                          color: i & 0x1 == 0
                              ? Colors.blueAccent
                              : Colors.greenAccent,
                        ), // Para manter o texto visível
                      ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 64,
                  color: const Color.fromARGB(255, 39, 39, 39),
                  child: TextField(
                    focusNode: _focusNode,
                    controller: _controller,
                    onSubmitted: (String value) {
                      _executeCommand(value);
                      _controller.text = "";
                      _focusNode.requestFocus();
                    },
                    textAlignVertical: TextAlignVertical.center,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      border: InputBorder.none,
                      hintText: 'Type a command',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              Container(
                width: 64,
                height: 64,
                color: Colors.grey,
                child: IconButton(
                  onPressed: () {
                    _executeCommand(_controller.text);
                    _controller.text = "";
                    _focusNode.requestFocus();
                  },
                  icon: const Icon(Icons.send, color: Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<String> parseCommand(String command) {
    int current = 0;
    int start = 0;
    List<String> tokens = [];

    List<String> validCharacters = [".", "-", "/", ":", "@"];

    bool isAtEnd() {
      return current >= command.length;
    }

    String advance() {
      return command[current++];
    }

    String peek() {
      return command[current];
    }

    void makeToken() {
      tokens.add(command.substring(start, current));
    }

    void makeTokenLexeme(String lexeme) {
      tokens.add(lexeme);
    }

    void string() {
      while (peek() != "\"" && !isAtEnd()) {
        advance();
      }

      advance();
      makeTokenLexeme(command.substring(start + 1, current - 1));
    }

    bool isAlphanumeric(String c) {
      int zero = "0".codeUnits[0];
      int nine = "9".codeUnits[0];

      int aLower = "a".codeUnits[0];
      int zLower = "z".codeUnits[0];
      int aUpper = "A".codeUnits[0];
      int zUpper = "Z".codeUnits[0];

      int codeUnit = c.codeUnits[0];

      return (codeUnit >= zero && codeUnit <= nine) ||
          (codeUnit >= aLower && codeUnit <= zLower) ||
          (codeUnit >= aUpper && codeUnit <= zUpper) ||
          validCharacters.contains(c);
    }

    void identifier() {
      while (!isAtEnd() && isAlphanumeric(peek())) {
        advance();
      }

      makeToken();
    }

    void scanToken() {
      String c = advance();

      switch (c) {
        case ' ':
        case '\n':
        case '\t':
        case '\r':
          break;

        case "\"":
          {
            string();
            break;
          }

        case ".":
          makeToken();
          break;

        default:
          identifier();
      }
    }

    while (!isAtEnd()) {
      start = current;
      scanToken();
    }

    return tokens;
  }

  void _executeCommand(String command) async {
    if (command.isEmpty) return;

    if (command == "cls") {
      setState(() {
        outs.clear();
      });

      return;
    }

    String procName = command.split(" ")[0];
    List<String> args = parseCommand(command).sublist(1);

    debugPrint(args.toString());

    // Inicia o processo de maneira assíncrona
    Process process = await Process.start(procName, args);

    // Ouvindo a saída à medida que ela chega
    process.stdout.transform(SystemEncoding().decoder).listen((data) {
      setState(() {
        // Adiciona a linha de saída ao histórico de saída
        outs.add(data);
      });
    });

    // Também ouve erros, caso existam
    process.stderr.transform(SystemEncoding().decoder).listen((data) {
      setState(() {
        outs.add("Error: $data");
      });
    });

    // Aguarda o término do processo (para garantir que ele terminou)
    await process.exitCode;
  }
}
