import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:frun/print_filters/processor/base.dart';
import 'package:tuple/tuple.dart';

const String _key = 'e: ';

class RedeclarationProcessor extends BuildProcessor {

  @override
  Future<List<String>?> doBiz(String message) async {
    stdout.writeln('RedeclarationProcessor: doBiz');

    final buildDir = Directory.current.child('build').asDir;
    if(buildDir == null) {
      '未找到build目录'.print();
      return null;
    }

    var list = message.split('\n');
    list = list.where((element) => element.trim().isNotEmpty).toList();
    list.forEach(toastErr);

    final t = find(list[0], ['/.pub-cache/git/', '/.pub-cache/hosted/'], 0);

    String package = '';
    if (t != null) {
      package = t.item2;
      if (t.item1 == 1) {
        var i = package.indexOf('/');
        package = package.substring(i + 1);
        i = package.indexOf('-');
        package = package.substring(0, i);
      } else {
        final i1 = package.indexOf('-');
        package = package.substring(0, i1);
      }
    }
    if(package.isEmpty) {
      '查找包失败'.print();
      return null;
    }

    '出错包为：$package'.print();

    final target = buildDir.child(package).asDir;
    if(target == null) {
      '构建目录（${buildDir.path}）不包含$package包'.print();
      return null;
    }

    await target.delete(recursive: true);

    '删除$package（${target.path}），重新打包'.printErr();

    return [];
  }

  @override
  bool isProcess(String message) {
    if (message.startsWith(_key) && message.contains(': Redeclaration: ')) {
      return true;
    }
    return false;
  }

  Tuple2<int, String>? find(String str, List<String> keys, int index) {
    if (keys.length <= index) {
      return null;
    }
    final key = keys[index];
    var i1 = str.indexOf(key);
    if (i1 == -1) {
      return find(str, keys, index + 1);
    }
    i1 += key.length;
    return Tuple2(index, str.substring(i1));
  }
}