import 'package:iclf_parser/iclf_parser.dart';
import 'package:test/test.dart';

void main() {
  test('fetches and parses from real URL', () async {
    final parser = await IclfParser.fromUrl(
        'https://raw.githubusercontent.com/msant77/iclf-standard/master/directives.json');
    expect(parser, isA<IclfParser>());
    // Add assertions on parser internals if needed
  });
}
