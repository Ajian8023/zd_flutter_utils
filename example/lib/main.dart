import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:zd_flutter_utils/dio/zd_dio_utils.dart';
import 'package:zd_flutter_utils/except/handle_exception.dart';
import 'package:zd_flutter_utils/log/log_utils.dart';
import 'package:zd_flutter_utils/screen/flutter_screenutil.dart';
import 'package:zd_flutter_utils/sp/sp_utils.dart';
import 'package:zd_flutter_utils/toast/snack_utils.dart';
import 'package:zd_flutter_utils/utils/flutter_init_utils.dart';
import 'package:zd_flutter_utils_example/utils/bus_utils_page.dart';
import 'package:zd_flutter_utils_example/utils/color_utils_page.dart';
import 'package:zd_flutter_utils_example/utils/data_utils_page.dart';
import 'package:zd_flutter_utils_example/utils/encrypt_utils_page.dart';
import 'package:zd_flutter_utils_example/utils/extension_utils_page.dart';
import 'package:zd_flutter_utils_example/utils/file_utils_page.dart';
import 'package:zd_flutter_utils_example/utils/image_utils_page.dart';
import 'package:zd_flutter_utils_example/utils/json_utils_page.dart';
import 'package:zd_flutter_utils_example/utils/log_utils_page.dart';
import 'package:zd_flutter_utils_example/utils/num_utils_page.dart';
import 'package:zd_flutter_utils_example/utils/object_utils_page.dart';
import 'package:zd_flutter_utils_example/utils/regex_utils_page.dart';
import 'package:zd_flutter_utils_example/utils/screen_page.dart';
import 'package:zd_flutter_utils_example/utils/sp_utils_page.dart';
import 'package:zd_flutter_utils_example/utils/storage_utils_page.dart';
import 'package:zd_flutter_utils_example/utils/text_utils_page.dart';
import 'package:zd_flutter_utils_example/utils/timer_utils_page.dart';
import 'package:zd_flutter_utils_example/widget/custom_raised_button.dart';

void main() {
  //初始化工具类操作
  Future(() async {
    await FlutterInitUtils.fetchInitUtils();
  });

  Future(() async {
    await ZdCacheUtils.init();
  });

  //await FlutterInitUtils.fetchInitUtils();
  //FlutterInitUtils.fetchInitUtils();
  //runApp(MainApp());
  hookCrash(() {
    runApp(MainApp());
  });
}

class MainApp extends StatelessWidget {
  //在构建页面时，会调用组件的build方法
  //widget的主要工作是提供一个build()方法来描述如何构建UI界面
  //通常是通过组合、拼装其它基础widget
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: Size(375, 737),
        builder: () => MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              home: HomePage(title: 'Flutter常用工具类'),
            ));
  }
}

//StatelessWidget表示组件，一切都是widget，可以理解为组件
//有状态的组件（Stateful widget）
//无状态的组件（Stateless widget）
//Stateful widget可以拥有状态，这些状态在widget生命周期中是可以变的，而Stateless widget是不可变的
class HomePage extends StatefulWidget {
  HomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  //createState()来创建状态(State)对象
  @override
  State<StatefulWidget> createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    LogUtils.init(tag: "yc", isDebug: true, maxLen: 128);

    ZdNetUtil.preInit(
      baseUrl: "http://www.zdsen2in.com:8085/",
      connectTimeout: 100 * 1000,
      connectTimeoutCallBack: () {
        print("object-ec");

        EasyLoading.showToast("status");
      },
      cancelCallBack: () => EasyLoading.showToast("eee"),
      noneNetWorkCallBack: ()=>EasyLoading.showToast("noneNetWork"),
      wifiNetWorkCallBack: () => EasyLoading.showToast("wifiNetWorkCallBack"),
    );
    ZdNetUtil.getInstance;
  }

  void inits() {
    print("33333");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //在构建页面时，会调用组件的build方法
  //widget的主要工作是提供一个build()方法来描述如何构建UI界面
  //通常是通过组合、拼装其它基础widget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 本地化的代理类
      builder: EasyLoading.init(),
      //支持的语言

      home: Scaffold(
        appBar: new AppBar(
          title: Text(this.widget.title ?? "Title"),
        ),
        body: Center(
          child: ListView(
            children: <Widget>[
              CustomRaisedButton(BusPage(), "EventBus 事件通知工具类"),
              CustomRaisedButton(LogUtilsPage(), "LogUtils 日志工具类"),
              CustomRaisedButton(DatePage(), "DateUtils 日期工具类"),
              CustomRaisedButton(JsonUtilsPage(), "JsonUtils Json工具类"),
              CustomRaisedButton(FileStoragePage(), "FileUtils 文件工具类"),
              CustomRaisedButton(EncryptPage(), "EncryptUtils 加解密工具类"),
              CustomRaisedButton(ObjectPage(), "ObjectUtils Object工具类"),
              CustomRaisedButton(TextPage(), "TextUtils 文本工具类"),
              CustomRaisedButton(NumPage(), "NumUtils 格式处理工具类"),
              CustomRaisedButton(ColorPage(), "ColorUtils 颜色工具类"),
              CustomRaisedButton(ImagePage(), "ImageUtils 图片工具类"),
              CustomRaisedButton(TimerPage(), "TimerUtils 计时器工具类"),
              CustomRaisedButton(RegexPage(), "RegexUtils 正则校验工具类"),
              CustomRaisedButton(StoragePage(), "StorageUtils 文件管理工具类"),
              CustomRaisedButton(ExtensionPage(), "extension_xx 拓展工具类"),
              CustomRaisedButton(SpPage(), "SpUtils sp存储工具类"),
              CustomRaisedButton(ScreenPage(), "ScreenUtil 屏幕适配工具"),
            ],
          ),
        ),
      ),
    );
  }
}
