import 'package:slipy/src/core/modular/bind.dart';
import 'package:slipy/src/core/modular/module.dart';
import 'package:slipy/src/modules/template_generator/domain/usecases/add_line.dart';
import 'package:slipy/src/modules/template_generator/domain/usecases/create.dart';

class TemplateGeneratorModule extends Module {
  @override
  final List<Bind> binds = [
    Bind.singleton<Create>((i) => CreateImpl(), export: true),
    Bind.singleton<AddLine>((i) => AddLineImpl(), export: true),
  ];
}
