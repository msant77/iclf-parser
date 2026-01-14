import 'dart:io';
import 'package:args/args.dart';
import '../parser.dart';
import '../models.dart';
import 'renderer.dart';

/// CLI command runner for the ICLF parser
class CliRunner {
  static const String _version = '1.0.0';
  static const String _defaultConfigUrl =
      'https://raw.githubusercontent.com/msant77/iclf-standard/master/directives.json';

  /// Runs the CLI with the given arguments
  /// Returns exit code (0 for success, non-zero for errors)
  Future<int> run(List<String> arguments) async {
    final parser = _buildArgParser();

    try {
      final results = parser.parse(arguments);

      if (results['help'] as bool) {
        _printUsage(parser);
        return 0;
      }

      if (results['version'] as bool) {
        print('iclf version $_version');
        return 0;
      }

      final command = results.command;
      if (command == null) {
        _printUsage(parser);
        return 0;
      }

      if (command.name == 'render') {
        return await _runRender(command);
      }

      _printUsage(parser);
      return 1;
    } on FormatException catch (e) {
      stderr.writeln('Error: ${e.message}');
      stderr.writeln('Run "iclf --help" for usage information.');
      return 1;
    }
  }

  ArgParser _buildArgParser() {
    final parser = ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false, help: 'Show this help message')
      ..addFlag('version', negatable: false, help: 'Show version number');

    final renderParser = ArgParser()
      ..addOption('output',
          abbr: 'o', help: 'Write output to file instead of stdout')
      ..addOption('config',
          abbr: 'c',
          help: 'Custom directives.json URL or local file path',
          defaultsTo: _defaultConfigUrl)
      ..addOption('width',
          abbr: 'w', help: 'Maximum line width', defaultsTo: '80')
      ..addFlag('compact', help: 'Compact output (no blank lines between sections)')
      ..addFlag('verbose', abbr: 'v', help: 'Show verbose parsing information')
      ..addFlag('help', abbr: 'h', negatable: false, help: 'Show render help');

    parser.addCommand('render', renderParser);

    return parser;
  }

  Future<int> _runRender(ArgResults args) async {
    // Check for help flag on render command
    if (args['help'] as bool) {
      _printRenderUsage();
      return 0;
    }

    if (args.rest.isEmpty) {
      stderr.writeln('Error: No input file specified');
      stderr.writeln('Usage: iclf render <file.iclf> [options]');
      return 1;
    }

    final filePath = args.rest.first;
    final file = File(filePath);

    if (!await file.exists()) {
      stderr.writeln('Error: File not found: $filePath');
      return 1;
    }

    // Load parser
    final configPath = args['config'] as String;
    IclfParser iclfParser;
    try {
      // Check if it's a local file path
      if (!configPath.startsWith('http://') && !configPath.startsWith('https://')) {
        final configFile = File(configPath);
        if (!await configFile.exists()) {
          stderr.writeln('Error: Config file not found: $configPath');
          return 1;
        }
        final jsonContent = await configFile.readAsString();
        iclfParser = IclfParser(jsonContent);
      } else {
        iclfParser = await IclfParser.fromUrl(configPath);
      }
    } catch (e) {
      stderr.writeln('Error loading configuration: $e');
      stderr.writeln('Tip: Check your network connection or use --config with a local file path.');
      return 1;
    }

    final verbose = args['verbose'] as bool;

    // Parse file
    final content = await file.readAsString();

    if (verbose) {
      stderr.writeln('[verbose] Parsing file: $filePath');
      stderr.writeln('[verbose] File size: ${content.length} bytes');
      stderr.writeln('[verbose] Config: $configPath');
    }

    final result = iclfParser.parse(content, filePath: filePath);

    if (verbose) {
      stderr.writeln('[verbose] Parse status: ${result.status}');
      stderr.writeln('[verbose] Errors: ${result.errors.length}');
      stderr.writeln('[verbose] Warnings: ${result.warnings.length}');
      if (result.song != null) {
        stderr.writeln('[verbose] Title: ${result.song!.title}');
        stderr.writeln('[verbose] Key: ${result.song!.key}');
        stderr.writeln('[verbose] Sections: ${result.song!.sections.length}');
        for (var i = 0; i < result.song!.sections.length; i++) {
          final section = result.song!.sections[i];
          stderr.writeln('[verbose]   Section[$i]: ${section.name} (${section.chords.length} chords)');
        }
      }
    }

    // Handle parse errors
    if (result.status == ParseStatus.invalid) {
      stderr.writeln('Parse errors:');
      for (final error in result.errors) {
        stderr.writeln('  - $error');
      }
      return 1;
    }

    // Show warnings
    for (final warning in result.warnings) {
      stderr.writeln('Warning: $warning');
    }

    // Parse width option
    int width;
    try {
      width = int.parse(args['width'] as String);
      if (width < 40) {
        stderr.writeln('Warning: Width too small, using minimum of 40');
        width = 40;
      }
    } catch (e) {
      stderr.writeln('Error: Invalid width value');
      return 1;
    }

    // Render
    final renderer = IclfRenderer(
      maxWidth: width,
      compact: args['compact'] as bool,
    );

    final output = renderer.render(result.song!);

    // Output
    final outputPath = args['output'] as String?;
    if (outputPath != null) {
      await File(outputPath).writeAsString(output);
      print('Output written to: $outputPath');
    } else {
      stdout.write(output);
    }

    return 0;
  }

  void _printUsage(ArgParser parser) {
    print('ICLF Parser - Inline Chorded Lyrics Format CLI');
    print('');
    print('Usage: iclf <command> [arguments]');
    print('');
    print('Commands:');
    print('  render <file>   Render an ICLF file as a chord sheet');
    print('');
    print('Global options:');
    print(parser.usage);
    print('');
    print('Run "iclf render --help" for render command options.');
  }

  void _printRenderUsage() {
    print('Render an ICLF file as a formatted chord sheet.');
    print('');
    print('Usage: iclf render <file.iclf> [options]');
    print('');
    print('Options:');
    print('  -o, --output <file>   Write output to file instead of stdout');
    print('  -w, --width <num>     Maximum line width (default: 80)');
    print('  --compact             Compact output (no blank lines between sections)');
    print('  -v, --verbose         Show verbose parsing information');
    print('  -c, --config <path>   Custom directives.json URL or local file path');
    print('  -h, --help            Show this help message');
    print('');
    print('Examples:');
    print('  iclf render song.iclf');
    print('  iclf render song.iclf -w 120');
    print('  iclf render song.iclf --compact');
    print('  iclf render song.iclf -o output.txt');
    print('  iclf render song.iclf -v');
  }
}
