import 'package:dio/dio.dart';
import 'package:zd_flutter_utils/flutter_utils.dart';
import 'dart:core';
import 'dart:ui';

class DioLogInterceptor extends Interceptor {
  VoidCallback? _connectTimeoutCallBack;
  VoidCallback? _sendTimeoutCallBack;
  VoidCallback? _receiveTimeoutCallBack;
  VoidCallback? _cancelCallBack;
  VoidCallback? _otherCallBack;
  VoidCallback? _responseCallBack;

  DioLogInterceptor(
      this._connectTimeoutCallBack,
      this._sendTimeoutCallBack,
      this._receiveTimeoutCallBack,
      this._cancelCallBack,
      this._otherCallBack,
      this._responseCallBack);

  onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    LogUtils.i("请求URL :" + options.baseUrl, tag: "ZdNetRequest");
    LogUtils.i("请求方法 :" + options.path, tag: "ZdNetRequest");
    LogUtils.i("请求类型 :" + options.method, tag: "ZdNetRequest");
    if (options.method == "GET") {
      LogUtils.i("请求参数 :" + options.queryParameters.toJsonString(),
          tag: "ZdNetRequest");
    } else {
      LogUtils.i("请求参数 :" + options.data.toJsonString(), tag: "ZdNetRequest");
    }
    if (ObjectUtils.isEmptyMap(options.extra)) {
      LogUtils.i("携带extra :" + options.extra.toJsonString(),
          tag: "ZdNetRequest");
    }
    return handler.next(options);
  }

  void onError(
    DioError e,
    ErrorInterceptorHandler handler,
  ) {
    if (e.type == DioErrorType.connectTimeout) {
      _connectTimeoutCallBack?.call();

      _dioErrLog(e,
          title: "连接ERROR", message: "请求超时", tag: 'ZdNetError ConnectTimeout');
    } else if (e.type == DioErrorType.sendTimeout) {
      _sendTimeoutCallBack ?? fun();
      _dioErrLog(e,
          title: "请求ERROR", message: "请求超时", tag: 'ZdNetError SendTimeout');

      // It occurs when url is sent timeout.

    } else if (e.type == DioErrorType.receiveTimeout) {
      _receiveTimeoutCallBack ?? fun();

      _dioErrLog(e,
          title: "响应ERROR", message: "响应超时", tag: "ZdNetError ReceiveTimeout");
    } else if (e.type == DioErrorType.response) {
      _responseCallBack ?? fun();
      _dioErrLog(e,
          title: "异常ERROR", message: "出现异常", tag: "ZdNetError ResponseError");

      LogUtils.e("Error---------------------------${e}");
    } else if (e.type == DioErrorType.cancel) {
      _cancelCallBack ?? fun();
      _dioErrLog(e, title: "请求取消", message: "请求取消", tag: "ZdNetError Cancel");
    } else {
      _otherCallBack ?? fun();
      _dioErrLog(e,
          title: "未知异常", message: "未知异常", tag: "ZdNetError OtherError");

      LogUtils.e("Error---------------------------${e}");
    }

    handler.next(e);
  }

  void fun() {
    print("ee");
  }

  _dioErrLog(DioError e, {String? title, String? tag, String? message}) {
    // It occurs when url is opened timeout.
    LogUtils.e("----------${message}----------", tag: tag);

    LogUtils.e("${title} URL :" + e.requestOptions.baseUrl, tag: tag);
    LogUtils.e("${title} 方法 :" + e.requestOptions.path,
        tag: "ZdNetError ConnectTimeout");
    LogUtils.e("${title} 类型 :" + e.requestOptions.method, tag: tag);
    if (e.requestOptions.method == "GET") {
      LogUtils.e(
          "${title} 参数 :" + e.requestOptions.queryParameters.toJsonString(),
          tag: tag);
    } else {
      LogUtils.e("${title} 参数 :" + e.requestOptions.data.toJsonString(),
          tag: tag);
    }
    if (ObjectUtils.isEmptyMap(e.requestOptions.extra)) {
      LogUtils.e("${title} extra :" + e.requestOptions.extra.toJsonString(),
          tag: tag);
    }
  }
}
