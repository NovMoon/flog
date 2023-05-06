import 'filter.dart';
import 'package:ansicolor/ansicolor.dart';

const _cmdMultiWord = ':1';
const _cmdNoMultiWord = ':2';

class SearchFilter extends PrefixCommand {
  SearchFilter() {
    subCmdList['1'] = _multiCmd;
    subCmdList['2'] = _noMultiCmd;
  }

  List<String> history = [];
  int _historyIndex = 0;
  AnsiPen pen = AnsiPen()..green(bg: true);

  bool isMultiWord = true;

  final SubCommandModel _multiCmd = SubCommandModel(
    cmdList: [_cmdMultiWord],
    help: '支持多个关键字搜索',
    isActive: true,
  );
  final SubCommandModel _noMultiCmd = SubCommandModel(
    cmdList: [_cmdNoMultiWord],
    help: '不支持多个关键字搜索',
  );

  @override
  String? filter(String message) {
    if (commands.isEmpty) return message;
    cmdReg ??= RegExp(commands.join('|'), caseSensitive: false);
    if (cmdReg != null) {
      if (!message.contains(cmdReg!)) {
        return null;
      }
    }
    message = message.replaceAllMapped(cmdReg!, (match) {
      final m = match.group(0);
      if (m?.isEmpty == true) {
        return '';
      }
      return pen(m!);
    });
    return message;
  }

  @override
  void afterRun(bool isRun) {
    super.afterRun(isRun);
    if (!isRun) {
      return;
    }
    String? command = commands.isEmpty ? null : commands.last;
    switch (command) {
      case _cmdMultiWord:
        isMultiWord = true;
        commands.clear();
        break;
      case _cmdNoMultiWord:
        isMultiWord = false;
        commands.clear();
        break;
    }
    if (isMultiWord) {
      _multiCmd.isActive = true;
      _noMultiCmd.isActive = false;
    } else {
      _multiCmd.isActive = false;
      _noMultiCmd.isActive = true;
    }
  }

  @override
  bool onRun({bool printLog = true}) {
    cmdReg = null;
    if (cache == ' ') {
      commands.clear();
      return true;
    }

    if (!isMultiWord) {
      commands.clear();
    }

    addCommand(cache);
    return true;
  }

  @override
  void addCommand(String command) {
    super.addCommand(command);
    if (history.contains(command)) {
      return;
    }
    history.add(command);
  }

  @override
  void moreLetters(String c) {
    if (c.codeUnitAt(0) == 27) {
      if (history.isEmpty) {
        return;
      }
      if (history.length <= _historyIndex) {
        _historyIndex = 0;
      }
      cache = history[_historyIndex++];
      return;
    }
    super.moreLetters(c);
  }

  @override
  void initConfig(Map config) {
    final map = config['search'] as Map? ?? {};
    isMultiWord = map['multiWord'] ?? true;
    super.initConfig(config);
  }

  @override
  Map getDefaultConfig() => {
        'search': {
          'multiWord': true,
        },
      };

  @override
  bool isFilter(String message) => true;

  @override
  bool isMatchCommand(String command) => true;

  @override
  String get name => '搜索';

  @override
  String get prefix => ':';

  @override
  String get clearCmd => ' ';
}
