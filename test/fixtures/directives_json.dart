import 'dart:io';

/// Loads directives.json from the canonical source in iclf-standard.
/// Single source of truth for the ICLF specification.
String getTestJson() {
  return File('../iclf-standard/directives.json').readAsStringSync();
}
