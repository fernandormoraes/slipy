import 'package:fpdart/fpdart.dart';
import 'package:slipy/slipy.dart';

import '../models/line_params.dart';

abstract class AddLine {
  Future<Either<SlipyError, SlipyProccess>> call(LineParams params);
}

class AddLineImpl extends AddLine {
  @override
  Future<Either<SlipyError, SlipyProccess>> call(LineParams params) async {
    var lines = await params.file.readAsLines();
    lines = params.replaceLine == null
        ? lines
        : lines.map<String>(params.replaceLine!).toList();
    lines.insertAll(params.position, params.inserts);
    await params.file.writeAsString(lines.join('\n'));

    if (params.inserts.isEmpty) {
      return Right(SlipyProccess(
          result: '${params.file.uri.pathSegments.last} added line'));
    }
    return Right(SlipyProccess(
        result:
            '${params.file.uri.pathSegments.last} added line ${params.inserts.first}'));
  }
}
