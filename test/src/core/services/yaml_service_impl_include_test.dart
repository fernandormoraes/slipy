import 'dart:convert';
import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:slipy/src/core/services/yaml_service_impl.dart';
import 'package:test/test.dart';

class FileMock extends Mock implements File {
  String savedFile = '';

  final String stringYaml;

  FileMock(this.stringYaml);

  @override
  Future<File> writeAsString(String contents,
      {FileMode mode = FileMode.write,
      Encoding encoding = utf8,
      bool flush = false}) async {
    savedFile = contents;
    return this;
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) async {
    return stringYaml;
  }

  @override
  String readAsStringSync({Encoding encoding = utf8}) {
    return stringYaml;
  }

  @override
  bool existsSync() {
    return true;
  }
}

void main() {
  test('include one', () async {
    final file = FileMock(stringYaml);
    final service = await YamlServiceImpl(
        yaml: file,
        getYamlFileParam: (file, path) {
          return FileMock(otherYaml);
        }).readAllIncludes();

    final node = service.getValue(['name']);
    expect(node?.value, 'slipy');
  });
  test('include list', () async {
    final file = FileMock(stringYamlList);
    var count = 0;
    final service = await YamlServiceImpl(
        yaml: file,
        getYamlFileParam: (file, path) {
          if (count == 0) {
            count++;
            return FileMock(otherYaml);
          }
          return FileMock(otherYaml2);
        }).readAllIncludes();

    final node = service.getValue(['name']);
    expect(node?.value, 'slipy');
    final node2 = service.getValue(['command']);
    expect(node2?.value, 'slipy-command');
  });
}

const stringYaml = ''' 
include: folder/other.yaml
''';
const stringYamlList = ''' 
include: 
- folder/other.yaml
- folder/other2.yaml
''';

const otherYaml = ''' 
name: slipy
''';
const otherYaml2 = ''' 
command: slipy-command
''';
