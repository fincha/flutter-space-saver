// File: lib/src/cli.dart
import 'dart:io';
import 'package:args/args.dart';
import 'space_saver.dart';

/// Command-line interface for the SpaceSaver
class CLI {
  /// Run the CLI with the given arguments
  Future<void> run(List<String> arguments) async {
    final parser = ArgParser()
      ..addFlag('help',
          abbr: 'h', negatable: false, help: 'Print this usage information.');

    ArgResults args;

    try {
      args = parser.parse(arguments);
    } catch (e) {
      _printUsage(parser);
      return;
    }

    if (args['help']) {
      _printUsage(parser);
      return;
    }

    if (args.rest.isEmpty) {
      print('Error: Project path is required.');
      _printUsage(parser);
      return;
    }

    final String projectPath = args.rest.first;
    final spaceSaver = SpaceSaver();
    await spaceSaver.processProject(projectPath);

    print('\n✨ Space optimization complete!');
  }

  /// Print usage information
  void _printUsage(ArgParser parser) {
    print(
        'Space Saver - A tool that optimizes your codebase by reducing its size');
    print('⚠️  FOR EDUCATIONAL PURPOSES ONLY - THIS WILL DELETE FILES ⚠️\n');
    print('Usage: dart run space_saver [options] <project_path>\n');
    print('Options:');
    print(parser.usage);
  }
}
