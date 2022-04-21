import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/cupertino.dart';
import 'package:zd_flutter_utils/log/log_utils.dart';

/// json 格式转化工具类
class JsonUtils {
  /// 单纯的Json格式输出打印
  static void printJson(Object object) {
    try {
      JsonEncoder encoder = JsonEncoder.withIndent('  ');
      var encoderString = encoder.convert(object);
      LogUtils.i(encoderString, tag: "json:");
    } catch (e) {
      LogUtils.e(e, tag: "json:");
    }
  }

  /// 单纯的Json格式输出打印
  static void printJsonDebug(Object object) {
    try {
      JsonEncoder encoder = JsonEncoder.withIndent('  ');
      var encoderString = encoder.convert(object);
      // print(encoderString);
      // 不使用print()方法是因为这是单条输出，如果过长无法显示全
      // 所以使用debugPrint()
      debugPrint(encoderString);
      // 下面这语句的效果与debugPrint 相同
      //encoderString.split('\n').forEach((element) => print(element));
    } catch (e) {
      print(e);
    }
  }

  /// 单纯的Json格式输出打印
  static void printJsonEncode(Object object) {
    try {
      var encoderString = json.encode(object);
      LogUtils.i(encoderString, tag: "json:");
    } catch (e) {
      LogUtils.e(e, tag: "json:");
    }
  }

  /// 接收Dio请求库返回的Response对象
  static void printRespond(Response response, {String? titile}) {
       if (null != response.headers.value(DIO_CACHE_HEADER_KEY_DATA_SOURCE)) {
           LogUtils.i('--------comingForCache--------');
         print(
        "-------------------------------------------【cache-$titile】-------------------------------------------");
     
    } else {
      // data come from net
         LogUtils.i('--------comingForNet--------');
       print(
        "-------------------------------------------【net-$titile】-------------------------------------------");
   
    }
    
    Map httpLogMap = Map();
     httpLogMap.putIfAbsent(
        "请求URL", () => "${response.requestOptions.uri}");
    httpLogMap.putIfAbsent("请求头", () => response.requestOptions.headers);
    httpLogMap.putIfAbsent(
        "query参数", () => response.requestOptions.queryParameters);
    httpLogMap.putIfAbsent('body参数',()=>response.data);
    httpLogMap.putIfAbsent("响应数据", () => response.data);


    printJsonDebug(httpLogMap);
    print(
        "-------------------------------------------【end】-------------------------------------------");
  }

  /// 将对象[值]转换为JSON字符串
  /// Converts object [value] to a JSON string.
  static String encodeObj(dynamic value) {
    return json.encode(value);
  }

  /// 转换JSON字符串到对象
  /// Converts JSON string [source] to object.
  static T getObj<T>(String source, T f(Map<String, dynamic> v)) {
    try {
      Map<String, dynamic> map = json.decode(source);
      return f(map);
    } catch (e) {
      print('JsonUtils convert error, Exception：${e.toString()}');
      return f(Map());
    }
  }

  /// 转换JSON字符串或JSON映射[源]到对象
  /// Converts JSON string or JSON map [source] to object.
  static T getObject<T>(dynamic source, T f(Map<String, dynamic> v)) {
    try {
      Map<String, dynamic> map;
      if (source is String) {
        map = json.decode(source);
      } else {
        map = source;
      }
      return f(map);
    } catch (e) {
      print('JsonUtils convert error, Exception：${e.toString()}');
      return f(Map());
    }
  }

  /// 转换JSON字符串列表[源]到对象列表
  /// Converts JSON string list [source] to object list.
  static List<T> getObjList<T>(String source, T f(Map<String, dynamic> v)) {
    try {
      List list = json.decode(source);
      return list.map((value) {
        if (value is String) {
          value = json.decode(value);
        }
        return f(value);
      }).toList();
    } catch (e) {
      print('JsonUtils convert error, Exception：${e.toString()}');
      return List.empty(growable: true);
    }
  }

  /// 转换JSON字符串或JSON映射列表[源]到对象列表
  /// Converts JSON string or JSON map list [source] to object list.
  static List<T>? getObjectList<T>(dynamic source, T f(Map v)) {
    if (source == null || source.toString().isEmpty) return null;
    try {
      List list;
      if (source is String) {
        list = json.decode(source);
      } else {
        list = source;
      }
      return list.map((value) {
        if (value is String) {
          value = json.decode(value);
        }
        return f(value);
      }).toList();
    } catch (e) {
      print('JsonUtils convert error, Exception：${e.toString()}');
    }
    return null;
  }

  /// get List
  static List<T>? getList<T>(dynamic source) {
    List list;
    if (source is String) {
      list = json.decode(source);
    } else {
      list = source;
    }
    return list.map((v) {
      return v as T;
    }).toList();
  }
}
