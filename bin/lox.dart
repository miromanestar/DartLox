import 'dart:io';
import 'package:args/args.dart';

import 'package:DartLox/scanner.dart';

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
    run(line);
  }
}

void run(String source) {
  final scanner = new Scanner(source);
  final tokens = scanner.scanTokens();

  for (var token in tokens) {
    print(token);
  }
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
