import 'package:extended_image/extended_image.dart';

import 'package:nora_chat/utils/jmessage_util.dart';
import 'package:nora_chat/utils/constants_util.dart';
import 'package:nora_chat/utils/image_util.dart';
import 'package:nora_chat/utils/toast_util.dart';
import 'package:nora_chat/event/event_bus.dart';
import 'package:nora_chat/ui/user_setting_page.dart';

import 'package:flutter/material.dart';
import 'dart:io';

import 'package:nora_chat/utils/sp_util.dart';

class LeftDrawerPage extends StatefulWidget {
  @override
  _LeftDrawerPageState createState() => _LeftDrawerPageState();
}

class _LeftDrawerPageState extends State<LeftDrawerPage> {

  JMUserInfo userInfo;
  String ablumBgPath = SpUtil.getString(ConstantsUtil.ABLUM_BG_IMAGE);

  final List<Icon> _iconItmes = <Icon>[
    Icon(Icons.person,size: 22,),
    Icon(Icons.settings,size: 22,),
    Icon(Icons.notifications,size: 22,),
    Icon(Icons.refresh,size: 22,)
  ];

  final List<String> _titleItems = <String>[
    '我的','设置','通知','注销',
  ];



  @override
  void initState() {
    super.initState();
    _getUserInfo();
    _addListener();

  }

  _getUserInfo() async {
    var value = await jmessage.getMyInfo();
    setState(() {
      userInfo = value;
    });
  }

  _addListener() {
    eventBus.on<UpdateUserSetting>().listen((event){
      if (mounted) {
      if (event.message == 'info') {
        _getUserInfo();
      } else {
      setState(() {
        ablumBgPath = SpUtil.getString(ConstantsUtil.ABLUM_BG_IMAGE);
      });
      }
      }
    });
    
  }

  void _itemsOnTap(BuildContext context, int index) {
    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context){
        return UserSettingPage(userInfo: userInfo,);
      }));
    }
    if (index == 1) {
      Navigator.pushNamed(context, '/setting_page');
    }

    if( index == 3) {
      jmessage.logout();
      Navigator.pushNamedAndRemoveUntil(context, '/login_page', (Route route) => false);
    }
  }

  void _setUserAvatar() async{
    try {
      File imageFile = await ImageUtil.getGalleryImage();
      if(imageFile == null) return;
      File cropImageFile = await ImageUtil.cropImage(
        imageFile: imageFile,
        maxHeight: 512,
        maxWidth: 512,
        ratioX: 1,
        ratioY: 1,
      );
      if(cropImageFile == null) {
        // 记得删除掉图片
        await imageFile.delete();
        return;
      }
      ToastUtil.showLoadingToastWithText('更新中');
      await jmessage.updateMyAvatar(imgPath: cropImageFile.path);
      JMUserInfo info = await jmessage.getMyInfo();
      setState(() {
        userInfo = info;
      });
      ToastUtil.showTextToast('更新成功');
      await imageFile.delete();
      await cropImageFile.delete();

      UpdateUserInfo event = UpdateUserInfo(message: 'avatar');
      eventBus.fire(event);

    } catch (error) {
      ToastUtil.showTextToast('更新失败');
    }
  }


  Widget _buildListItem(BuildContext context, int index) {
    return ListTile(
      title: Text(
        _titleItems[index],
        textAlign: TextAlign.right,
      ),
      trailing: _iconItmes[index],
      onTap: () {
        _itemsOnTap(context, index);
      },
    );
  }

  Widget _buildHeader() {
    return UserAccountsDrawerHeader(
      accountName: Text(
        userInfo == null ? '' : userInfo.nickname,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      accountEmail: Text(
        userInfo == null ? '' : userInfo.signature,
        softWrap: true,
      ),
      currentAccountPicture: GestureDetector(
        onTap: () {
          _setUserAvatar();
        },
        child:CircleAvatar(
          backgroundImage: userInfo == null ? 
          AssetImage('assets/images/loading.gif'): 
          userInfo.avatarThumbPath == ''? AssetImage('assets/images/default_avatar.png'):
          FileImage(File(userInfo.avatarThumbPath)),
        ),
      ),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: ablumBgPath == '' ? 
            AssetImage('assets/images/ablum_bg.png') :
            ExtendedNetworkImageProvider(ablumBgPath,cache: true),
          fit: BoxFit.fill
        )
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    List<Widget> _list = List();
    _list.add(_buildHeader());

    for (int i = 0; i < _titleItems.length; i++) {
      _list.add(_buildListItem(context, i));
    }
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: _list,
      ),
    );
  }
}