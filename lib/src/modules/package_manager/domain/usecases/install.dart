import 'package:fpdart/fpdart.dart';
import 'package:slipy/src/modules/package_manager/domain/repositories/package_repository.dart';

import '../../../../core/entities/slipy_process.dart';
import '../../../../core/errors/errors.dart';
import '../params/package_name.dart';

abstract class Install {
  TaskEither<SlipyError, SlipyProccess> call(PackageName package);
}

class InstallImpl implements Install {
  final PackageRepository repository;

  InstallImpl(this.repository);

  @override
  TaskEither<SlipyError, SlipyProccess> call(PackageName package) {
    return _resolveVersion(package) //
        .flatMap(repository.putPackage)
        .map(_finishProcess);
  }

  TaskEither<SlipyError, PackageName> _resolveVersion(PackageName package) {
    return TaskEither(() async {
      if (package.name.contains('@')) {
        final elements = package.name.split('@');
        return Right(package.copyWith(
            name: elements[0].trim(), version: elements[1].trim()));
      } else {
        final result = await repository.getVersions(package.name).run();
        return result.map(
            (allVersion) => package.copyWith(version: '^${allVersion.last}'));
      }
    });
  }

  SlipyProccess _finishProcess(PackageName package) {
    return SlipyProccess(result: 'Added ${package.name}: ${package.version}');
  }
}
