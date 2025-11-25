
import 'identical_checker.dart';

void main() {
  final tool = IdenticalChecker();
  const folderPath = r'D:\pics';
  final extensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
  tool.checkFiles(folderPath, extensions);
}
