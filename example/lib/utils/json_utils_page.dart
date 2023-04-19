import 'package:flutter/material.dart';
import 'package:zd_flutter_utils/json/json_utils.dart';
import 'package:zd_flutter_utils_example/model/city.dart';

class JsonUtilsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new JsonUtilsState();
  }
}

class JsonUtilsState extends State<JsonUtilsPage> {
  String title1 = "初始化值";
  String title2 = "初始化值";
  String title3 = "初始化值";
  String title4 = "初始化值";
  City city = new City("北京");

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String listStr = "[{\"name\":\"成都市\"}, {\"name\":\"北京市\"}]";
    List<City> cityList = JsonUtils.getObjList(listStr, (v) => City.fromJson(v));

    return Scaffold(
        //https://www.jianshu.com/p/82842d07e8fe
        appBar: new AppBar(title: new Text("测试JsonUtils的功能")),
        body: ListView(
          children: <Widget>[
            new Text("测试GetItHelper的功能"),
            new Text(title1),
            new Text("将对象[值]转换为JSON字符串：" + JsonUtils.encodeObj(city)),
            TextButton(
              onPressed: () {
                String objStr = "{\"name\":\"成都市\"}";
                City hisCity = JsonUtils.getObject(objStr, (v) => City.fromJson(v));
                setState(() {
                  title1 = "City对象：" + hisCity.name;
                });
              },
              child: new Text('转换JSON字符串[源]到对象'),
            ),
            new Divider(),
            new Text(title2),
            TextButton(
              onPressed: () {
                setState(() {
                  setState(() {
                    title1 = "City对象列表：" + cityList.length.toString();
                  });
                });
              },
              child: new Text('转换JSON字符串列表[源]到对象列表'),
            ),
            new Text("将对象[值]转换为JSON字符串：" + cityList.length.toString()),
            TextButton(
              onPressed: () {
                String objStr = "{\"name\":\"成都市\"}";
                JsonUtils.printJson(objStr);
              },
              child: new Text('单纯的Json格式输出打印'),
            ),
            TextButton(
              onPressed: () {
                String objStr = "{\"name\":\"成都市\"}";
                JsonUtils.printJsonEncode(objStr);
              },
              child: new Text('单纯的Json格式输出打印'),
            ),
          ],
        ));
  }
}
