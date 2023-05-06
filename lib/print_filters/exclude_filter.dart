import 'filter.dart';

const _cmd1 = [
  'checkFileExit',
  'uploadEvent',
  'cdnExceptionMonitor',
  '(HTTPLog)-Static',
  'Logan',
  'interLog',
  'checkFileExit',
  'topic',
  'cts',
  'bb_dialog',
  'NavigatorPageLifecycleMixin',
  'mrt',
  'FlutterApm',
  'ConfigCenterImpl',
  'ConsoleLogger',
  'reportPage',
  'WebSocketChannel',
  'BybitDialogPageObserver',
  'DebounceUnique',
];

class ExcludeFilter extends PrefixCommand {
  ExcludeFilter() {
    subCmdList['1'] = SubCommandModel(
      cmdList: _cmd1,
      help: '内置排除组1（${_cmd1.join(',')}）',
    );
  }

  @override
  String? filter(String message) {
    if (commands.isEmpty) return message;
    cmdReg ??= RegExp(commands.join('|'), caseSensitive: false);
    if (message.contains(cmdReg!)) {
      return null;
    }
    return message;
  }

  @override
  bool isFilter(String message) => true;

  @override
  String get name => '排除';

  @override
  String get prefix => '!';

  @override
  void initConfig(Map config) {
    final exclude = config['exclude'] as Map? ?? {};
    final list = exclude['list'] as List? ?? [];
    commands.addAll(list.map((e) => e.toString()));

    super.initConfig(config);
  }

  @override
  Map getDefaultConfig() => {
        'exclude': {
          'list': [
            'checkFileExit',
            'uploadEvent',
            'cdnExceptionMonitor',
            '(HTTPLog)-Static',
            'Logan',
            'interLog',
            'checkFileExit',
            'topic',
            'cts',
            'bb_dialog',
            'NavigatorPageLifecycleMixin',
            'mrt',
            'FlutterApm',
            'ConfigCenterImpl',
            'ConsoleLogger',
            'reportPage',
            'WebSocketChannel',
            'BybitDialogPageObserver',
            'DebounceUnique',
          ],
        },
      };

  @override
  String get clearCmd => '!!';
}
