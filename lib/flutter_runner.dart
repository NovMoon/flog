import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cli_tools/cli_tools.dart';
import 'package:frun/printer.dart';

const _holder = [
  'r',
  'R',
  'q',
];

class FlutterRunner {
  FlutterRunner._();

  factory FlutterRunner() {
    return _instance ??= FlutterRunner._();
  }

  static FlutterRunner? _instance;

  final List<StreamSubscription?> _subs = [];
  final List<Process?> _process = [];
  Process? _mainProcess;

  /// 默认执行的命令
  String? defaultCmd;
  List<String>? defaultCmdArgs;

  bool needRestart = false;

  Future<void> start(List<String> arguments) async {
    if (arguments.isEmpty) {
      if (defaultCmd?.isEmpty ?? true) {
        print('当前没有默认命令，请在.flog/config.json中配置defaultCmd，例如：flutter run');
        return;
      }
      // Printer().print('执行：adb kill-server'.asLine);
      // await Process.run('adb ', ['kill-server'], runInShell: true);
      // Printer().print('执行：adb start-server'.asLine);
      // await Process.run('adb ', ['start-server'], runInShell: true);
      // final result = await _run('flutter', ['pub', 'get']);
      // if(await result.exitCode != 0) {
      //   stop();
      //   exit(-1);
      // }

      await startMainProcess();

      stop();
      return;
    }
    final cmd = arguments[0];
    _mainProcess = await _run(cmd, arguments.sublist(1));
  }

  Future<void> startMainProcess() async {
    final cmds = <String>[defaultCmd!, ...(defaultCmdArgs??[])];

    _mainProcess =  await cmds.startAsCmd(out: Printer().print, err: Printer().print);

    await _mainProcess!.exitCode;
    await locked;
    if(needRestart) {
      needRestart = false;
      await startMainProcess();
    }
  }

  Future<Process> _run(String cmd, List<String>? args) async {
    final proc = await Process.start(cmd, args ?? []);
    _process.add(proc);
    _subs.add(proc.stdout.transform(utf8.decoder).listen(Printer().print));
    _subs.add(proc.stderr.transform(utf8.decoder).listen(Printer().print));
    return proc;
  }

  bool input(String input) {
    if (!_holder.contains(input)) {
      return false;
    }
    _mainProcess?.stdin.write(input);
    stdout.write(input);
    stdout.write('\n');

    if (input == 'q') {
      stop();
    }
    return true;
  }

  void stop() {
    for (var element in _subs) {
      element?.cancel();
    }
    _subs.clear();

    for (var element in _process) {
      element?.kill();
    }
    _process.clear();
    _mainProcess = null;
    exit(0);
  }

  void initConfig(Map config) {
    final defCmd = config['defaultCmd'];
    if (defCmd is! Map) {
      return;
    }
    defaultCmd = defCmd['cmd'];
    final args = defCmd['args'];
    if (args is! List) {
      return;
    }
    defaultCmdArgs = args.map((e) => e.toString()).toList();
  }

  Map getDefaultConfig() {
    /// 'flutter run --dart-define=SELECT_ENV=true'
    return {
      'defaultCmd': {
        'cmd': 'flutter',
        'args': ['run', '--dart-define=SELECT_ENV=true'],
      },
    };
  }

  void _testMode() {
    print('进入测试模式');
    var a = 0;
    Future.doWhile(() async {
      if (a % 2 == 0) {
        Printer().print('FlutterRunner: abcde');
      } else if (a % 3 == 0) {
        Printer().print('FlutterRunner: 12345');
      } else {
        Printer().print('FlutterRunner: 好的');
      }
      a++;
      await Future.delayed(const Duration(seconds: 1));
      return true;
    });
  }
}
