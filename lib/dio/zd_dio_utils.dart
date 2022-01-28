import 'dart:convert';
import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';

import 'package:flutter/foundation.dart';

import 'package:zd_flutter_utils/flutter_utils.dart';

import 'dio_log_Interceptor.dart';

/*
 * 封装 restful 请求
 *
 * GET、POST、DELETE、PUT、DOWNLOAD、UPLOAD
 * 主要作用为统一处理相关事务：
 *  - 统一处理请求前缀；
 *  - 统一打印请求信息；
 *  - 统一打印响应信息；
 *  - 统一打印报错信息；
 *  
 */
typedef ProgressCallback = void Function(int count, int total);

class ZdNetUtil {
  static ZdNetUtil _instance = ZdNetUtil._internal();
  factory ZdNetUtil() => _instance;
  CancelToken cancelToken = new CancelToken();
  BaseOptions? _options;
  static String _appName = '';
  static String _version = '';

  ///错误处理
  static VoidCallback? _connectTimeoutCallBack;

  static VoidCallback? _sendTimeoutCallBack;
  static VoidCallback? _receiveTimeoutCallBack;
  static VoidCallback? _cancelCallBack;
  static VoidCallback? _otherCallBack;
  static VoidCallback? _responseCallBack;
  static VoidCallback? _noneNetWorkCallBack;

  ///check网络callback
  static VoidCallback? _mobileNetWorkCallBack;
  static VoidCallback? _wifiNetWorkCallBack;

  static Dio? _dio;

  static String? _baseUrl;
  static int? _connectTimeout;
  static int? _receiveTimeout;
  static ResponseType? _responseType;
  //baseHeader 列表
  static Map<String, dynamic>? _baseHeader;
  static String? _contentType;
  /*
   * 必须初始化 
   * baseUrl:基础网络请求连接
   * */

  static preInit({
    required String baseUrl,
    Map<String, dynamic>? header,
    int? connectTimeout,
    int? receiveTimeout,
    String? contentType,
    ResponseType? responseType,
    VoidCallback? connectTimeoutCallBack,
    VoidCallback? sendTimeoutCallBack,
    VoidCallback? receiveTimeoutCallBack,
    VoidCallback? cancelCallBack,
    VoidCallback? otherCallBack,
    VoidCallback? responseCallBack,
    VoidCallback? noneNetWorkCallBack,
    VoidCallback? mobileNetWorkCallBackl,
    VoidCallback? wifiNetWorkCallBack,
  }) {
    _baseUrl = baseUrl;
    _baseHeader = header ?? _baseHeader;
    _connectTimeout = connectTimeout;
    _receiveTimeout = receiveTimeout;
    _responseType = responseType;
    _contentType = contentType;

    ///errorCallBack
    ///
    ///
    _connectTimeoutCallBack = connectTimeoutCallBack;
    _sendTimeoutCallBack = sendTimeoutCallBack;
    _receiveTimeoutCallBack = receiveTimeoutCallBack;
    _cancelCallBack = cancelCallBack;
    _otherCallBack = otherCallBack;
    _responseCallBack = responseCallBack;

    ///检查无网络操作
    _noneNetWorkCallBack = noneNetWorkCallBack;
    _mobileNetWorkCallBack = mobileNetWorkCallBackl;
    _wifiNetWorkCallBack = wifiNetWorkCallBack;
  }

  // 通用全局单例初始化
  ZdNetUtil._internal() {
    ///通用全局单例，第一次使用时初始化
    if (null == _dio) {
      _options = new BaseOptions(

          ///请求的基础地址
          baseUrl: _baseUrl ?? "",

          ///相应超时时间
          connectTimeout: _connectTimeout ?? 150000,

          ///响应流上次请求时间
          receiveTimeout: _receiveTimeout ?? 7000,

          ///请求头
          headers: _baseHeader ?? _zdHeaders,

          ///请求 contentType
          contentType: _contentType ?? Headers.formUrlEncodedContentType,
          responseType: _responseType ?? ResponseType.json);

      _dio = new Dio(_options);

      _dio!.interceptors.add(new DioLogInterceptor(
          _connectTimeoutCallBack,
          _sendTimeoutCallBack,
          _receiveTimeoutCallBack,
          _cancelCallBack,
          _otherCallBack,
          _responseCallBack));
//      _dio.interceptors.add(new PrettyDioLogger());
      //_dio!.interceptors.add(new ResponseInterceptors(0));
    }
  }

  ///可指定域名
  static ZdNetUtil getInstance({String? baseUrl}) {
    //initPackageInfo();
    if (baseUrl == null) {
      return _instance._normal();
    } else {
      return _instance._appointUrl(baseUrl);
    }
  }

  //用于指定特定域名
  ZdNetUtil _appointUrl(String baseUrl) {
    if (_dio != null) {
      _dio!.options.baseUrl = baseUrl;
    }
    return this;
  }

  //一般请求，默认域名
  ZdNetUtil _normal() {
    if (_dio != null) {
      if (_dio!.options.baseUrl != _baseUrl) {
        if (ObjectUtils.isEmptyString(_baseUrl)) {
          LogUtils.e("baseUrl不可为空", tag: "ZdNetUtil");
        } else {
          _dio!.options.baseUrl = _baseUrl!;
        }
      }
    }
    return this;
  }

  /*
   * 取消请求
   *
   * 同一个cancel token 可以用于多个请求，当一个cancel token取消时，所有使用该cancel token的请求都会被取消。
   * 所以参数可选
   */
  void cancelRequests(CancelToken token) {
    token.cancel("cancelled");
  }

  /// 自定义Header

  Map<String, dynamic> _zdHeaders = {
    //'mobile_phone_type': GetPlatform.isAndroid ? "Android" : "IOS",
  };

  // ///初始化设备信息
  // static void initPackageInfo() {
  //   PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
  //     _appName = packageInfo.appName;
  //     _version = packageInfo.version;
  //   });
  // }

  /*
   * get请求
   */
  get({
    required String url,
    Map<String, dynamic>? data,
    Options? options,
    CancelToken? cancelToken,
    String? title,
    VoidCallback? startRequest,
    VoidCallback? endRequest,
    bool? useResponsePrint = true,
  }) async {
    await _assessNetWork();
    Response? response;

    try {
      startRequest?.call();
      response = await _dio!.get(url,
          queryParameters: data ?? {},
          options: options,
          cancelToken: cancelToken);

      useResponsePrint!
          ? JsonUtils.printRespond(response, titile: title ?? url)
          : null;
    } on DioError catch (e) {}
    endRequest?.call();

    return response?.data;
  }

  /*
   * post请求
   */
  post({
    required String url,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    String? title,
    VoidCallback? startRequest,
    VoidCallback? endRequest,
    bool? useResponsePrint = true,
  }) async {
    await _assessNetWork();
    Response? response;

    try {
      startRequest?.call();
      response = await _dio!
          .post(url, data: data, options: options, cancelToken: cancelToken);
      useResponsePrint!
          ? JsonUtils.printRespond(response, titile: title ?? url)
          : null;
    } on DioError catch (e) {}
    endRequest?.call();
    return response?.data;
  }

  /*
   * put请求
   */
  put({
    required String url,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    String? title,
    VoidCallback? startRequest,
    VoidCallback? endRequest,
    bool? useResponsePrint = true,
  }) async {
    await _assessNetWork();
    Response? response;
    try {
      startRequest?.call();
      response = await _dio!
          .put(url, data: data, options: options, cancelToken: cancelToken);
      useResponsePrint!
          ? JsonUtils.printRespond(response, titile: title ?? url)
          : null;
      ;
    } on DioError catch (e) {}
    endRequest?.call();
    return response?.data;
  }

  /*
   * delete请求
   */
  delete({
    required String url,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    String? title,
    VoidCallback? startRequest,
    VoidCallback? endRequest,
    bool? useResponsePrint = true,
  }) async {
    await _assessNetWork();
    Response? response;
    try {
      startRequest?.call();
      response = await _dio!
          .delete(url, data: data, options: options, cancelToken: cancelToken);
      useResponsePrint!
          ? JsonUtils.printRespond(response, titile: title ?? url)
          : null;
      ;
    } on DioError catch (e) {}
    endRequest?.call();
    return response?.data;
  }

/*
   * 上传文件
   */
  upload(
      {required String url,
      required String path,
      required String imageName,
      Options? options,
      CancelToken? cancelToken,
      String? title,
      String? imageType,
      bool useResponsePrint = true,
      ProgressCallback? onReceiveProgress,
      ProgressCallback? onSendProgress}) async {
    await _assessNetWork();
    Response? response;

    Map<String, dynamic> map = Map();
    if (ObjectUtils.isEmptyString(imageType)) {
      map["file"] =
          await MultipartFile.fromFile(path, filename: imageName + imageType!);
    } else {
      map["file"] =
          await MultipartFile.fromFile(path, filename: imageName + ".png");
    }

    FormData formData = FormData.fromMap(map);
    try {
      response = await _dio!.post(
        url,
        data: formData,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: (count, total) {
          if (onReceiveProgress != null) {
            onReceiveProgress(count, total);
          }
        },
        onSendProgress: (count, total) {
          if (onSendProgress != null) {
            onSendProgress(count, total);
          }
        },
      );
      useResponsePrint
          ? JsonUtils.printRespond(response, titile: title ?? "上传")
          : null;
      ;
    } on DioError catch (e) {}
    return response?.data;
  }

  /*
   * 下载文件
   */
  downloadFile({
    required String urlPath,
    required String dirName,
    required String fileName,
    String? title,
    ProgressCallback? onReceiveProgress,
    bool useResponsePrint = true,
  }) async {
    await _assessNetWork();
    Response? response;
    var path = '';
    try {
      path = await StorageUtils.getAppDocPath(
          fileName: fileName, dirName: dirName);
      response = await _dio!.download(urlPath, path,
          onReceiveProgress: (int count, int total) {
        //进度
        ;
        useResponsePrint
            ? LogUtils.d("下载进度:$count $total", tag: "DownloadFile")
            : null;
        if (onReceiveProgress != null) {
          onReceiveProgress(count, total);
        }
      });
    } on DioError catch (e) {
      print('downloadFile error---------$e');
    }

    return path;
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
}
