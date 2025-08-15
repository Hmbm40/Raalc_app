import 'package:flutter/foundation.dart';

typedef LogSink = void Function(String message, {Object? error, StackTrace? stackTrace});

class Log {
  static LogSink infoSink   = _defaultPrint;
  static LogSink warnSink   = _defaultPrint;
  static LogSink errorSink  = _defaultPrint;
  static LogSink debugSink  = _defaultPrint;

  static void i(String m, {Object? error, StackTrace? stackTrace}) => infoSink(_fmt('I', m), error: error, stackTrace: stackTrace);
  static void w(String m, {Object? error, StackTrace? stackTrace}) => warnSink(_fmt('W', m), error: error, stackTrace: stackTrace);
  static void e(String m, {Object? error, StackTrace? stackTrace}) => errorSink(_fmt('E', m), error: error, stackTrace: stackTrace);
  static void d(String m, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) debugSink(_fmt('D', m), error: error, stackTrace: stackTrace);
  }

  static String _fmt(String lvl, String m) => '[$lvl] $m';
  static void _defaultPrint(String m, {Object? error, StackTrace? stackTrace}) {
    // ignore: avoid_print
    print(error == null ? m : '$m  error=$error\n$stackTrace');
  }
}
