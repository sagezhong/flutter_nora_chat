import 'package:flutter/material.dart';
import 'dart:io';

import 'package:nora_chat/utils/jmessage_util.dart';


class TestWidget extends StatefulWidget {
  final JMUserInfo userInfo;
  final double width;
  final double height;
  const TestWidget({Key key, this.userInfo,this.height = 35.0, this.width = 35.0}): super(key: key);
  @override
  _TestWidgetState createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  String path = '';


  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async{
    var resutl2 = await jmessage.downloadThumbUserAvatar(username: widget.userInfo.username);
    setState(() {
      path = resutl2['filePath'];
    });

  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        image: DecorationImage(
          image: FileImage(File(path),),
          fit: BoxFit.fill
        )
      ),
    );
  }
}