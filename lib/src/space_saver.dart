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
  final List<String> _extensions = ['.dart', '.yaml', '.json', '.gradle', '.xml'];
  
  /// List of directories to exclude
  final List<String> _excludeDirs = ['.git', '.dart_tool', 'build', '.idea', '.vscode', 'ios/Pods'];
  
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
    
    try {
      int filesProcessed = 0;
      int filesSkipped = 0;
      int totalLinesSaved = 0;
      int totalBytesBeforeOptimization = 0;
      int totalBytesAfterOptimization = 0;
      
      await for (final FileSystemEntity entity in projectDir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final String relativePath = path.relative(entity.path, from: projectPath);
          
          // Skip if in excluded directory
          if (_excludeDirs.any((dir) => relativePath.startsWith('$dir/'))) {
            _logger.fine('Skipping excluded directory: $relativePath');
            filesSkipped++;
            continue;
          }
          
          // Only process files with specific extensions
          final String extension = path.extension(entity.path).toLowerCase();
          if (_extensions.contains(extension)) {
            final result = await _processFile(entity);
            filesProcessed++;
            totalLinesSaved += result.linesSaved;
            totalBytesBeforeOptimization += result.bytesBeforeOptimization;
            totalBytesAfterOptimization += result.bytesAfterOptimization;
          } else {
            _logger.fine('Skipping non-target file: $relativePath');
            filesSkipped++;
          }
        }
      }
      
      double percentageSaved = totalBytesBeforeOptimization > 0 
          ? ((totalBytesBeforeOptimization - totalBytesAfterOptimization) / totalBytesBeforeOptimization * 100) 
          : 0;
      
      _logger.info('Optimization complete:');
      _logger.info('- Files processed: $filesProcessed');
      _logger.info('- Files skipped: $filesSkipped');
      _logger.info('- Lines optimized: $totalLinesSaved');
      _logger.info('- Space saved: ${_formatBytes(totalBytesBeforeOptimization - totalBytesAfterOptimization)}');
      _logger.info('- Original size: ${_formatBytes(totalBytesBeforeOptimization)}');
      _logger.info('- New size: ${_formatBytes(totalBytesAfterOptimization)}');
      _logger.info('- Percentage saved: ${percentageSaved.toStringAsFixed(2)}%');
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
  
  /// Process a single file
  Future<_ProcessResult> _processFile(File file) async {
    final String relativePath = path.basename(file.path);
    _logger.info('Optimizing file: $relativePath');
    
    try {
      // Read the file content
      final String content = await file.readAsString();
      final List<String> lines = content.split('\n');
      
      if (lines.isEmpty) {
        _logger.info('Skipping empty file: $relativePath');
        return _ProcessResult(0, content.length, content.length);
      }
      
      // Optimize ~50% of the lines by replacing them with comments
      final result = _optimizeLines(lines, path.extension(file.path).toLowerCase());
      final String modifiedContent = result.lines.join('\n');
      
      await file.writeAsString(modifiedContent);
      _logger.info('Optimized file: $relativePath (${result.linesSaved} lines saved)');
      
      return _ProcessResult(
        result.linesSaved, 
        content.length, 
        modifiedContent.length
      );
    } catch (e) {
      _logger.warning('Error optimizing file $relativePath: $e');
      return _ProcessResult(0, 0, 0);
    }
  }
  
  /// Optimize ~50% of lines by commenting them out
  _OptimizeResult _optimizeLines(List<String> lines, String fileExtension) {
    final List<String> result = [];
    int linesSaved = 0;
    
    // Determine comment style based on file extension
    final String commentPrefix = _getCommentPrefix(fileExtension);
    final String commentSuffix = _getCommentSuffix(fileExtension);
    
    for (int i = 0; i < lines.length; i++) {
      if (_random.nextBool()) {
        // Approximately 50% chance to comment out the line
        // Skip commenting if the line is already a comment or is empty
        if (lines[i].trim().startsWith(commentPrefix) || lines[i].trim().isEmpty) {
          result.add(lines[i]);
        } else {
          result.add('$commentPrefix ${lines[i]} $commentSuffix // Space Saver');
          linesSaved++;
        }
      } else {
        result.add(lines[i]);
      }
    }
    return _OptimizeResult(result, linesSaved);
  }
  
  /// Get the appropriate comment prefix based on file extension
  String _getCommentPrefix(String extension) {
    switch (extension) {
      case '.dart':
      case '.java':
      case '.kt':
      case '.swift':
      case '.c':
      case '.cpp':
      case '.gradle':
        return '//';
      case '.yaml':
      case '.yml':
        return '#';
      case '.xml':
        return '<!--';
      default:
        return '//';
    }
  }
  
  /// Get the appropriate comment suffix based on file extension
  String _getCommentSuffix(String extension) {
    switch (extension) {
      case '.xml':
        return '-->';
      default:
        return '';
    }
  }
}

/// Class to hold the result of line optimization
class _OptimizeResult {
  final List<String> lines;
  final int linesSaved;
  
  _OptimizeResult(this.lines, this.linesSaved);
}

/// Class to hold the result of file processing
class _ProcessResult {
  final int linesSaved;
  final int bytesBeforeOptimization;
  final int bytesAfterOptimization;
  
  _ProcessResult(this.linesSaved, this.bytesBeforeOptimization, this.bytesAfterOptimization);
}
