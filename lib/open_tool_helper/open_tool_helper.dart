import '/common/common.dart';
import '../base/tool.dart';

class OpenToolHelper extends Tool {
  @override
  String name() => "Open Browser and Tools";

  @override
  String description() => "Opens Google Chrome with default tabs and IDE";

  void openChrome(List<String> urls) async {
    ProcessUtils.openChrome(
      urls: urls,
    );
  }

  void runProcess(String path) async {
    ProcessUtils.runProcess(path);
  }
}

void main() async {
  var tool = OpenToolHelper();
  tool.openChrome(
    [
      'https://teams.microsoft.com/v2/',
      'https://chatgpt.com/',
      'https://bitbucket.org/ASTO-System/workspace/overview/',
    ],
  );
  tool.runProcess(r'D:\softs\Android\Android Studio\bin\studio64.exe');
  tool.runProcess(
    r'C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe',
  );
}
