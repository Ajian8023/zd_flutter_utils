import 'dart:core';
import 'dart:ui';

import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:zd_flutter_utils/flutter_utils.dart';

typedef OnResponseCallback = void Function(Response response);
typedef OnRequestCallback = void Function(RequestOptions response);

class DioInterceptor extends Interceptor {
  VoidCallback? _connectTimeoutCallBack;
  VoidCallback? _sendTimeoutCallBack;
  VoidCallback? _receiveTimeoutCallBack;
  VoidCallback? _cancelCallBack;
  VoidCallback? _otherCallBack;
  VoidCallback? _responseCallBack;
  VoidCallback? _wifiNetWorkCallBack;
  VoidCallback? _noneNetWorkCallBack;
  VoidCallback? _mobileNetWorkCallBack;
  OnResponseCallback? _onResponseCallback;
  OnRequestCallback? _onRequestCallback;
  bool _useDioLogPrint;

  DioInterceptor(
    this._connectTimeoutCallBack,
    this._sendTimeoutCallBack,
    this._receiveTimeoutCallBack,
    this._cancelCallBack,
    this._otherCallBack,
    this._responseCallBack,
    this._wifiNetWorkCallBack,
    this._noneNetWorkCallBack,
    this._mobileNetWorkCallBack,
    this._onResponseCallback,
    this._onRequestCallback,
    this._useDioLogPrint,
  );

  onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (_onRequestCallback != null) {
      _onRequestCallback!(options);
    }
    _assessNetWork();
    //如果全局输出  、 并且携带requestLog 那么默认输出  如果
    if (_useDioLogPrint && !ObjectUtils.isEmptyMap(options.extra) && options.extra['requestLogPrint'] == true) {
      LogUtils.i("请求URL :" + options.baseUrl, tag: "ZdNetRequest");
      LogUtils.i("请求方法 :" + options.path, tag: "ZdNetRequest");
      LogUtils.i("请求类型 :" + options.method, tag: "ZdNetRequest");
      if (options.method == "GET") {
        LogUtils.i("请求参数 :" + options.queryParameters.toJsonString(), tag: "ZdNetRequest");
      } else {
        LogUtils.i("请求参数 :" + options.data.toString(), tag: "ZdNetRequest");
      }
      if (!ObjectUtils.isEmptyMap(options.extra)) {
        LogUtils.i("携带extra :" + options.extra.toJsonString(), tag: "ZdNetRequest");
      }
    }

    return handler.next(options);
  }

  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    if (_onResponseCallback != null) {
      _onResponseCallback!(response);
    }
    return handler.next(response);
  }

  Future<void> onError(
    DioError e,
    ErrorInterceptorHandler handler,
  ) async {
    if (e.type == DioErrorType.connectTimeout) {
      _connectTimeoutCallBack?.call();

      _dioErrLog(e, title: "连接ERROR", message: "请求超时", tag: 'ZdNetError ConnectTimeout');
    } else if (e.type == DioErrorType.sendTimeout) {
      _sendTimeoutCallBack?.call();
      _dioErrLog(e, title: "请求ERROR", message: "请求超时", tag: 'ZdNetError SendTimeout');

      // It occurs when url is sent timeout.

    } else if (e.type == DioErrorType.receiveTimeout) {
      _receiveTimeoutCallBack?.call();

      _dioErrLog(e, title: "响应ERROR", message: "响应超时", tag: "ZdNetError ReceiveTimeout");
    } else if (e.type == DioErrorType.response) {
      _responseCallBack?.call();
      _dioErrLog(e, title: "服务器异常ERROR", message: "服务器出现异常", tag: "ZdNetError ResponseError");

      LogUtils.e("Error---------------------------${e}");
    } else if (e.type == DioErrorType.cancel) {
      _cancelCallBack?.call();
      _dioErrLog(e, title: "请求取消", message: "请求取消", tag: "ZdNetError Cancel");
    } else {
      _otherCallBack?.call();
      print(e);
      _dioErrLog(e, title: "未知异常", message: "未知异常", tag: "ZdNetError OtherError");
    }

    handler.next(e);
  }

  /*
   * 判断网络
   */
  _assessNetWork() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      // I am connected to a mobile network.
      LogUtils.i("I am connected to a mobile network.");
      _mobileNetWorkCallBack?.call();
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a wifi network.

      _wifiNetWorkCallBack?.call();
      LogUtils.i("I am connected to a wifi network.");
    } else if (connectivityResult == ConnectivityResult.none) {
      _noneNetWorkCallBack?.call();
    }
  }

  _dioErrLog(DioError e, {String? title, String? tag, String? message}) {
    // It occurs when url is opened timeout.
    LogUtils.e("----------${message}----------", tag: tag);

    LogUtils.e("${title} URL :" + e.requestOptions.baseUrl, tag: tag);
    LogUtils.e("${title} 方法 :" + e.requestOptions.path, tag: tag);
    LogUtils.e("${title} 类型 :" + e.requestOptions.method, tag: tag);
    if (e.requestOptions.method == "GET") {
      LogUtils.e("${title} 参数 :" + e.requestOptions.queryParameters.toJsonString(), tag: tag);
    } else {
      LogUtils.e("${title} 参数 :" + e.requestOptions.data.toString(), tag: tag);
    }
    if (ObjectUtils.isEmptyMap(e.requestOptions.extra)) {
      LogUtils.e("${title} extra :" + e.requestOptions.extra.toJsonString(), tag: tag);
    }
  }
}
