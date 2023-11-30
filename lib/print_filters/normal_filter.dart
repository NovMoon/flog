import 'package:cli_tools/cli_tools.dart';
import 'package:frun/print_filters/filter.dart';

class NormalFilter extends Filter {
  RegExp regex = RegExp(r'[A-Z]/flutter \(\d+\): ');

  @override
  String? filter(String message) {
    message = message.replaceAll(regex, '');
    return message.removeColor();
  }

  @override
  bool isFilter(String message) {
    return true;
  }
}
