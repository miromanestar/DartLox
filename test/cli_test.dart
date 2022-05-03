import 'package:test/test.dart';
import 'dart:io';

// void main() {
//   test('calculate', () {
//     expect(calculate(), 42);
//   });
// }

void main() {

  test('bruh', () {
      var files = Directory('test/files').listSync();
      print(files);
      
      expect(true, true);
  });
}