// ignore_for_file: avoid_print

import 'validator_utils.dart';

class AnalysisValidator {
  void validate() {
    const targetPath = 'analysis_options.yaml';
    const templatePath = 'lib/project_validator/data/analysis_options.yaml';
    ValidatorUtils.checkLineByLine(targetPath: targetPath, templatePath: templatePath);
  }
}
