import 'package:grinder/grinder.dart';
import 'package:cli_pkg/cli_pkg.dart' as pkg;

void main(List<String> args) {
  pkg.name.value = 'slipy';
  pkg.humanName.value = 'slipy';
  pkg.githubUser.value = 'fernandormoraes';
  pkg.homebrewRepo.value = 'fernandormoraes/homebrew-slipy';

  pkg.addAllTasks();
  grind(args);
}
