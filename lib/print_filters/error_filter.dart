import 'package:cli_tools/cli_tools.dart';
import 'package:frun/print_filters/filter.dart';

abstract class ErrorFilter extends Filter {
  List<String>? get keys;
  RegExp? get regex;

  @override
  String? filter(String message) {
    return message.removeColor().cRed();
  }

  @override
  bool isFilter(String message) {
    if(keys != null) {
      for (var value in keys!) {
        if (message.contains(value)) {
          return true;
        }
      }
    }

    return regex?.hasMatch(message) ?? false;
  }
}


class AnyErrorFilter extends ErrorFilter {

  @override
  final RegExp regex = RegExp(r"#\d\s{6}");

  @override
  List<String> get keys => [
    'Error:'
  ];
}
