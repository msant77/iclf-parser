import 'package:iclf_parser/iclf_parser.dart';

Future<void> main() async {
  try {
    final parser = await IclfParser.fromUrl(
      'https://raw.githubusercontent.com/msant77/iclf-standard/master/directives.json',
    );

    const sampleContent = '''
{title: Sample Song}
{key: C}
{section: Verse}
[C]Hello [G]world
# Note here
''';

    final result = parser.parse(sampleContent, filePath: 'sample.iclf');

    print('Status: ${result.status}');
    print('Warnings: ${result.warnings}');
    print('Errors: ${result.errors}');
    if (result.song != null) {
      print('Title: ${result.song!.title}');
      print('Key: ${result.song!.key}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
