import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:slipy/src/core/errors/errors.dart';
import 'package:slipy/src/modules/pipeline/domain/entities/script.dart';

import '../entities/slipy_pipeline_v1.dart';
import '../services/yaml_reader_service.dart';

abstract class LoadSlipyPipeline {
  TaskEither<SlipyError, SlipyPipelineV1> call(File yamlFile);
}

class LoadSlipyPipelineImpl implements LoadSlipyPipeline {
  final YamlReaderService yamlReader;

  LoadSlipyPipelineImpl(this.yamlReader);

  @override
  TaskEither<SlipyError, SlipyPipelineV1> call(File yamlFile) {
    return TaskEither(() async {
      if (!await yamlFile.exists()) {
        return Left(SlipyError(
            'YAML file (${yamlFile.path}) not found. Add \'slipy.yaml\' file'));
      }
      final yamlText = await yamlFile.readAsString();

      final yamlMap = yamlReader.readYaml(yamlText);

      if (yamlMap['slipy'] == null) {
        return Left(SlipyError('Field [slipy] is required. (ex: slipy: "1")'));
      }

      if (yamlMap['slipy'] is! String) {
        return Left(SlipyError('Field [slipy] must be String.'));
      }

      if (yamlMap['slipy'] != '1') {
        return Left(
            SlipyError('slipy Version ${yamlMap['slipy']} not supported'));
      }

      final scripts = yamlMap['scripts'];

      if (scripts != null) {
        if (scripts is! Map<String, dynamic>) {
          return Left(SlipyError('Field [scripts] not be a object.'));
        }

        for (var key in scripts.keys) {
          final script = scripts[key]!;
          if (script is String) {
            continue;
          }
          if ((script['run'] == null && script['steps'] == null) || //
              (script['run'] != null && script['steps'] != null)) {
            return Left(
                SlipyError('Use [run] or [steps] propertie in Script.'));
          }

          if (script['shell'] != null &&
              ShellEnum.values
                  .where((e) => e.name == script['shell'])
                  .isEmpty) {
            return Left(SlipyError(
                'Invalid [shell] propertie. Avaliable values (${ShellEnum.values.map((e) => e.name).join('|')})'));
          }

          if (script['environment'] != null && script['environment'] is! Map) {
            return Left(SlipyError('Field [environment] must be Object.'));
          }

          final steps = script['steps'];

          if (steps != null) {
            if (steps is! List) {
              return Left(SlipyError('Field [steps] not be a List.'));
            }
            for (var step in steps) {
              if (step['shell'] != null &&
                  ShellEnum.values
                      .where((e) => e.name == step['shell'])
                      .isEmpty) {
                return Left(SlipyError(
                    'Invalid [type] propertie. Avaliable values (${ShellEnum.values.map((e) => e.name).join('|')})'));
              }
              if (step['run'] == null) {
                return Left(
                    SlipyError('Field [run] is required in [step] propertie.'));
              }

              if (step['condition'] != null && //
                  _validateCondicion(step['condition']) &&
                  step['condition'] is! String) {
                return Left(SlipyError('Field [condition] must be String.'));
              }

              if (script['environment'] != null &&
                  step['environment'] is! Map<String, String>) {
                return Left(SlipyError(
                    'Field [environment] must be Object[String,String].'));
              }
            }
          }
        }
      }

      final script = mapToScriptEntry(scripts);

      final pipe = SlipyPipelineV1(
        version: yamlMap['slipy'],
        systemVariables: Platform.environment,
        localVariables: yamlMap['variables'] != null
            ? fixMapVariables(yamlMap['variables'])
            : {},
        scripts: script,
      );

      return Right(pipe);
    });
  }

  Map<String, String> fixMapVariables(Map variables) {
    return variables.map((key, value) => MapEntry(key, value.toString()));
  }

  Map<String, Script> mapToScriptEntry(Map? json) {
    if (json == null) {
      return {};
    }
    return json.map((key, value) {
      if (value is String) {
        final script = Script(name: key, run: value, shell: ShellEnum.command);
        return MapEntry(key, script);
      }

      final script = Script(
        name: value['name'] ?? key,
        run: value['run'],
        description: value['description'] ?? '',
        environment: value['environment']?.cast<String, String>(),
        shell: ShellEnum.values.firstWhere((e) => e.name == value['shell'],
            orElse: () => ShellEnum.command),
        workingDirectory: value['working-directory'] ?? '.',
        steps: value['steps']?.map<Step>(mapToStep).toList(),
      );
      return MapEntry(key, script);
    });
  }

  Step mapToStep(dynamic map) {
    return Step(
      name: map['name'],
      condition: map['condition'],
      description: map['description'] ?? '',
      environment: map['environment']?.cast<String, String>(),
      shell: ShellEnum.values.firstWhere((e) => e.name == map['shell'],
          orElse: () => ShellEnum.command),
      workingDirectory: map['working-directory'] ?? '.',
      run: map['run'],
    );
  }

  bool _validateCondicion(String condition) {
    final splitter = condition.split(RegExp('(&&|||)'));
    for (var element in splitter) {
      if (!element.trim().contains(r'^\w+ *(==|!=) *\w+')) {
        return false;
      }
    }

    return true;
  }
}
