import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
              await ZdNetUtil.getInstance(
                      baseUrl: 'http://www.zdsenlin.com:8085/')
                  .post(
                      url: "recharge/getRecharge",
                      title: "查询",
                      data: {"name": "123"},
                      cancelToken: cancelToken,
                      cacheMaxAge: Duration(seconds: 10),
                      cacheMaxStale: Duration(seconds: 100),
                      useResponsePrint: true,
                      cacheForceRefresh: false);
              bool e = await ZdNetUtil.getInstance().deleteCacheByPrimaryKey(
                path: 'http://www.zdsenlin.com:8085/recharge/getRecharge',
                requestMethod: 'post',
              );
              LogUtils.i(e);
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
