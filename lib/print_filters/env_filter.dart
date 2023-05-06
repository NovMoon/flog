import 'package:frun/utils/string_ext.dart';

import 'filter.dart';

class EnvFilter extends PrefixCommand {
  final List<Filter> filters;
  static EnvFilter? _instance;

  factory EnvFilter([List<Filter> f = const []]) {
    return _instance ??= EnvFilter._(f);
  }

  EnvFilter._(this.filters);

  @override
  bool isFilter(String message) => false;

  @override
  String get name => '所有';

  @override
  String get prefix => '@';

  @override
  bool onRun({bool printLog = true}) {
    return true;
  }

  @override
  String filter(String message) => message;

  @override
  String printCurrent({bool isPrint = true, int indent = 0}) {
    var str = '';
    for (var i = 0; i < filters.length; i++) {
      var e = filters[i];
      if (e == this) {
        continue;
      } else if (e is CommandFilter) {
        str += e.printCurrent(isPrint: false, indent: 0);
        if (i != filters.length - 1) {
          str += '\n';
          str += '\n';
          str += '${getIndentString(0)}$centerLine\n\n';
        }
      }
    }
    printCmd(str);
    return '';
  }

  @override
  String? get clearCmd => null;
}
