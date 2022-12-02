import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/foundation.dart';
import 'package:postman_dio/postman_dio.dart';
import 'package:zd_flutter_utils/flutter_utils.dart';
import 'package:sentry_dio/sentry_dio.dart';
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
  DioCacheManager? _dioCacheManager;
  CancelToken cancelToken = new CancelToken();
  BaseOptions? _options;
  static String _appName = '';
  static String _version = '';
  static String _findProxyUrl = '127.0.0.1:8888';

  ///错误处理
  static VoidCallback? _connectTimeoutCallBack;

  static VoidCallback? _sendTimeoutCallBack;
  static VoidCallback? _receiveTimeoutCallBack;
  static VoidCallback? _cancelCallBack;
  static VoidCallback? _otherCallBack;
  static VoidCallback? _noneNetWorkCallBack;

  ///
  /// request  response 回调
  static VoidCallback? _responseCallBack;
  static OnRequestCallback? _onRequestCallback;

  ///抓包
  static bool _findProxy = false;

  ///check网络callback
  static VoidCallback? _mobileNetWorkCallBack;
  static VoidCallback? _wifiNetWorkCallBack;
  static OnResponseCallback? _onResponseCallback;
  static Dio? _dio;
  static bool _useDioLogPrint = true;
  static String? _baseUrl;
  static int? _connectTimeout;
  static int? _receiveTimeout;
  static ResponseType? _responseType;
  //baseHeader 列表
  static Map<String, dynamic>? _baseHeader;
  static String? _contentType;
  /*
   * 必须初始化
   * baseUrl:基础网络请求连接。
   * */

  static preInit({
    required String baseUrl,
    Map<String, dynamic>? header,
    int? connectTimeout,
    int? receiveTimeout,
    String? contentType,
    String findProxyUrl = '127.0.0.1:8888',
    bool findProxy = false,
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
    OnResponseCallback? onResponseCallback,
    OnRequestCallback? onRequestCallback,
    bool useDioLogPrint = true,
  }) {
    _baseUrl = baseUrl;
    _baseHeader = header ?? _baseHeader;
    _connectTimeout = connectTimeout;
    _receiveTimeout = receiveTimeout;
    _responseType = responseType;
    _contentType = contentType;

    _findProxy = findProxy;
    _findProxyUrl = findProxyUrl;

    ///errorCallBack
    ///
    ///
    _connectTimeoutCallBack = connectTimeoutCallBack;
    _sendTimeoutCallBack = sendTimeoutCallBack;
    _receiveTimeoutCallBack = receiveTimeoutCallBack;
    _cancelCallBack = cancelCallBack;
    _otherCallBack = otherCallBack;
    _responseCallBack = responseCallBack;

    ///
    _onResponseCallback = onResponseCallback;
    _onRequestCallback = onRequestCallback;

    ///检查无网络操作
    _noneNetWorkCallBack = noneNetWorkCallBack;
    _mobileNetWorkCallBack = mobileNetWorkCallBackl;
    _wifiNetWorkCallBack = wifiNetWorkCallBack;

    ///
    _useDioLogPrint = useDioLogPrint;
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
          contentType: _contentType,
          responseType: _responseType ?? ResponseType.json);

      _dio = new Dio(_options);

      _dio!.interceptors.add(new DioInterceptor(
        _connectTimeoutCallBack,
        _sendTimeoutCallBack,
        _receiveTimeoutCallBack,
        _cancelCallBack,
        _otherCallBack,
        _responseCallBack,
        _wifiNetWorkCallBack,
        _noneNetWorkCallBack,
        _mobileNetWorkCallBack,
        _onResponseCallback,
        _onRequestCallback,
        _useDioLogPrint,
      ));
      _dio!.interceptors.add(
        PostmanDioLogger(
            logPrint: (Object object) => _useDioLogPrint
                ? LogUtils.i(
                    object.toString(),
                    tag: 'PostmanDioLoggerSimple',
                  )
                : null),
      );
      _dioCacheManager = DioCacheManager(CacheConfig(
        baseUrl: _baseUrl,
        databaseName: "zdsl",
      ));
      ;

      ///缓存库
      _dio!.interceptors.add(_dioCacheManager!.interceptor);

      ///
      if (_findProxy) {
        (_dio!.httpClientAdapter as DefaultHttpClientAdapter)
            .onHttpClientCreate = (client) {
          /// 过https 证书
          client.badCertificateCallback = (cert, host, port) {
            return true;
          };

          ///代理

          client.findProxy = (url) {
            return "PROXY ${_findProxyUrl}";
          };
        };
      }
//      _dio.interceptors.add(new PrettyDioLogger());
      //_dio!.interceptors.add(new ResponseInterceptors(0));
      _dio!.addSentry();
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

  /**
   * 无论子密钥是什么，如果主密钥匹配，请删除本地缓存
   * path 默认情况下，host + path用作主键
   * 一般此处path可以忽略host 直接填写path  但是如果使用的方式不是dio配置的baseurl的host   此处也需要加上host
   * requestMethod 请求类型 POST GET PUT DELETE
   *
   *
   */
  Future<bool> deleteCacheByPrimaryKey(
          {required String path, String? requestMethod}) =>
      _dioCacheManager!.deleteByPrimaryKey(path, requestMethod: requestMethod);

  /**
   *
   * path 默认情况下，host + path用作主键
   * 一般此处path可以忽略host 直接填写path  但是如果使用的方式不是dio配置的baseurl的host   此处也需要加上host
   * requestMethod 请求类型 POST GET PUT DELETE
   * 如果有queryParameters 需要填上
   */
  Future<bool> deleteCacheByPrimaryKeyAndSubKey(
          {required String path,
          String? requestMethod,
          Map<String, dynamic>? queryParameters}) =>
      _dioCacheManager!.deleteByPrimaryKeyAndSubKey(path,
          requestMethod: requestMethod, queryParameters: queryParameters);

  /**
   *
   *  会清除所有指定primaryKey 的缓存  或者指定所有 primaryKey+ subkey 的缓存
   *
   */
  Future<bool> deleteCache(
          {required String primaryKey,
          String? subKey,
          String? requestMethod}) =>
      _dioCacheManager!
          .delete(primaryKey, subKey: subKey, requestMethod: requestMethod);

  ///清除所有本地缓存  不管有没有过期
  Future<bool> clearAllCache() => _dioCacheManager!.clearAll();

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
   *  get请求
   *    url           path路径
   *    data          请求参数
   *    headers       设置请求handers 有一点需要注意 如果使用自定义options则这个属性失效
   *    options       自定义 options
   *    cancelToken   取消请求
   *    requiredResponse  是否需要返回Response对象返回 可以做更多操作 默认false  直接返回服务器的data数据
   *    title         主要用于log时  格式化输出response json输出时的标题  调试使用  使用输出格式为 ----title:login/login------
   *    startRequest  请求开始前 自定义方法  可以实现loading或者等其他功能
   *    endRequest    请求结束时 自定义方法
   *    cacheMaxAge   缓存过期时间    会尝试在服务区返回hander获取
   *    cacheMaxStale 缓存销毁时间    会尝试在服务区返回hander获取
   *    cacheForceRefresh
   *    首先从网络获取数据。
   *    如果从网络获取数据成功，存储或刷新缓存。
   *    如果从网络获取数据失败或网络无法使用，请尝试从缓存获取数据，而不是出错。
   *
   *    cacheprimaryKey      指定主key 可以自定义  默认情况下，host + path用作主键
   *    cacheSubKey           指定subkey
   *    默认使用 url 作为缓存 key ,但当 url 不够用的时候
   *    比如 post 请求不同参数比如分页的时候，就需要配合subKey使用
   *
   *    requestDioLogPrint 方法级输出
   */
  get({
    required String url,
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
    bool useRequestOption = false,
    Options? options,
    CancelToken? cancelToken,
    bool requiredResponse = false,
    String? title,
    VoidCallback? startRequest,
    VoidCallback? endRequest,
    Duration? cacheMaxAge,
    bool requestDioLogPrint = true,
    Duration? cacheMaxStale,
    String? cacheprimaryKey,
    bool? cacheForceRefresh = true,
    String? cacheSubKey,
  }) async {
    Response? response;

    try {
      startRequest?.call();
      response = await _dio!.get(
        url,
        queryParameters: data ?? {},
        options: buildConfigurableCacheOptions(
          maxAge: cacheMaxAge,
          options: useRequestOption ? options : Options(headers: headers),
          forceRefresh: cacheForceRefresh,
          maxStale: cacheMaxStale,
          primaryKey: cacheprimaryKey,
          subKey: cacheSubKey,
        ),
        cancelToken: cancelToken,
      );

      _useDioLogPrint && requestDioLogPrint
          ? JsonUtils.printRespond(response,
              titile: title == null ? url : '${title}:${url}')
          : null;
    } on Error catch (e) {
      print("Error-------: ${e}");
    }
    endRequest?.call();

    return requiredResponse ? response : response?.data;
  }

  /*
   * post请求
   */
  post({
    required String url,
    dynamic data,
    Map<String, dynamic>? headers,
    bool useRequestOption = false,
    Options? options,
    CancelToken? cancelToken,
    bool requiredResponse = false,
    String? title,
    VoidCallback? startRequest,
    VoidCallback? endRequest,
    bool requestDioLogPrint = true,
    Duration? cacheMaxAge,
    Duration? cacheMaxStale,
    String? cacheprimaryKey,
    bool? cacheForceRefresh = true,
    String? cacheSubKey,
    Map<String, dynamic>? queryParameters,
  }) async {
    Response? response;

    try {
      startRequest?.call();
      response = await _dio!.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: buildConfigurableCacheOptions(
            maxAge: cacheMaxAge,
            options: useRequestOption ? options : Options(headers: headers),
            forceRefresh: cacheForceRefresh,
            maxStale: cacheMaxStale,
            primaryKey: cacheprimaryKey,
            subKey: cacheSubKey),
        cancelToken: cancelToken,
      );
      _useDioLogPrint && requestDioLogPrint
          ? JsonUtils.printRespond(response,
              titile: title == null ? url : '${title}:${url}')
          : null;
    } on Error catch (e) {
      print("Error-------: ${e}");
    }
    endRequest?.call();
    return requiredResponse ? response : response?.data;
  }

  /*
   * put请求
   */
  put({
    required String url,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool useRequestOption = false,
    bool requestDioLogPrint = true,
    Options? options,
    CancelToken? cancelToken,
    bool requiredResponse = false,
    String? title,
    VoidCallback? startRequest,
    VoidCallback? endRequest,
    Duration? cacheMaxAge,
    Duration? cacheMaxStale,
    String? cacheprimaryKey,
    bool? cacheForceRefresh = true,
    String? cacheSubKey,
  }) async {
    Response? response;
    try {
      startRequest?.call();
      response = await _dio!.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: buildConfigurableCacheOptions(
            maxAge: cacheMaxAge,
            options: useRequestOption ? options : Options(headers: headers),
            forceRefresh: cacheForceRefresh,
            maxStale: cacheMaxStale,
            primaryKey: cacheprimaryKey,
            subKey: cacheSubKey),
        cancelToken: cancelToken,
      );
      _useDioLogPrint && requestDioLogPrint
          ? JsonUtils.printRespond(response,
              titile: title == null ? url : '${title}:${url}')
          : null;
      ;
    } on Error catch (e) {
      print("Error-------: ${e}");
    }
    endRequest?.call();
    return requiredResponse ? response : response?.data;
  }

  /*
   * delete请求
   */
  delete({
    required String url,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool requestDioLogPrint = true,
    bool useRequestOption = false,
    Options? options,
    CancelToken? cancelToken,
    bool requiredResponse = false,
    String? title,
    VoidCallback? startRequest,
    VoidCallback? endRequest,
    Duration? cacheMaxAge,
    Duration? cacheMaxStale,
    String? cacheprimaryKey,
    bool? cacheForceRefresh = true,
    String? cacheSubKey,
  }) async {
    Response? response;
    try {
      startRequest?.call();
      response = await _dio!.delete(
        url,
        data: data,
        queryParameters: queryParameters,
        options: buildConfigurableCacheOptions(
            maxAge: cacheMaxAge,
            options: useRequestOption ? options : Options(headers: headers),
            forceRefresh: cacheForceRefresh,
            maxStale: cacheMaxStale,
            primaryKey: cacheprimaryKey,
            subKey: cacheSubKey),
        cancelToken: cancelToken,
      );
      _useDioLogPrint && requestDioLogPrint
          ? JsonUtils.printRespond(response,
              titile: title == null ? url : '${title}:${url}')
          : null;
      ;
    } on Error catch (e) {
      print("Error-------: ${e}");
    }
    endRequest?.call();
    return requiredResponse ? response : response?.data;
  }

/*
   * 上传文件
   */
  upload(
      {required String url,
      required String path,
      required String imageName,
      Map<String, dynamic>? queryParameters,
      Map<String, dynamic>? headers,
      bool useRequestOption = false,
      Options? options,
      CancelToken? cancelToken,
      bool requestDioLogPrint = true,
      bool requiredResponse = false,
      String? title,
      String? imageType,
      ProgressCallback? onReceiveProgress,
      ProgressCallback? onSendProgress}) async {
    Response? response;

    Map<String, dynamic> map = Map();
    if (!ObjectUtils.isEmptyString(imageType)) {
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
        queryParameters: queryParameters,
        options: useRequestOption ? options : Options(headers: headers),
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
      _useDioLogPrint && requestDioLogPrint
          ? JsonUtils.printRespond(response,
              titile: title == null ? "上传:" + url : '${title}:${url}')
          : null;
      ;
    } on Error catch (e) {
      print("Error-------: ${e}");
    }
    return requiredResponse ? response : response?.data;
  }

  /*
   * 下载文件
   */
  downloadFile({
    required String urlPath,
    required String dirName,
    required String fileName,
    Map<String, dynamic>? queryParameters,
    bool requestDioLogPrint = true,
    CancelToken? cancelToken,
    bool requiredResponse = false,
    String? title,
    ProgressCallback? onReceiveProgress,
  }) async {
    Response? response;
    var path = '';
    try {
      path = await StorageUtils.getAppDocPath(
          fileName: fileName, dirName: dirName);
      response = await _dio!.download(urlPath, path,
          cancelToken: cancelToken, queryParameters: queryParameters,
          onReceiveProgress: (int count, int total) {
        //进度
        ;
        _useDioLogPrint && requestDioLogPrint
            ? LogUtils.d("下载进度:$count $total", tag: "DownloadFile")
            : null;
        if (onReceiveProgress != null) {
          onReceiveProgress(count, total);
        }
      });
    } on Error catch (e) {
      print("Error-------: ${e}");
    }
    return requiredResponse ? response : path;
  }
}
