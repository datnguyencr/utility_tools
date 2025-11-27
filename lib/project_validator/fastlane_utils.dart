// ignore_for_file: avoid_print

import 'dart:io';

import 'package:path/path.dart' as p;

import 'validator_utils.dart';

class FastlaneUtils {
  void validate() {
    checkAppFile();
    checkFastFile();
    checkGemFile();
    checkDeployBat();
  }

  void init() {
    copyAppFile();
    copyFastFile();
    copyGemFile();
    copyDeployBat();
  }

  void copyAppFile() {
    const templatePath = 'lib/project_validator/data/Appfile';
    const targetPath = 'android/fastlane/Appfile';
    ValidatorUtils.ensureFileExists(templatePath: templatePath, targetPath: targetPath);
  }

  void copyFastFile() {
    const templatePath = 'lib/project_validator/data/Fastfile';
    const targetPath = 'android/fastlane/Fastfile';
    ValidatorUtils.ensureFileExists(templatePath: templatePath, targetPath: targetPath);
  }

  void copyGemFile() {
    const templatePath = 'lib/project_validator/data/Gemfile';
    const targetPath = 'android/Gemfile';
    ValidatorUtils.ensureFileExists(templatePath: templatePath, targetPath: targetPath);
  }

  void copyDeployBat() {
    const targetPath = 'deploy.bat';
    const templatePath = 'lib/project_validator/data/deploy.bat';
    ValidatorUtils.checkLineByLine(targetPath: targetPath, templatePath: templatePath);
  }

  static bool hasFastlane({String? projectRoot}) {
    final root = projectRoot ?? Directory.current.path;

    final pathsToCheck = [
      p.join(root, 'fastlane'), // root/fastlane
      p.join(root, 'Fastfile'), // root/Fastfile
      p.join(root, 'ios', 'fastlane'), // ios/fastlane
      p.join(root, 'ios', 'Fastfile'), // ios/Fastfile
      p.join(root, 'android', 'fastlane'), // android/fastlane
      p.join(root, 'android', 'Fastfile'), // android/Fastfile
    ];

    for (final path in pathsToCheck) {
      if (FileSystemEntity.typeSync(path) != FileSystemEntityType.notFound) {
        return true;
      }
    }
    return false;
  }

  void checkAppFile() {
    const templatePath = 'lib/project_validator/data/Appfile';
    const targetPath = 'android/fastlane/Appfile';
    ValidatorUtils.checkLineByLine(templatePath: templatePath, targetPath: targetPath);
  }

  void checkFastFile() {
    const templatePath = 'lib/project_validator/data/Fastfile';
    const targetPath = 'android/fastlane/Fastfile';
    ValidatorUtils.checkLineByLine(templatePath: templatePath, targetPath: targetPath);
  }

  void checkGemFile() {
    const templatePath = 'lib/project_validator/data/Gemfile';
    const targetPath = 'android/Gemfile';
    ValidatorUtils.checkLineByLine(templatePath: templatePath, targetPath: targetPath);
  }

  void checkDeployBat() {
    const targetPath = 'deploy.bat';
    const templatePath = 'lib/project_validator/data/deploy.bat';
    ValidatorUtils.checkLineByLine(targetPath: targetPath, templatePath: templatePath);
  }
}
