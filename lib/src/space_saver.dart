// File: lib/src/space_saver.dart
import 'dart:io';
import 'dart:math';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

/// A class that randomly reduces codebase size by approximately 50%
/// This is for educational/demonstration purposes only
class SpaceSaver {
  final Logger _logger = Logger('SpaceSaver');
  final Random _random = Random();

  /// List of extensions to process
  final List<String> _extensions = [
    '.dart',
    '.yaml',
    '.json',
    '.gradle',
    '.xml'
  ];

  /// List of directories to exclude
  final List<String> _excludeDirs = [
    '.git',
    '.dart_tool',
    'build',
    '.idea',
    '.vscode',
    'ios/Pods'
  ];

  SpaceSaver() {
    _initializeLogger();
  }

  void _initializeLogger() {
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  /// Process the project directory
  Future<void> processProject(String projectPath) async {
    final Directory projectDir = Directory(projectPath);

    if (!await projectDir.exists()) {
      _logger.severe('Project directory does not exist: $projectPath');
      return;
    }

    _logger.info('Starting to optimize project at: $projectPath');
    _logger
        .warning('WARNING: This will DELETE approximately 50% of your files!');

    try {
      List<File> eligibleFiles = [];
      int filesSkipped = 0;
      int totalBytesBeforeOptimization = 0;

      // First pass: identify eligible files
      await for (final FileSystemEntity entity
          in projectDir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final String relativePath =
              path.relative(entity.path, from: projectPath);

          // Skip if in excluded directory
          if (_excludeDirs.any((dir) => relativePath.startsWith('$dir/'))) {
            _logger.fine('Skipping excluded directory: $relativePath');
            filesSkipped++;
            continue;
          }

          // Only process files with specific extensions
          final String extension = path.extension(entity.path).toLowerCase();
          if (_extensions.contains(extension)) {
            totalBytesBeforeOptimization += await entity.length();
            eligibleFiles.add(entity);
          } else {
            _logger.fine('Skipping non-target file: $relativePath');
            filesSkipped++;
          }
        }
      }

      // Second pass: delete approximately 50% of eligible files
      int filesDeleted = 0;
      int totalBytesDeleted = 0;

      // Shuffle the files to ensure random deletion
      eligibleFiles.shuffle(_random);

      // Delete approximately 50% of the files
      int filesToDelete = (eligibleFiles.length / 2).round();
      for (int i = 0; i < filesToDelete && i < eligibleFiles.length; i++) {
        final File file = eligibleFiles[i];
        final String relativePath = path.relative(file.path, from: projectPath);
        final int fileSize = await file.length();

        try {
          await file.delete();
          _logger
              .info('Deleted file: $relativePath (${_formatBytes(fileSize)})');
          filesDeleted++;
          totalBytesDeleted += fileSize;
        } catch (e) {
          _logger.warning('Failed to delete file $relativePath: $e');
        }
      }

      double percentageSaved = totalBytesBeforeOptimization > 0
          ? (totalBytesDeleted / totalBytesBeforeOptimization * 100)
          : 0;

      _logger.info('Optimization complete:');
      _logger.info('- Files eligible for processing: ${eligibleFiles.length}');
      _logger.info('- Files deleted: $filesDeleted');
      _logger.info('- Files skipped: $filesSkipped');
      _logger.info('- Files remaining: ${eligibleFiles.length - filesDeleted}');
      _logger.info('- Space saved: ${_formatBytes(totalBytesDeleted)}');
      _logger.info(
          '- Original size: ${_formatBytes(totalBytesBeforeOptimization)}');
      _logger.info(
          '- New size: ${_formatBytes(totalBytesBeforeOptimization - totalBytesDeleted)}');
      _logger
          .info('- Percentage saved: ${percentageSaved.toStringAsFixed(2)}%');
    } catch (e) {
      _logger.severe('Error processing project: $e');
    }
  }

  /// Format bytes to a human-readable string
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / 1048576).toStringAsFixed(2)} MB';
  }
}
