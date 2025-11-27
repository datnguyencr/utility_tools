// ignore_for_file: avoid_print
import 'validator_utils.dart';

class GithubWorkflowValidator {
  void validate() {
    const targetPath = '.github/workflows/release.yml';
    const templatePath = 'lib/project_validator/data/release.yml';
    ValidatorUtils.checkLineByLine(targetPath:targetPath, templatePath:templatePath);
  }
}
