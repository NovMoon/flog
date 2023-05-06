import 'dart:async';
import 'dart:io';

import 'package:frun/flutter_runner.dart';
import 'package:frun/printer.dart';

const lineNumber = 'line-number';
const cTest = 'test';

Future<void> main(List<String> arguments) async {
  exitCode = 0;
  // final parser = ArgParser();
  // ArgResults argResults = parser.parse(arguments);
  // final paths = argResults.rest;
  // print('paths=${paths.join(',')}');

  Printer().start();
  FlutterRunner().start(arguments);
}

/// hello
void test() {}
