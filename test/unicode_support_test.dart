import 'package:iclf_parser/iclf_parser.dart';
import 'package:test/test.dart';
import './fixtures/directives_json.dart';

void main() {
  group('Unicode Support', () {
    late IclfParser parser;
    setUp(() {
      parser = IclfParser(getTestJson());
    });
    test('012 handles unicode lyrics', () {
      const content =
          '{title: Águas de Março}\n{key: Bb}\n[Bb7/Ab]É [Gm6]pau, é [Ebmmaj7/Gb]pedra, é o [Bb]fim do caminho,';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.valid);
      expect(result.song?.title, 'Águas de Março');
      expect(result.song?.sections.first.chords.last.lyrics, 'fim do caminho,');
    });
    test('013 handles Japanese lyrics', () {
      const content =
          '{title: 怨み節}\n{key: Am}\n[Am] [E] [Dm] Hana yo Kirei to, Odaterare,';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.valid);
      expect(result.song?.title, '怨み節');
      expect(result.song?.sections.first.chords.last.lyrics,
          ' Hana yo Kirei to, Odaterare,');
    });
  });
}
