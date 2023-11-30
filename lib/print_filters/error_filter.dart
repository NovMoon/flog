import 'package:cli_tools/cli_tools.dart';
import 'package:frun/print_filters/filter.dart';

abstract class ErrorFilter extends Filter {
  List<String>? get keys;
  RegExp? get regex;

  @override
  String? filter(String message) {
    // stackTrace=#0
    if(message.contains('ce=#0')) {
      final list = message.split('#0');
      var first = list.removeAt(0).removeColor();
      first = first.cYellow();
      final sb = StringBuffer();
      sb.writeln(first);
      first = list.first;
      sb.write('#0$first'.cRed());
      return '\n$sb';
    }
    if(message.contains('package:bepro')) {
      message = message.removeColor();
      return message.cCyan(bold: true);
    }
    return message.cRed();
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
  final RegExp regex = RegExp(r"#\d+\s{5,6}");

  @override
  List<String> get keys => [
    'Error:'
  ];
}
