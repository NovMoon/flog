import 'package:cli_tools/cli_tools.dart';
import 'package:frun/flutter_runner.dart';
import 'package:frun/print_filters/filter.dart';
import 'package:frun/print_filters/processor/base.dart';
import 'package:frun/print_filters/processor/multi_device.dart';
import 'package:frun/print_filters/processor/redeclaration.dart';
import 'package:frun/printer.dart';

const String _loseConnect = 'Lost connection to device';
const String _built = '✓  Built build';
const String _building = 'Running Gradle';
const String _buildFailed = 'BUILD FAILED in';
const String _buildFailed2 = 'FAILURE: Build failed';
const String _error = 'e:';

const _list = [
  _loseConnect,
  _built,
  _building,
  _error,
];
const _listContain = [
  _buildFailed,
  _buildFailed2,
];

class FlutterBuildFilter extends Filter {

  factory FlutterBuildFilter() {
    return _instance ??= FlutterBuildFilter._();
  }

  FlutterBuildFilter._();

  static FlutterBuildFilter? _instance;

  List<BuildProcessor> processorList = [MultiDeviceProcessor(), RedeclarationProcessor()];
  BuildProcessor? processor;

  @override
  String? filter(String message) {
    if(processor != null) {
      processor!.onProcess(message);
      return null;
    }
    if (message.startsWith(_building)) {
      return message.cGreen();
    }
    if (message.startsWith(_built)) {
      Printer().isBuilding = false;
      return message.cGreen();
    }
    if (message.startsWith(_error)) {
      return message.cRed();
    }

    if (message.startsWith(_loseConnect) ||
        message.contains(_buildFailed) ||
        message.contains(_buildFailed2)) {
      if(FlutterRunner().needRestart) {
        return message.cRed();
      }
      Printer().stop(message.cRed());
      return null;
    }

    return message;
  }

  @override
  bool isFilter(String message) {
    if (!Printer().isBuilding) {
      return false;
    }
    if(processor != null) {
      return true;
    }
    for (var value in processorList) {
      if(value.isProcess(message)) {
        processor = value;
        return true;
      }
    }
    for (var value in _list) {
      if (message.startsWith(value)) {
        return true;
      }
    }

    for (var value in _listContain) {
      if (message.contains(value)) {
        return true;
      }
    }
    return false;
  }
}
