import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:flutter/foundation.dart';
import 'package:package_info/package_info.dart';
import 'package:zd_flutter_utils/flutter_utils.dart';

/*
 * 封装 restful 请求
 *
 * GET、POST、DELETE、PATCH
 * 主要作用为统一处理相关事务：
 *  - 统一处理请求前缀；
 *  - 统一打印请求信息；
 *  - 统一打印响应信息；
 *  - 统一打印报错信息；
 */
enum HttpMethod { GET, POST, DELETE, PUT, DOWNLOAD }

class ZdNetUtil {
  static ZdNetUtil? instance;
  CancelToken cancelToken = new CancelToken();
  BaseOptions? options;
  static String appName = '';
  static String version = "";

  static const String GET = 'get';
  static const String POST = 'post';
  static const String PUT = 'put';
  static const String PATCH = 'patch';
  static const String DELETE = 'delete';

  static Dio? dio;

  static String? baseUrl;
  static int? connectTimeout;
  static int? receiveTimeout;
  static Map<String, dynamic>? map;
  static ResponseType? responseType;

  //header 列表
  Map<String, String> header = {"version": version, "appName": appName};

  ///初始化 网络请求
  static ZdNetUtil? getInstance() {
    initPackageInfo();
    if (ObjectUtils.isEmpty(instance)) {
      instance = new ZdNetUtil();

      LogUtils.d("初始化成功", tag: "ZdNetUtils");
      return instance;
    }
    LogUtils.d("初始化成功", tag: "ZdNetUtils");
    return instance;
  }

  /*
  * baseUrl:请求基础地址
  * */
  ZdNetUtil() {
    options = new BaseOptions(

        ///请求的基础地址
        baseUrl: baseUrl ?? "",

        ///相应超时时间
        connectTimeout: connectTimeout ?? 150000,

        ///响应流上次请求时间
        receiveTimeout: receiveTimeout ?? 7000,

        ///请求头
        headers: map ?? header,

        ///请求 contentType
        contentType: Headers.formUrlEncodedContentType,
        responseType: responseType ?? ResponseType.json);

    dio = new Dio(options);

    //添加拦截器
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

  ///添加带初始信息 header
  ZdNetUtil addHeader(String k, Object v) {
    header[k] = v.toString();
    return this;
  }

  ///初始化设备信息
  static initPackageInfo() {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      appName = packageInfo.appName;
      version = packageInfo.version;
    });
  }

  /*
   * get请求
   */
  get(url, {data, options, cancelToken, title}) async {
    Response? response;
    try {
      response = await dio!.get(url,
          queryParameters: data, options: options, cancelToken: cancelToken);

      JsonUtils.printRespond(response, titile: title);
    } on DioError catch (e) {
      print('get error---------$e');
      formatError(e);
    }
    return response?.data;
  }

  /*
   * post请求
   */
  post(url, {data, options, cancelToken}) async {
    Response? response;
    try {
      response = await dio!.post(url,
          queryParameters: data, options: options, cancelToken: cancelToken);
      print('post success---------${response.data}');
    } on DioError catch (e) {
      print('post error---------$e');
      formatError(e);
    }
    return response?.data;
  }

  /*
   * 下载文件
   */
  downloadFile(urlPath, savePath) async {
    Response? response;
    try {
      response = await dio!.download(urlPath, savePath,
          onReceiveProgress: (int count, int total) {
        //进度
        ;
        LogUtils.d("$count $total", tag: "DownloadFile");
      });

      JsonUtils.printRespond(response, titile: "downloadFile success");
    } on DioError catch (e) {
      print('downloadFile error---------$e');
      formatError(e);
    }

    return response!.data;
  }

  /*
   * error统一处理
   */
  void formatError(DioError e) {
    if (e.type == DioErrorType.connectTimeout) {
      // It occurs when url is opened timeout.
      LogUtils.d("请求超时", tag: "ZdNetUtil");
    } else if (e.type == DioErrorType.sendTimeout) {
      // It occurs when url is sent timeout.
      LogUtils.d("请求超时", tag: "ZdNetUtil");
    } else if (e.type == DioErrorType.receiveTimeout) {
      //It occurs when receiving timeout
      LogUtils.d("响应超时", tag: "ZdNetUtil");
    } else if (e.type == DioErrorType.response) {
      // When the server response, but with a incorrect status, such as 404, 503...
      LogUtils.d("出现异常", tag: "ZdNetUtil");
    } else if (e.type == DioErrorType.cancel) {
      // When the request is cancelled, dio will throw a error with this type.
      LogUtils.d("请求取消", tag: "ZdNetUtil");
    } else {
      //DEFAULT Default error type, Some other Error. In this case, you can read the DioError.error if it is not null.
      LogUtils.d("未知错误", tag: "ZdNetUtil");
    }
  }
}
