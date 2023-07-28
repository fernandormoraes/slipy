import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:slipy/slipy.dart';

import '../../../../../core/command/command_base.dart';
import '../../../domain/models/template_info.dart';
import '../../../domain/usecases/create.dart';
import '../../templates/use_case.dart';
import '../../utils/template_file.dart';
import '../../utils/utils.dart' as utils;

class GenerateUseCaseSubCommand extends CommandBase {
  @override
  final name = 'usecase';
  @override
  final description = 'Creates a Use Case file';

  GenerateUseCaseSubCommand() {
    argParser.addFlag('notest',
        abbr: 'n', negatable: false, help: 'Don`t create file test');
    argParser.addOption('bind',
        abbr: 'u',
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

    if (!await templateFile.checkDependencyIsExist('dartz')) {
      var command = CommandRunner('slipy', 'CLI')..addCommand(InstallCommand());
      await command.run(['install', 'dartz@0.10.0-nullsafety.1 ']);
    }

    var result = await Modular.get<Create>().call(TemplateInfo(
        yaml: useCase,
        destiny: templateFile.file,
        key: 'use_case',
        args: ['${templateFile.fileNameWithUpperCase}Event']));
    execute(result);
    if (result.isRight()) {
      await utils.injectParentModule(
          argResults!['bind'],
          '${templateFile.fileNameWithUpperCase}()',
          templateFile.import,
          templateFile.file.parent);
    }

    if (!argResults!['notest']) {
      result = await Modular.get<Create>().call(TemplateInfo(
          yaml: useCase,
          destiny: templateFile.fileTest,
          key: 'use_case_test',
          args: [
            templateFile.fileNameWithUpperCase,
            templateFile.import,
            templateFile.fileNameWithUpperCase
          ]));
      execute(result);
    }
  }

  @override
  String? get invocationSuffix => null;
}

class GenerateUseCaseAbbrSubCommand extends GenerateUseCaseSubCommand {
  @override
  String get name => 'u';
}
