import 'package:flutter/material.dart';
import 'package:zd_flutter_utils/dio/zd_dio_utils.dart';
import 'package:zd_flutter_utils/screen/flutter_screenutil.dart';

class ScreenPage extends StatelessWidget {
  ScreenPage({Key? key}) : super(key: key);

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
            onTap: () {
              
              ZdNetUtil().get("recharge/getRecharge", title: "查询");
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
        ],
      ),
    );
  }
}
