import 'dart:convert';
import 'package:iclf_parser/iclf_parser.dart';
import 'package:test/test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'iclf_parser_test.mocks.dart';
import './fixtures/directives_json.dart';

@GenerateMocks([http.Client])
void main() {
  group('From URL', () {
    test('018 fromUrl loads successfully', () async {
      final mockClient = MockClient();
      when(mockClient.get(Uri.parse('https://example.com'))).thenAnswer(
          (_) async => http.Response.bytes(utf8.encode(getTestJson()), 200));
      final urlParser = await IclfParser.fromUrl('https://example.com',
          httpClient: mockClient);
      expect(urlParser, isA<IclfParser>());
    });
    test('019 fromUrl throws on failure', () async {
      final mockClient = MockClient();
      when(mockClient.get(Uri.parse('https://example.com')))
          .thenAnswer((_) async => http.Response('Error', 404));
      expect(
        () async => await IclfParser.fromUrl('https://example.com',
            httpClient: mockClient),
        throwsException,
      );
    });
  });
}
