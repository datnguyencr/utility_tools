import '/common/common.dart';
import '../base/tool.dart';

class OpenToolHelper extends Tool {
  @override
  String name() => "Open Browser and Tools";

  @override
  String description() => "Opens Google Chrome with default tabs and IDE";

  @override
  void run() async {
    ProcessUtils.openChrome(
      urls: [
        'https://teams.microsoft.com/v2/',
        'https://chatgpt.com/',
        'https://bitbucket.org/ASTO-System/workspace/overview/',
      ],
    );
    ProcessUtils.runProcess(
        r'D:\softs\Android\Android Studio\bin\studio64.exe');
    ProcessUtils.runProcess(
      r'C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe',
    );
  }
}

void main() async {
  var tool = OpenToolHelper();
  tool.run();
}
