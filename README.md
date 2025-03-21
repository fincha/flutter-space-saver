# Space Saver

⚠️ **EDUCATIONAL PURPOSES ONLY** ⚠️

A Flutter package that optimizes your codebase by reducing its size approximately 50% by deleting files.

## Disclaimer

This package is created for educational/demonstration purposes only. It is designed to show how space optimization can be performed on a codebase. **DO NOT use this on production code or any important project. THIS WILL DELETE YOUR FILES!**

## Features

- Reduces codebase size by deleting approximately 50% of the files in your Flutter/Dart project
- Supports multiple file types (.dart, .yaml, .json, .gradle, .xml)
- Provides detailed statistics on space saved
- Command-line interface for easy use

## Installation

```bash
flutter pub add space_saver
```

## Usage

### Command Line

```bash
# Run the optimization
dart run space_saver /path/to/your/project
```

### As a Library

```dart
import 'package:space_saver/space_saver.dart';

void main() async {
  final spaceSaver = SpaceSaver();
  
  // Process a project
  await spaceSaver.processProject('/path/to/your/project');
}
```

## How It Works

The package:

1. Recursively scans all files in the specified project directory
2. Filters files by supported extensions
3. Randomly deletes approximately 50% of the eligible files
4. Provides detailed statistics on the optimization performed

## License

MIT
