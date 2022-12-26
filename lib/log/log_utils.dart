/// 这个使用flutter日志打印
class LogUtils {
  static const String _defTag = 'ZdLog';
  //是否是debug模式,true: log v 不输出.
  static bool _debugMode = true;
  static int _maxLen = 128;
  static String _tagValue = _defTag;

  static void init({
    String tag = _defTag,
    bool isDebug = false,
    int maxLen = 128,
  }) {
    _tagValue = tag;
    _debugMode = isDebug;
    _maxLen = maxLen;
  }

  ///打印debug日志
  static void d(Object object, {String? tag}) {
    if (_debugMode) {
      _printLog(tag ?? _defTag, ' d ', object);
    }
  }

  ///打印error日志
  static void e(Object object, {String? tag}) {
    _printLog(tag ?? _defTag, ' e ', object);
  }

  ///打印v日志
  static void v(Object object, {String? tag}) {
    if (_debugMode) {
      _printLog(tag ?? _defTag, ' v ', object);
    }
  }

  ///打印info日志
  static void i(Object object, {String? tag}) {
    if (_debugMode) {
      _printLog(tag ?? _defTag, ' i ', object);
    }
  }

  ///打印ware警告日志
  static void w(Object object, {String? tag}) {
    if (_debugMode) {
      _printLog(tag ?? _defTag, ' w ', object);
    }
  }

  static void _printLog(String tag, String stag, Object object) {
    String da = object.toString();

    if (da.length <= _maxLen) {
      print('$tag$stag $da');
      return;
    }
    print('$tag$stag — — — — — — — — — — st — — — — — — — — — — — — —');
    while (da.isNotEmpty) {
      if (da.length > _maxLen) {
        print('$tag$stag| ${da.substring(0, _maxLen)}');
        da = da.substring(_maxLen, da.length);
      } else {
        print('$tag$stag| $da');
        da = '';
      }
    }
    print('$tag$stag — — — — — — — — — — ed — — — — — — — — — ---— —');
  }
}

/// log print tools
class logger {
  static const _LOG_COLOR_TABLE = {
    LogLevel.verbose: "37",
    LogLevel.debug: "34",
    LogLevel.info: "32",
    LogLevel.warn: "33",
    LogLevel.error: "31",
  };

  /// control log print
  static bool logOpen = true;

  /// print error log
  static void e(String tag, Object msg) {
    log(LogLevel.error, tag, msg);
  }

  /// print warnning log
  static void w(String tag, Object msg) {
    log(LogLevel.warn, tag, msg);
  }

  /// print info log
  static void i(String tag, Object msg) {
    log(LogLevel.info, tag, msg);
  }

  /// print debug log
  static void d(String tag, Object msg) {
    log(LogLevel.debug, tag, msg);
  }

  /// print verbose log
  static void v(String tag, Object msg) {
    log(LogLevel.verbose, tag, msg);
  }

  /// print custom log
  static void log(int level, String tag, Object msg) {
    if (logOpen) {
      if (tag.isEmpty) {
        tag = "TXFlutterPlayer";
      }
      if (level < LogLevel.verbose) {
        level = LogLevel.verbose;
      }
      if (level > LogLevel.error) {
        level = LogLevel.error;
      }
      StringBuffer logStrBuffer = StringBuffer();
      logStrBuffer.write(tag);
      logStrBuffer.write(":");
      logStrBuffer.write("\t");
      logStrBuffer.write(msg.toString());
      print(_effectLevel(level, logStrBuffer.toString()));
    }
  }

  static String _effectLevel(int level, String str) {
    String formateStr = '\x1B[${_LOG_COLOR_TABLE[level]}m $str \x1B[0m';
    return formateStr;
  }
}

class LogLevel {
  static const verbose = 1;
  static const debug = 2;
  static const info = 3;
  static const warn = 4;
  static const error = 5;
}
