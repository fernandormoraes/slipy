import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/errors.dart';
import '../params/package_name.dart';

abstract class PackageRepository {
  TaskEither<SlipyError, List<String>> getVersions(String packageName);
  TaskEither<SlipyError, PackageName> putPackage(PackageName package);
  TaskEither<SlipyError, PackageName> removePackage(PackageName package);
  TaskEither<SlipyError, List<String>> findPackage(String packageName);
}
