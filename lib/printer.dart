import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:frun/print_filters/env_filter.dart';
import 'package:frun/print_filters/exclude_filter.dart';
import 'package:frun/print_filters/filter.dart';
import 'package:frun/print_filters/search_filter.dart';

import 'flutter_runner.dart';

class Printer {
  Printer._() {
    stdin.lineMode = false;
    stdin.echoMode = false;
    _filters.add(EnvFilter(_filters));
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

  Future<void> start() async {
    initConfig();
    final keys = [10, 13, 27, 127];
    _sub = stdin.transform(utf8.decoder).listen((event) {
      final code = event.codeUnitAt(0);
      if (!keys.contains(code) && code < 32) {
        return;
      }
      if (code == 127) {
        _deleteAll();
        if (_command != null) {
          _command!.delete();
          stdout.write(_command!.cache);
          return;
        }
      }

      if (_command == null && FlutterRunner().input(event)) {
        stdout.write(event);
        return;
      }
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
    }
    if (_command != null) {
      _deleteAll();
    }
    stdout.writeln(message);
    if (_command != null) {
      stdout.write(_command!.cache);
    }
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }

  void initConfig() {
    var homeDir = Platform.environment['HOME'];
    homeDir ??= Platform.environment['USERPROFILE'];

    if (homeDir == null) {
      throw Exception('Failed to determine user home directory.');
    }

    final dir = '$homeDir/.frun';

    logFile = File('$dir/log/${DateTime.now().millisecondsSinceEpoch}.txt');
    if (!logFile!.existsSync()) {
      logFile!.createSync(recursive: true);
    }
    logSink = logFile?.openWrite(mode: FileMode.append);

    final file = File('$dir/config.json');

    if (!file.existsSync()) {
      file.createSync(recursive: true);
      final str = JsonEncoder().convert({for (var e in _filters) ...e.getDefaultConfig()});
      file.writeAsStringSync(str);
    }

    final configStr = file.readAsStringSync();
    final json = JsonDecoder().convert(configStr);
    if (json is Map) {
      for (var e in _filters) {
        e.initConfig(json);
      }
    }

    EnvFilter().printCurrent();
  }
}

void _deleteAll() {
  stdout.write('\r\x1b[K');
}
