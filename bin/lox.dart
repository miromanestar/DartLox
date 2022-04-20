import 'dart:io';
import 'package:DartLox/error.dart';
import 'package:DartLox/interpreter.dart';
import 'package:DartLox/parser.dart';
import 'package:DartLox/types.dart';
import 'package:args/args.dart';

import 'package:DartLox/scanner.dart';

final interpreter = Interpreter();

void runFile(String path) {
  var file = File(path);
  var source = file.readAsStringSync();
  run(source);
}

void runPrompt() {
  print('Starting DartLox REPL');

  ProcessSignal.sigint.watch().listen((signal) {
    print('\nExiting...');
    exit(0);
  });

  while (true) {
    stdout.write('> ');
    var line = stdin.readLineSync();
    if (line == null) {
      break;
    }
    run(line, true);
    hadError = false;
  }
}

void run(String source, [bool isRepl = false]) {
  final scanner = Scanner(source);
  final tokens = scanner.scanTokens();

  if (isRepl) {
    for (var token in tokens) {
      if (token.type == TokenType.SEMICOLON) {
        isRepl = false;
        break;
      }
    }
  }

  final parser = Parser(tokens, isRepl);
  final statements = parser.parse();

  if (hadError) return;

  interpreter.interpret(statements, isRepl);
}

void main(List<String> arguments) {
  final parser = ArgParser()..addOption('file', abbr: 'f');
  ArgResults args = parser.parse(arguments);

  if (args['file'] != null) {
    runFile(args['file']);
  } else if (args.rest.isNotEmpty) {
    runFile(args.rest.first);
  } else {
    runPrompt();
  }
}
