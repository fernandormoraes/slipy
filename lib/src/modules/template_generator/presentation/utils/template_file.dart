import 'dart:io';

import 'package:recase/recase.dart';
import 'package:slipy/slipy.dart';
import 'package:slipy/src/core/services/yaml_service.dart';
import 'package:yaml/yaml.dart';

class TemplateFile {
  late final File file;
  late final File fileTest;
  late final String fileName;
  late final String fileNameWithUpperCase;
  final String packageName;
  late final String import;

  String get fileNameUpperSnake => fileNameWithUpperCase.snakeCase;

  TemplateFile._(String path, String type, this.packageName) {
    file = File('lib/app/$path$type.dart');
    fileTest = File('test/app/$path${type}_test.dart');
    fileName = ReCase(Uri.parse(path).pathSegments.last).camelCase;
    fileNameWithUpperCase = fileName[0].toUpperCase() + fileName.substring(1);
    import = 'import \'package:$packageName/app/$path$type.dart\';';
  }

  static Future<TemplateFile> getInstance(String path, String? type) async {
    final pubspec = Modular.get<YamlService>();
    return TemplateFile._(path, type == null ? '' : '_$type',
        (pubspec.getValue(['name']))?.value);
  }

  Future<bool> checkDependencyIsExist(String dependency,
      [bool isDev = false]) async {
    try {
      final dependenciesLine = isDev ? 'dev_dependencies' : 'dependencies';
      final pubspec = Modular.get<YamlService>();
      final map = (pubspec.getValue([dependenciesLine]))?.value as YamlMap;
      return map.containsKey(dependency);
    } catch (e) {
      return false;
    }
  }
}
