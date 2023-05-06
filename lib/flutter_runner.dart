import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:frun/printer.dart';

const _holder = [
  'r',
  'R',
];

class FlutterRunner {
  FlutterRunner._();

  factory FlutterRunner() {
    return _instance ??= FlutterRunner._();
  }

  static FlutterRunner? _instance;

  StreamSubscription? _sub;
  Process? _process;

  Future<void> start(List<String> arguments) async {
    if (arguments.isEmpty) {
      var a = 0;
      Future.doWhile(() async {
        if (a % 2 == 0) {
          Printer().print('FlutterRunner: abcde ');
        } else if (a % 3 == 0) {
          Printer().print('FlutterRunner: 12345');
        } else {
          Printer().print('FlutterRunner: 好的');
        }
        a++;
        await Future.delayed(const Duration(seconds: 1));
        return true;
      });
      return;
    }
    final cmd = arguments[0];
    _process = await Process.start(cmd, arguments.sublist(1));
    // _process = await Process.start(cmd, ['run', '--dart-define=SELECT_ENV=true']);
    _sub = _process?.stdout.transform(utf8.decoder).listen(Printer().print);
  }

  bool input(String input) {
    if (!_holder.contains(input)) {
      return false;
    }
    _process?.stdin.write(input);
    return true;
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
    _process?.kill();
    _process = null;
  }
}
