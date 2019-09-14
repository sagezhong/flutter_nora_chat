import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:io';

import 'package:nora_chat/utils/jmessage_util.dart';
import 'package:nora_chat/event/event_bus.dart';


class UserAvatarWidget extends StatefulWidget {
  final String username;
  final double width;
  final double height;
  final double radius;
   UserAvatarWidget({Key key, this.username,this.height = 35.0, this.width = 35.0,this.radius = 5.0}): super(key: key);

  @override
  _UserAvatarWidgetState createState() => _UserAvatarWidgetState();
}

class _UserAvatarWidgetState extends State<UserAvatarWidget> {
  String path;


  @override
  void initState() {
    super.initState();
    _init();
    _addListener();

  }
  // @override
  // void deactivate() {
  //   super.deactivate();
  //   print('deactivate');
  // }
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   print('didChange');

  // }



  _addListener() {
    eventBus.on<UpdateUserInfo>().listen((event){
      if(event.message == 'avatar') {
 
         _init();
      }

    });
  }

  _init() async{
    try {
    var resutl2 = await jmessage.downloadThumbUserAvatar(username: widget.username);
    if (!mounted) return;
    setState(() {
      path = resutl2['filePath'];
    });
    } catch (error) {
      print(error);
      if (!mounted) return;
      setState(() {
        path = '';
      });
    }

  }
  @override
  Widget build(BuildContext context) {
    
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius),
        image: DecorationImage(
          image: path == null ? AssetImage('assets/images/loading.gif'): 
            path ==''? AssetImage('assets/images/default_avatar.png') :FileImage(File(path),),
          fit: BoxFit.fill
        )
      ),
    );
  }
}