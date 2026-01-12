import 'package:iclf_parser/iclf_parser.dart';

void main() {
  const directivesJson = '...'; // Paste JSON string
  final parser = IclfParser(directivesJson);
  final content = '{title: Test}\n[Am]Hello';
  final result = parser.parse(content);
  print(result.status);
}
