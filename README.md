# Utility Tools

A collection of utility helpers for Flutter and Dart, including file duplicate checking, process launching, and browser automation.

## Features

- **IdenticalChecker** – scan a folder for duplicate image files by extension.
- **OpenToolHelper** – quickly launch Chrome with predefined tabs or run desktop processes.

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  utility_tools: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Check for duplicate images in a folder

```dart
import 'package:utility_tools/utility_tools.dart';

void main() async {
  var tool = IdenticalChecker();
  const folderPath = r'D:\pics';
  final extensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
  tool.checkFiles(folderPath, extensions);
}
```

### Open Chrome and run processes

```dart
import 'package:utility_tools/utility_tools.dart';

void main() async {
  var tool = OpenToolHelper();

  tool.openChrome([
    'https://teams.microsoft.com/v2/',
    'https://chatgpt.com/',
    'https://bitbucket.org/ASTO-System/workspace/overview/',
  ]);

  tool.runProcess(r'D:\softs\Android\Android Studio\bin\studio64.exe');
  tool.runProcess(
    r'C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe',
  );
}
```

## License

This project is licensed under the MIT License – see the [LICENSE.md](LICENSE.md) file for details.
