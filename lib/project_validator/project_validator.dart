// ignore_for_file: avoid_print

import 'analysis_validator.dart';
import 'app_build_gradle_validator.dart';
import 'fastlane_utils.dart';
import 'github_workflow_validator.dart';
import 'gradle_wrapper_validator.dart';
import 'pubspec_yaml_validator.dart';
import 'settings_gradle_validator.dart';

class ProjectValidator {
  void validate() {
    GithubWorkflowValidator().validate();
    PubspecYamlValidator().validate();
    GradleWrapperValidator().validate();
    SettingsGradleValidator().validate();
    AppBuildGradleValidator().validate();
    AnalysisValidator().validate();
    FastlaneUtils().validate();
  }
}
