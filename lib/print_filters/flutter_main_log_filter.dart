import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:cli_tools/cli_tools.dart';
import 'package:frun/flutter_runner.dart';
import 'package:frun/print_filters/filter.dart';
import 'package:frun/printer.dart';

const String _loseConnect = 'Lost connection';
const String _built = '✓  Built build';
const String _building = 'Running Gradle';
const String _buildFailed = 'BUILD FAILED in';
const String _moreDevice = 'More than one device connected';

const _list = [
  _loseConnect,
  _built,
  _building,
  _buildFailed,
];

class FlutterMainLogFilter extends Filter {
  AnsiPen pen = AnsiPen()..green();
  bool isMoreDevice = false;
  int moreDeviceCount = 0;

  Future<void> processMultiDevice(String message) async {
    var list = message.split('\n');
    list = list.where((element) => element.trim().isNotEmpty).toList();
    list.mapIndex((e, i) => '(${i + 1}) $e').forEach(stdout.writeln);

    lockMain();

    stdout.writeln('');
    stdout.write('请选择设备：');
    final choice = await promptForCharInput(list.mapIndex((e, i) => '${i + 1}').toList());
    final index = int.tryParse(choice);
    if (index == null || index > list.length) {
      stdout.writeln('error');
      unlockMain();
      return;
    }

    stdout.writeln('');

    message = list[index - 1];

    var pos = message.indexOf('•');
    message = message.substring(pos + 2);

    pos = message.indexOf(' ');
    message = message.substring(0, pos);

    FlutterRunner().defaultCmdArgs?.add('-d');
    FlutterRunner().defaultCmdArgs?.add(message);
    FlutterRunner().needRestart = true;

    moreDeviceCount = 0;
    isMoreDevice = false;

    unlockMain();
  }

  @override
  String? filter(String message) {
    if (isMoreDevice && moreDeviceCount == 0) {
      moreDeviceCount++;
      return message;
    }
    if (isMoreDevice) {
      if (moreDeviceCount == 1) {
        processMultiDevice(message);
      }
      moreDeviceCount++;
      return null;
    }
    if (message.startsWith(_building)) {
      return pen(message);
    }
    if (message.startsWith(_built)) {
      Printer().isBuilding = false;
      return pen(message);
    }

    if (message.startsWith(_loseConnect) || message.contains(_buildFailed)) {
      Printer().stop(pen(message));
      return null;
    }

    return message;
  }

  @override
  bool isFilter(String message) {
    if(!Printer().isBuilding) {
      return false;
    }
    if (isMoreDevice) {
      return true;
    }
    for (var value in _list) {
      if (message.startsWith(value)) {
        return true;
      }
    }
    if (message.startsWith(_moreDevice)) {
      isMoreDevice = true;
      return true;
    }
    if (message.contains(_buildFailed)) {
      return true;
    }
    return false;
  }
}
