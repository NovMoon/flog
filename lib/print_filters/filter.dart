import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:frun/utils/string_ext.dart';

abstract class Filter {
  bool isFilter(String message);
  String? filter(String message);

  void initConfig(Map config) {}
  Map getDefaultConfig() => {};
}

final String topLine = 20.dividerOuter;
final String centerLine = 20.dividerInner;

abstract class CommandFilter extends Filter {
  String get name;

  List<String> commands = [];

  String cache = '';

  bool isMatchCommand(String command);

  bool onRun();
  void afterRun(bool isRun);

  bool run({bool printLog = true}) {
    if (cache.isEmpty) {
      cache = '';
      return false;
    }
    final result = onRun();
    afterRun(result);
    cache = '';
    if (result && printLog) {
      printCurrent();
    }
    return result;
  }

  void addCommand(String command) {
    if (commands.contains(command)) {
      return;
    }
    commands.add(command);
  }

  void moreLetters(String c) {
    if (c.codeUnitAt(0) == 27) {
      return;
    }
    cache += c;
  }

  void delete() {
    if (cache.isEmpty) {
      return;
    }
    cache = cache.substring(0, cache.length - 1);
  }

  bool isBreak() {
    return false;
  }

  void clear() {
    cache = '';
    commands.clear();
  }

  String printCurrent({bool isPrint = true, int indent = 0}) {
    final indentStr = getIndentString(indent);
    var cmdStr = commands.join(' | ');
    if (cmdStr.isEmpty) {
      cmdStr = '无内容';
    }
    final str = '$indentStr${_pen(name)}: $cmdStr';
    if (isPrint) {
      printCmd(str);
    }
    return str;
  }
}

final _pen = AnsiPen()..red(bg: true);
final _penAct = AnsiPen()..magenta();

abstract class PrefixCommand extends CommandFilter {
  String get prefix;

  String? get clearCmd;

  Map<String, SubCommandModel> subCmdList = {};

  RegExp? cmdReg;

  @override
  void afterRun(bool isRun) {
    if (!isRun) {
      return;
    }
    subCmdList.forEach((key, value) {
      value.isActive = commands.join().contains(value.cmdList.join());
    });
  }

  @override
  bool onRun({bool printLog = true}) {
    cmdReg = null;
    if (cache == clearCmd) {
      commands.clear();
      return true;
    }
    if (!cache.startsWith(prefix)) {
      return false;
    }
    var command = cache.substring(1);
    final subCmd = command[0];
    cache = '';

    if (subCmdList.isEmpty) {
      addCommand(command);
      return true;
    }
    final cmd = subCmdList[subCmd];
    if (cmd == null) {
      addCommand(command);
      return true;
    }

    final cmdList = cmd.cmdList;
    if (cmdList.isEmpty) {
      addCommand(command);
      return true;
    }

    cmdList.forEach(addCommand);
    return true;
  }

  @override
  bool isMatchCommand(String command) {
    if (command.startsWith(prefix)) {
      return true;
    }
    return false;
  }

  @override
  String printCurrent({bool isPrint = true, int indent = 0}) {
    var msg = super.printCurrent(isPrint: false, indent: indent);
    if (subCmdList.isNotEmpty) {
      final indentStr = getIndentString(indent + 1);
      var subCmdStr = '$indentStr${_pen('快捷命令')}:\n';
      // 打印清空命令
      if (clearCmd != null) {
        subCmdStr +=
            '$indentStr  ${_pen(clearCmd!.trim().isEmpty ? '空格' : clearCmd!)} - 清空 $name\n';
      }
      // 打印子命令
      subCmdList.forEach((key, value) {
        final lStr = prefix + key;
        var left = _pen(lStr);
        if (value.isActive) {
          left += _penAct('(激活)');
        }
        final right = value.help;
        subCmdStr += '$indentStr  $left - $right\n';
      });

      // 组合父命令和子命令
      msg = '$msg \n${subCmdStr.substring(0, subCmdStr.length - 1)}';
    }

    if (isPrint) {
      printCmd(msg);
    }
    return msg;
  }

  @override
  void initConfig(Map config) {
    super.initConfig(config);
    afterRun(true);
  }
}

class SubCommandModel {
  SubCommandModel({
    this.cmdList = const [],
    required this.help,
    this.isActive = false,
  });

  List<String> cmdList;
  String help;

  bool isActive;
}

void printCmd(String message) {
  stdout.writeln('');
  stdout.writeln(topLine);
  stdout.writeln('');
  stdout.writeln(message);
  stdout.writeln('');
  stdout.writeln(topLine);
  stdout.writeln('');
}

String getIndentString(int indent) {
  if (indent <= 0) {
    return '';
  }
  var indentStr = '';
  for (var i = 0; i < indent; i++) {
    indentStr += '  ';
  }
  return indentStr;
}
