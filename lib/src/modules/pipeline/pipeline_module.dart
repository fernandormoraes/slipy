import 'package:slipy/src/core/modular/module.dart';
import 'package:slipy/src/modules/pipeline/domain/usecase/execute_script.dart';
import 'package:slipy/src/modules/pipeline/domain/usecase/load_slipy_pipeline.dart';
import 'package:slipy/src/modules/pipeline/domain/usecase/resolve_variables.dart';

import '../../core/modular/bind.dart';
import 'domain/services/yaml_reader_service.dart';
import 'domain/usecase/condition_eval.dart';
import 'infra/services/yaml_reader_service.dart';

class PipelineModule extends Module {
  @override
  List<Bind> get binds => [
        //domain
        Bind.singleton<LoadSlipyPipeline>((i) => LoadSlipyPipelineImpl(i()),
            export: true),
        Bind.singleton<ResolveVariables>((i) => ResolveVariablesImpl(),
            export: true),
        Bind.singleton<ExecuteStep>((i) => ExecuteStepImpl(), export: true),
        Bind.singleton<ConditionEval>((i) => ConditionEvalImpl(), export: true),
        //infra
        Bind.singleton<YamlReaderService>((i) => YamlReaderServiceImpl(),
            export: true),
      ];
}
