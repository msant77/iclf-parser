import 'dart:io';

String getTestJson() {
  return File('test/fixtures/directives.json').readAsStringSync();
}
