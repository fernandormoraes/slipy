import 'package:slidy/src/core/models/custom_file.dart';

final _mobxTemplate = r''' 
mobx: |
  import 'package:mobx/mobx.dart';
  
  part '$fileName.g.dart';
  
  class $fileName|pascalcase = $fileName|pascalcaseBase with _$$fileName|pascalcase;
  abstract class $fileName|pascalcaseBase with Store {}
mobx_test: |
  import 'package:flutter_test/flutter_test.dart';
  $arg2
   
  void main() {
    late $arg1 store;
  
    setUpAll(() {
      store = $arg1();
    });
  }
''';

final mobxFile = CustomFile(yaml: _mobxTemplate);
