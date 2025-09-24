import 'identical_checker/identical_checker.dart';
import 'open_tool_helper/open_tool_helper.dart';

void main() async {
  showIntro();
}

Future<void> showIntro() async {
  final tools = [IdenticalChecker(), OpenToolHelper()];
  print('=== My Utility Collections ===\n');
  for (var i = 0; i < tools.length; i++) {
    var tool = tools[i];
    print('${i + 1}. ${tool.name()}');
    print('Description: ${tool.description()}');
    print('====================================');
  }
}
