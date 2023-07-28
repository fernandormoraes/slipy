import 'package:fpdart/fpdart.dart';
import 'package:slipy/slipy.dart';

import '../repositories/package_repository.dart';

abstract class Find {
  TaskEither<SlipyError, SlipyProccess> call(String packageName);
}

class FindImpl implements Find {
  final PackageRepository repository;

  FindImpl(this.repository);

  @override
  TaskEither<SlipyError, SlipyProccess> call(String packageName) {
    return TaskEither<SlipyError, String>.of(packageName) //
        .flatMap(repository.findPackage)
        .map(_finishProcess);
  }

  SlipyProccess _finishProcess(List<String> packages) {
    for (var element in packages) {
      print(element);
    }
    return SlipyProccess(result: '');
  }
}
