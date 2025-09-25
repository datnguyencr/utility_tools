import 'package:flutter/foundation.dart';

import 'identical_checker/identical_checker.dart';
import 'open_tool_helper/open_tool_helper.dart';

void main() async {
  await showIntro();
}

Future<void> showIntro() async {
  final tools = [IdenticalChecker(), OpenToolHelper()];
  if (kDebugMode) {
    print('=== My Utility Collections ===\n');
  }
  for (var i = 0; i < tools.length; i++) {
    final tool = tools[i];
    if (kDebugMode) {
      print('${i + 1}. ${tool.name()}');
      print('Description: ${tool.description()}');
      print('====================================');
    }
  }
}
