import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:zd_flutter_utils/dio/zd_dio_utils.dart';
import 'package:zd_flutter_utils/screen/flutter_screenutil.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        designSize: Size(375, 812),
        orientation: Orientation.portrait);
    return Scaffold(
      appBar: new AppBar(
        title: new Text("屏幕适配工具类"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          InkWell(
            onTap: () async {
              await ZdNetUtil.getInstance(
                      baseUrl: 'http://www.zdsenlin.com:8085/')
                  .post(
                      url: "recharge/getRecharge",
                      title: "查询",
                      data: {"name": "123"},
                      cancelToken: cancelToken,
                      cacheMaxAge: Duration(seconds: 100),
                      cacheMaxStale: Duration(seconds: 100),
                      cacheForceRefresh: false);

              // ZdNetUtil.getInstance().cancelRequests(cancelToken);

              // var e = await ZdNetUtil.getInstance(
              //         baseUrl: "https://gimg2.baidu.com/")
              //     .downloadFile(
              //   fileName: "hhh",
              //   dirName: "image",
              //   urlPath:
              //       "image_searcsh/src=http%3A%2F%2Fhbimg.b0.upaiyun.com%2Fb0037e12bb79c4c5a2544b7db3cac4cec747ad5510807-VXMeMd_fw236&refer=http%3A%2F%2Fhbimg.b0.upaiyun.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1645841831&t=e22d29e88faf10a535b422b9d4320479",
              // );
              // LogUtils.d("path:" + e);
              setState(() {});
            },
            child: Container(
              alignment: Alignment.centerLeft,
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
          Row(
            children: [
              Container(
                height: 200.w,
                width: 200.w,
                decoration: BoxDecoration(
                  color: Colors.green,
                ),
                child: Text(
                  "适配后",
                  style: TextStyle(fontSize: 15.sp),
                ),
              ),
              Container(
                height: 200.w,
                width: 175.w,
                decoration: BoxDecoration(
                  color: Colors.amber,
                ),
                child: Text(
                  "适配后",
                  style: TextStyle(fontSize: 12.sp),
                ),
              ),
            ],
          ),
          Image.asset(path)
        ],
      ),
    );
  }
}
