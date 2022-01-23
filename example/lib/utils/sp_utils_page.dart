import 'package:flutter/material.dart';
import 'package:zd_flutter_utils/date/data_formats.dart';
import 'package:zd_flutter_utils/date/date_utils.dart';
import 'package:zd_flutter_utils/log/log_utils.dart';
import 'package:zd_flutter_utils/num/num_utils.dart';
import 'package:zd_flutter_utils/sp/sp_utils.dart';
import 'package:zd_flutter_utils/toast/snack_utils.dart';
import 'package:zd_flutter_utils_example/model/city.dart';
import 'package:zd_flutter_utils/extens/extension_map.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _DatePageState();
  }
}

class _DatePageState extends State<SpPage> {
  String str1 = "124321423";
  String str2 = "1243.21423";
  double d = 12312.3121;
  double d2 = 12312.3121;
  List<String> list = new List.empty(growable: true);
  List<dynamic> list2 = new List.empty(growable: true);
  Map map = new Map();
  bool isWidget = false;
  bool putSuccess = false;

  @override
  void initState() {
    super.initState();
    list.add("yc");
    list.add("doubi");
    list2.add(1);
    list2.add(true);
    list2.add("yc");
    map["1"] = "1";
    map["2"] = "2";
    LogUtils.i("initState 1 ");
    Future(() async {
      LogUtils.i("initState 2 ");
      await ZdCacheUtils.init();
      LogUtils.i("initState 3 ");
    });
    LogUtils.i("initState 4 ");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("sp存储工具类"),
        centerTitle: true,
      ),
      body: new ListView(
        children: <Widget>[
          new Text("先存储sp中存储的值：${putSuccess.toString()}"),
          MaterialButton(
            onPressed: put,
            child: new Text("点击存储"),
            color: Colors.cyan,
          ),
          new Text("后获取sp中存储的值"),
          MaterialButton(
            onPressed: click,
            child: new Text("点击获取"),
            color: Colors.cyan,
          ),
          getWidget(),
        ],
      ),
    );
  }

  Widget getWidget() {
    if (!isWidget) {
      return new Text("haha");
    }
    // return new Column(
    //   children: <Widget>[
    //     new Text("获取sp中key的布尔值：" + sharedPreferences.getBool("100").toString()),
    //     new Text("获取sp中key的double值：" + sharedPreferences.getDouble("101").toString()),
    //     new Text("获取sp中key的int值：" + sharedPreferences.getInt("102").toString()),
    //     new Text("获取sp中key的字符串：" + sharedPreferences.getString("103").toString()),
    //     new Text("获取sp中key的list<String>值：" + sharedPreferences.getStringList("104").toString()),
    //   ],
    // );
    return new Column(
      children: <Widget>[
        new Text("获取sp中key的布尔值：" + ZdCacheUtils.getBool("100").toString()),
        new Text(
            "获取sp中key的double值：" + ZdCacheUtils.getDouble("101").toString()),
        new Text("获取sp中key的int值：" + ZdCacheUtils.getInt("102").toString()),
        new Text("获取sp中key的字符串：" + ZdCacheUtils.getString("103").toString()),
        new Text("获取sp中key的list<String>值：" +
            ZdCacheUtils.getStringList("104").toString()),
        new Text(
            "获取sp中key的dynamic值：" + ZdCacheUtils.getDynamic("102").toString()),
        new Text(
            "获取sp中key的map值：" + ZdCacheUtils.getStringMap("106").toString()),
        new Text(
            "获取sp中key的list：" + ZdCacheUtils.getStringList(str1).toString()),
        new Text(
            "获取sp中key的map数据：" + ZdCacheUtils.getObject("107").toJsonString()),
        new Text(
            "获取sp中key的list集合：" + ZdCacheUtils.getObjectList("108").toString()),
      ],
    );
  }

  void click() {
    setState(() {
      isWidget = true;
    });
  }

  // SharedPreferences sharedPreferences;
  void put() async {
    // sharedPreferences = await SharedPreferences.getInstance();
    // sharedPreferences.setBool("100", true);
    // sharedPreferences.setDouble("101", 101.1);
    // sharedPreferences.setInt("102", 520);
    // sharedPreferences.setString("103", "yangchong");
    // sharedPreferences.setStringList("104", list);

    await ZdCacheUtils.init();
    ZdCacheUtils.putBool("100", true).then((value) {
      if (value) {
        putSuccess = true;
      } else {
        putSuccess = false;
      }
    });
    ZdCacheUtils.putDouble("101", 101.1);
    ZdCacheUtils.putInt("102", 520);
    ZdCacheUtils.putString("103", "yangchong");
    ZdCacheUtils.putStringList("104", list);
    ZdCacheUtils.putStringList2("105", list2);
    ZdCacheUtils.putStringMap("106", map)?.then((value) {
      if (value) {
        putSuccess = true;
      } else {
        putSuccess = false;
      }
    });

    /// 存储实体对象示例。
    City city = new City("湖北黄冈");
    ZdCacheUtils.putObject("107", city);

    /// 存储实体对象list示例。
    List<City> list5 = new List.empty(growable: true);
    list5.add(new City("黄冈市"));
    list5.add(new City("北京市"));
    ZdCacheUtils.putObjectList("108", list5);
    setState(() {});
  }
}
