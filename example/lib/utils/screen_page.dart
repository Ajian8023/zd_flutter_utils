import 'dart:io';

import 'package:flutter/material.dart';
import 'package:zd_flutter_utils/dio/zd_dio_utils.dart';
import 'package:zd_flutter_utils/flutter_utils.dart';
import 'package:zd_flutter_utils/screen/flutter_screenutil.dart';
import 'package:dio/dio.dart';

class ScreenPage extends StatefulWidget {
  const ScreenPage({Key? key}) : super(key: key);

  @override
  _ScreenPageState createState() => _ScreenPageState();
}

class _ScreenPageState extends State<ScreenPage> {
  CancelToken cancelToken = new CancelToken();
  var path = "";
  File? paths;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  init() async {
    path = await StorageUtils.getAppDocPath(
        dirName: "/images/", fileName: "image.png");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("屏幕适配工具类"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          InkWell(
            onTap: () async {
              // ZdNetUtil.getInstance(baseUrl: "http://www.zdsenlin.com:8085/")
              //     .get("recharge/getRecharge",
              //         title: "查询",
              //         data: {"name": "123"},
              //         cancelToken: cancelToken);

              // ZdNetUtil.getInstance().cancelRequests(cancelToken);

              print("path:" + path);

              await ZdNetUtil.getInstance(
                      baseUrl: "http://www.zdsenlin.com:8085/")
                  .upload("file/upLoad", path, "hhh",);
              setState(() {});
            },
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                  color: Colors.amber, borderRadius: BorderRadius.circular(12)),
              child: Text(
                "适配前",
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
          Container(
            height: 200.w,
            width: 200.h,
            decoration: BoxDecoration(
                color: Colors.green, borderRadius: BorderRadius.circular(12.r)),
            child: Text(
              "适配后",
              style: TextStyle(fontSize: 12.sp),
            ),
          ),
          Image.asset(path)
        ],
      ),
    );
  }
}
