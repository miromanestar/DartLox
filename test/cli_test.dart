import 'package:test/test.dart';
import 'dart:io';

void main() {
  var files = Directory('test/files').listSync();

  for (var file in files) {
    final name = file.uri.pathSegments.last.split('.').first;
    final ext = file.uri.pathSegments.last.split('.').last;
    
    if (ext == 'lox') {
      final expected = File('test/files/$name.test').readAsStringSync();
      test(name, () async {
        var f = Directory('.').listSync();
        print(f);
        final process = await Process.start('dart run', ['bin/lox.dart', '${file.path}']);
        final result = process.stdout;

        expect(result.toString(), expected);
      });
    }
  }
}