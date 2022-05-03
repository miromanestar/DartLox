import 'package:test/test.dart';
import 'dart:io';

void main() {
  var files = Directory('test/auto').listSync();

  for (var file in files) {
    final name = file.uri.pathSegments.last.split('.').first;
    final ext = file.uri.pathSegments.last.split('.').last;
    
    if (ext == 'lox') {
      final expected = File('test/auto/$name.test').readAsStringSync()
        .replaceAll('\r\n', '\n').trim();
        
      test(name, () async {
        final process = await Process.run('dart', ['run', './bin/lox.dart', file.path]);
        final result = process.stdout.replaceAll('\r\n', '\n').trim();

        expect(result, expected);
      });
    }
  }
}