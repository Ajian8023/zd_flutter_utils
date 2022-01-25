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
  var path =
      "/var/mobile/Containers/Data/Application/0F83DBA0-21DE-4B0C-839E-DF05E1044D45/Documents/images//image";
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
              ZdNetUtil.getInstance(baseUrl: "http://www.zdsenlin.com:8085/")
                  .get("recharge/getRecharge",
                      title: "查询",
                      data: {"name": "123"},
                      cancelToken: cancelToken);

              ZdNetUtil.getInstance().cancelRequests(cancelToken);
              path = await StorageUtils.getAppDocPath(
                  dirName: "images/", fileName: "image");
              print("path:" + path);

              await StorageUtils.getAppDocPath(
                  dirName: "images/", fileName: "aaa");

              paths = await FileUtils.getAppFile("333");
              var appDocPath = await StorageUtils.getAppDocPath();
              print("pathfile:${paths!.path}");
              print("paths:" + appDocPath);
              await ZdNetUtil.getInstance(baseUrl: "https://gimg2.baidu.com/")
                  .downloadFile(
                      "image_search/src=http%3A%2F%2Fbj-yuantu.fotomore.com%2Fcreative%2Fvcg%2Fnew%2FVCG211363439424.jpg%3FExpires%3D1643621485%26OSSAccessKeyId%3DLTAI2pb9T0vkLPEC%26Signature%3DV7ZL3VtfrWsfGDmJDiahAW3pOgo%253D%26x-oss-process%3Dimage%252Fauto-orient%252C0%252Fsaveexif%252C1%252Fresize%252Cm_lfit%252Ch_1200%252Cw_1200%252Climit_1%252Fsharpen%252C100%252Fquality%252CQ_80%252Fwatermark%252Cg_se%252Cx_0%252Cy_0%252Cimage_d2F0ZXIvdmNnLXdhdGVyLTIwMDAucG5nP3gtb3NzLXByb2Nlc3M9aW1hZ2UvcmVzaXplLG1fbGZpdCxoXzE3MSx3XzE3MSxsaW1pdF8x%252F&refer=http%3A%2F%2Fbj-yuantu.fotomore.com&app=2002&size=f10000,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1645691655&t=5c25c17984d8e6ee19b4445862fabce7",
                      paths!.path);
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
          Image.asset(paths?.path ??
              "/var/mobile/Containers/Data/Application/0F83DBA0-21DE-4B0C-839E-DF05E1044D45/Documents/333")
        ],
      ),
    );
  }
}
