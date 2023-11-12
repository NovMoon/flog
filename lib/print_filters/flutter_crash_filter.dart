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
const String _buildFailed2 = 'FAILURE: Build failed';
const String _moreDevice = 'More than one device connected';

const _list = [
  _loseConnect,
  _built,
  _building,
];
const _listContain = [
  _buildFailed,
  _buildFailed2,
];

class FlutterCrashFilter extends Filter {
  bool isMoreDevice = false;
  int moreDeviceCount = 0;

  @override
  String? filter(String message) {

    return message;
  }

  @override
  bool isFilter(String message) {

    return false;
  }
}
