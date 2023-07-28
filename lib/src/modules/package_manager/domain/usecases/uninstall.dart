import 'package:fpdart/fpdart.dart';
import 'package:slipy/src/modules/package_manager/domain/repositories/package_repository.dart';

import '../../../../core/entities/slipy_process.dart';
import '../../../../core/errors/errors.dart';
import '../params/package_name.dart';

abstract class Uninstall {
  TaskEither<SlipyError, SlipyProccess> call(PackageName package);
}

class UninstallImpl implements Uninstall {
  final PackageRepository repository;

  UninstallImpl(this.repository);

  @override
  TaskEither<SlipyError, SlipyProccess> call(PackageName package) {
    return repository //
        .removePackage(package)
        .map(finishProcess);
  }

  SlipyProccess finishProcess(PackageName package) {
    return SlipyProccess(result: '${package.name} removed!');
  }
}
