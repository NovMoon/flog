import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:frun/print_filters/filter.dart';

abstract class ErrorFilter extends Filter {
  AnsiPen pen = AnsiPen()..red(bold: true);

  List<String> get keys;

  @override
  bool isFilter(String message) {
    for (var value in keys) {
      if (message.contains(value)) {
        return true;
      }
    }
    return false;
  }
}


class AnyErrorFilter extends ErrorFilter {

  @override
  String? filter(String message) {
    return pen(message);
  }
  @override
  List<String> get keys => [
    'Error:'
  ];
}
