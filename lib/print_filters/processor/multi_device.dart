import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:frun/print_filters/processor/base.dart';

const String _moreDevice = 'More than one device connected';

class MultiDeviceProcessor extends BuildProcessor {

  bool isTarget = false;

  @override
  Future<List<String>?> doBiz() async {
    var list = <String>[];
    for (var message in messages) {
      list.addAll(message.split('\n'));
    }
    list = list.where((element) => element.trim().isNotEmpty).toList();
    list.mapIndex((e, i) => '(${i + 1}) $e').forEach(stdout.writeln);


    stdout.write('请选择设备：');
    final choice = await promptForCharInput(list.mapIndex((e, i) => '${i + 1}').toList());
    final index = int.tryParse(choice);
    if (index == null || index > list.length) {
      stdout.writeln('error');
      return null;
    }

    stdout.writeln('');

    var cmdMsg = list[index - 1];

    var pos = cmdMsg.indexOf('•');
    cmdMsg = cmdMsg.substring(pos + 2);

    pos = cmdMsg.indexOf(' ');
    cmdMsg = cmdMsg.substring(0, pos);

    return ['-d', cmdMsg];
  }

  @override
  bool isProcess(String message) {
    if (message.startsWith(_moreDevice)) {
      isTarget = true;
      return false;
    }
    return isTarget;
  }

  @override
  void onRecycle() {
    super.onRecycle();
    isTarget = false;
  }
}