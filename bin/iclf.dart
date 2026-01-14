import 'dart:io';
import 'package:iclf_parser/src/cli/cli_runner.dart';

Future<void> main(List<String> arguments) async {
  final exitCode = await CliRunner().run(arguments);
  exit(exitCode);
}
