import 'dart:math';

import 'package:fpdart/fpdart.dart';
import 'package:slipy/src/modules/package_manager/domain/repositories/package_repository.dart';

import '../../../../core/entities/slipy_process.dart';
import '../../../../core/errors/errors.dart';
import '../params/package_name.dart';

abstract class Versions {
  TaskEither<SlipyError, SlipyProccess> call(PackageName package);
}

class VersionsImpl implements Versions {
  final PackageRepository repository;

  VersionsImpl(this.repository);

  @override
  TaskEither<SlipyError, SlipyProccess> call(PackageName package) {
    return repository
        .getVersions(package.name) //
        .map(finishProcess);
  }

  SlipyProccess finishProcess(List<String> versions) {
    final maxItem = min(versions.length, 10);
    final newList = versions.reversed.take(maxItem);

    for (var element in newList) {
      print(element);
    }

    return SlipyProccess(result: '');
  }
}
