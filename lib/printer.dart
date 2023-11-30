import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:frun/print_filters/env_filter.dart';
import 'package:frun/print_filters/error_filter.dart';
import 'package:frun/print_filters/exclude_filter.dart';
import 'package:frun/print_filters/filter.dart';
import 'package:frun/print_filters/flutter_build_filter.dart';
import 'package:frun/print_filters/normal_filter.dart';
import 'package:frun/print_filters/search_filter.dart';

import 'flutter_runner.dart';

class Printer {
  Printer._() {
    stdin.lineMode = false;
    stdin.echoMode = false;
    _filters.add(EnvFilter(_filters));
    _filters.add(NormalFilter());
    _filters.add(FlutterBuildFilter());
    _filters.add(AnyErrorFilter());
    _filters.add(ExcludeFilter());
    _filters.add(SearchFilter());
  }

  factory Printer() {
    return _instance ??= Printer._();
  }

  static Printer? _instance;

  File? logFile;
  IOSink? logSink;

  StreamSubscription? _sub;

  final List<Filter> _filters = [];

  CommandFilter? _command;

  bool accessCmd = true;

  bool isBuilding = true;

  Future<void> start() async {
    initConfig();
    // 10、13 回车
    // 127 删除
    // 27 ESC
    final keys = [10, 13, 27, 127];
    // _sub = stdin.transform(utf8.decoder).listen((event) {
    _sub = keystrokes.listen((event) {
      stdout.writeln('lockInput: $lockInput, isBuilding: $isBuilding, accessCmd: $accessCmd');
      if (lockInput || isBuilding || !accessCmd) {
        return;
      }
      final code = event.codeUnitAt(0);
      // 32 是空格，小于32的都是特殊字符
      if (!keys.contains(code) && code < 32) {
        return;
      }

      // ! 如果是删除键
      if (code == 127) {
        _deleteAll();
        if (_command != null) {
          _command!.delete();
          stdout.write(_command!.cache);
          return;
        }
      }

      if (_command == null && FlutterRunner().input(event)) {
        return;
      }
      // ! 如果是回车
      if (code == 10 || code == 13) {
        _command?.run();
        _command = null;
        return;
      }
      if (_command != null) {
        _command?.moreLetters(event);
        if (!_command!.isBreak()) {
          _deleteAll();
          stdout.write(_command!.cache);
          return;
        }
      }

      event = _command?.cache ?? event;
      _command = null;

      for (final filter in _filters) {
        if (filter is CommandFilter && filter.isMatchCommand(event)) {
          _command = filter;
          _command?.moreLetters(event);
          _deleteAll();
          stdout.write(_command!.cache);
          return;
        }
      }
    });
  }

  void print(String message) {
    message.split('\n').where((e) => e.isNotEmpty).forEach(_print);
  }

  void _print(String message) {
    logSink?.writeln(message);
    for (final filter in _filters) {
      if (!filter.isFilter(message)) {
        continue;
      }
      final result = filter.filter(message);
      if (result == null) {
        return;
      }

      message = result;

      if(filter is ErrorFilter) {
        break;
      }
    }
    if (_command != null) {
      _deleteAll();
    }
    stdout.writeln(message);
    if (_command != null) {
      stdout.writeln(_command!.cache);
    }
  }

  void stop([String? message]) {
    _sub?.cancel();
    _sub = null;
    if(message != null) {
      stdout.writeln(message);
    }
    FlutterRunner().stop();
  }

  void initConfig() {
    var homeDir = Platform.environment['HOME'];
    homeDir ??= Platform.environment['USERPROFILE'];

    if (homeDir == null) {
      throw Exception('Failed to determine user home directory.');
    }

    final dir = '$homeDir/.flog';

    logFile = File('$dir/log/${DateTime.now().millisecondsSinceEpoch}.txt');
    if (!logFile!.existsSync()) {
      logFile!.createSync(recursive: true);
    }
    logSink = logFile?.openWrite(mode: FileMode.append);

    final file = File('$dir/config.json');

    if (!file.existsSync()) {
      file.createSync(recursive: true);
      final str = JsonEncoder.withIndent('  ').convert({
        ...FlutterRunner().getDefaultConfig(),
        for (var e in _filters) ...e.getDefaultConfig(),
      });
      file.writeAsStringSync(str);
    }

    final configStr = file.readAsStringSync();
    final json = JsonDecoder().convert(configStr);
    if (json is Map) {
      for (var e in _filters) {
        e.initConfig(json);
      }
      FlutterRunner().initConfig(json);
    }

    EnvFilter().printCurrent();
  }
}

void _deleteAll() {
  stdout.write('\r\x1b[K');
}
