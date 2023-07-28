import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:slipy/src/core/errors/errors.dart';
import 'package:slipy/src/core/services/yaml_service.dart';
import 'package:slipy/src/modules/package_manager/domain/errors/errors.dart';
import 'package:slipy/src/modules/package_manager/domain/params/package_name.dart';
import 'package:slipy/src/modules/package_manager/domain/repositories/package_repository.dart';
import 'package:slipy/src/modules/package_manager/infra/datasources/pub_service.dart';

class PackageRepositoryImpl implements PackageRepository {
  final YamlService pubspec;
  final PubService datasource;

  PackageRepositoryImpl({required this.pubspec, required this.datasource});

  @override
  TaskEither<SlipyError, List<String>> getVersions(String packageName) {
    return TaskEither(() async {
      try {
        final versions = await datasource.fetchVersions(packageName);
        return Right(versions);
      } on SlipyError catch (e) {
        return Left(e);
      } on SocketException catch (e) {
        if (e.osError?.errorCode == 11001) {
          throw PackageManagerError('Internet error');
        }
        rethrow;
      }
    });
  }

  @override
  TaskEither<SlipyError, PackageName> putPackage(PackageName package) {
    return TaskEither(
      () async {
        pubspec.update(
            [package.isDev ? 'dev_dependencies' : 'dependencies', package.name],
            package.version);
        final result = await pubspec.save();
        if (result) {
          return Right(package);
        } else {
          return Left(
              PackageManagerError('$package not added in pubspec.yaml'));
        }
      },
    );
  }

  @override
  TaskEither<SlipyError, PackageName> removePackage(PackageName package) {
    return TaskEither(() async {
      try {
        final isRemoved = pubspec.remove([
          package.isDev ? 'dev_dependencies' : 'dependencies',
          package.name
        ]);
        if (!isRemoved) {
          return Left(PackageManagerError('Dependency not exist'));
        }
        final result = await pubspec.save();
        if (result) {
          return Right(package);
        } else {
          return Left(
              PackageManagerError('$package not removed in pubspec.yaml'));
        }
      } on SlipyError catch (e) {
        return Left(e);
      }
    });
  }

  @override
  TaskEither<SlipyError, List<String>> findPackage(String packageName) {
    return TaskEither(() async {
      try {
        final packages = await datasource.searchPackage(packageName);
        return Right(packages);
      } on SlipyError catch (e) {
        return Left(e);
      } on SocketException catch (e) {
        if (e.osError?.errorCode == 11001) {
          throw PackageManagerError('Internet error');
        }
        rethrow;
      }
    });
  }
}
