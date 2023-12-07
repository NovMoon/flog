
import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:frun/flutter_runner.dart';
import 'package:frun/print_filters/flutter_build_filter.dart';

abstract class BuildProcessor {

  bool isBizDoing = false;

  bool isProcess(String message);

  List<String> messages = [];

  Future<void> onProcess(String message) async {
    messages.add(message);
    if(isBizDoing) {
      return;
    }
    lockMain();
    isBizDoing = true;
    stdout.writeln('');

    await Future.delayed(Duration(seconds: 3));

    final cmd = await doBiz();
    if(cmd == null) {
      onRecycle();
      return;
    }

    FlutterRunner().defaultCmdArgs?.addAll(cmd);
    FlutterRunner().restart();

    onRecycle();
  }

  /// 如果返回null，表示不能处理，直接结束
  /// 否则返回需要追加的命令参数，如果命令参数为空，则按原命令执行
  Future<List<String>?> doBiz();

  void onRecycle() {
    isBizDoing = false;
    FlutterBuildFilter().processor = null;
    unlockMain();
  }
}
