class Logger {
  static Logger? _instance;
  factory Logger() {
    return _instance ??= Logger._();
  }
  Logger._();
  void init() {}
}
