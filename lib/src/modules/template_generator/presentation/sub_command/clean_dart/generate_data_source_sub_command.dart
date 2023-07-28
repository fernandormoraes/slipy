import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:slipy/slipy.dart';

import '../../../../../core/command/command_base.dart';
import '../../../domain/models/template_info.dart';
import '../../../domain/usecases/create.dart';
import '../../templates/data_source.dart';
import '../../utils/template_file.dart';
import '../../utils/utils.dart' as utils;

class GenerateDataSourceSubCommand extends CommandBase {
  @override
  final name = 'datasource';
  @override
  final description = 'Creates a Data Source file';

  GenerateDataSourceSubCommand() {
    argParser.addFlag('notest',
        abbr: 'n', negatable: false, help: 'Don`t create file test');
    argParser.addOption('bind',
        abbr: 'd',
        allowed: [
          'singleton',
          'lazy-singleton',
          'factory',
        ],
        defaultsTo: 'lazy-singleton',
        allowedHelp: {
          'singleton': 'Object persist while module exists',
          'lazy-singleton':
              'Object persist while module exists, but only after being called first for the fist time',
          'factory': 'A new object is created each time it is called.',
        },
        help: 'Define type injection in parent module');
  }

  @override
  FutureOr run() async {
    final templateFile =
        await TemplateFile.getInstance(argResults?.rest.single ?? '', null);

    if (!await templateFile.checkDependencyIsExist('dio')) {
      var command = CommandRunner('slipy', 'CLI')..addCommand(InstallCommand());
      await command.run(['install', 'dio@4.0.0-beta6']);
    }

    var splited = templateFile.file.path.split('/');

    var last = splited.removeLast().replaceAll('.dart', '_data_source.dart');
    var body = splited.join('/');

    var result = await Modular.get<Create>().call(
      TemplateInfo(
        yaml: dataSource,
        destiny: File('$body/../infra/datasource/$last'),
        key: 'interface_data_source',
        args: ['${templateFile.fileNameWithUpperCase}Event'],
      ),
    );

    execute(result);

    var importDataSourceInterface = 'import \'../../infra/datasource/$last\';';
    var importDataSource = 'import \'external/datasource/$last\';';

    result = await Modular.get<Create>().call(
      TemplateInfo(
        yaml: dataSource,
        destiny: File('$body/../external/datasource/$last'),
        key: 'data_source',
        args: [
          '${templateFile.fileNameWithUpperCase}Event',
          importDataSourceInterface
        ],
      ),
    );

    execute(result);

    if (result.isRight()) {
      await utils.injectParentModule(
          argResults!['bind'],
          '${templateFile.fileNameWithUpperCase}DataSourceImpl(i())',
          importDataSource,
          templateFile.file.parent.parent);
    }

    if (!argResults!['notest']) {
      if (!await templateFile.checkDependencyIsExist('mockito')) {
        var command = CommandRunner('slipy', 'CLI')
          ..addCommand(InstallCommand());
        await command.run(['install', 'mockito@5.0.0']);
      }

      result = await Modular.get<Create>().call(
        TemplateInfo(
          yaml: dataSource,
          destiny: templateFile.fileTest,
          key: 'data_source_test',
          args: [
            'I${templateFile.fileNameWithUpperCase}DataSource',
            templateFile.import,
            '${templateFile.fileNameWithUpperCase}DataSourceImpl'
          ],
        ),
      );

      execute(result);
    }
  }

  @override
  String? get invocationSuffix => null;
}

class GenerateDataSourceAbbrSubCommand extends GenerateDataSourceSubCommand {
  @override
  String get name => 'd';
}
