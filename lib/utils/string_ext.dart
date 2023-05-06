const String _l1 = '****';
const String _l2 = '----';

extension StringExt on String {}

extension IntExt on int {
  String get dividerOuter => _l1 * this;

  String get dividerInner => _l2 * this;

  String get emptyStr => ' ' * this;

  Iterable get iterable {
    return [for (var i = 0; i < this; i++) i];
  }
}
