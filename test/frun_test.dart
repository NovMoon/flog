import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

void main() {
  RegExp regex1 = RegExp(r'\[\d+;\d;\d+m|\[0m');
  // RegExp regex1 = RegExp(r'\[38;5;\d+m|\[0m');
  String text = 'I/flutter (29382): [38;5;13m[D][0m [48;5;13mtime:[0m: 2023-11-12T23:10:44.084472 [38;5;13mtag:[0m: SafelyOnError [38;5;13mmsg:[0m SafelyOnError error=Bad state: No element; stackTrace=#0';

  text = text.replaceAll(regex1, '');
  // text = text.replaceAll(regex2, '');

  print(text);
}
