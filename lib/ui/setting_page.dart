


import 'package:nora_chat/event/event_bus.dart';
import 'package:nora_chat/utils/sp_util.dart';
import 'package:nora_chat/utils/constants_util.dart';
import 'package:nora_chat/utils/toast_util.dart';
import 'package:nora_chat/utils/version_util.dart';
import 'package:nora_chat/utils/image_util.dart';
import 'package:nora_chat/utils/http_util.dart';


import 'package:flutter/material.dart';
import 'dart:io';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {


  String themeName = '';
  String appVersion = '1.0.0';

  @override
  void initState() {
    _initInfo();
    super.initState();
  }

  _initInfo() async{
    appVersion = await VersionUtil.getVersion();
    if (SpUtil.getString(ConstantsUtil.SYSTEM_THEME) == null) {
      setState(() {
        themeName = '暗夜黑';
      });

      SpUtil.putString(ConstantsUtil.SYSTEM_THEME, 'dark');
    } else {
      if (SpUtil.getString(ConstantsUtil.SYSTEM_THEME) == 'dark') {
        setState(() {
          themeName = '暗夜黑';
        });
      } else if(SpUtil.getString(ConstantsUtil.SYSTEM_THEME) == ''){
        setState(() {
          themeName = '暗夜黑';
        });
      } else {
        setState(() {
          themeName = '极简白';
        });
      }
    }
  }

  Widget _buildThemePick(BuildContext context) {
    return Card(
      elevation: 5.0,
      child: MaterialButton( 
        padding: EdgeInsets.all(0),
        onPressed: (){
          showThemePick(context);
        },
        child:Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.only(left: 0,right: 0,top: 10,bottom: 10),
                child: Icon(
                  Icons.dashboard,
                  size: 32,
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  '主题',
                  style: TextStyle(fontSize: 18),
                ),
              ),
    
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 20,
                      width: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                    Expanded(
                      child:Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 5),
                        child: Icon(Icons.arrow_forward_ios),
                      )
                      )
                  ],
                ),
              ),
            )
          ],
        ) 
      ),
    );
  }

  Widget _buildBgImageItem({IconData iconData,String name,VoidCallback onPressed}) {
    return Card(

      elevation: 5,
        child:MaterialButton(
          padding: EdgeInsets.all(0), 
          onPressed: onPressed,
          child:Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.only(top: 10,bottom: 10),
                child: Icon(iconData,size: 32,),
              ),
            ),
            Expanded(
              flex: 5,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(name,style: TextStyle(fontSize: 18),),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.only(right: 5),
                alignment: Alignment.centerRight,
                child: Icon(Icons.arrow_forward_ios),
              ),
            )
          ],
        ),
      )
    );
  }

  _buildVersionItme() {
    return Card(
      elevation: 5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.only(top: 10,bottom: 10),
              child: Icon(Icons.restore,size: 32,),
            ),
          ),
          Expanded(
            flex: 5,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('当前版本',style: TextStyle(fontSize: 18),),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.only(right: 10),
              alignment: Alignment.centerRight,
              child: Text('$appVersion',style: TextStyle(fontSize: 15),)
            ),
          )
        ],
      ),
    );
  }

 void showThemePick(BuildContext context) async{
   var result = await showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title:Text("选择主题"),
            children: <Widget>[
             SimpleDialogOption(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 25,
                      width: 25,
                      color: Colors.grey[850],
                    ),
                    Container(width: 10,),
                    Text('暗夜黑',style: TextStyle(fontSize: 15),),
                  ],
                ),
                
                onPressed: () {
                  Navigator.of(context).pop("dark");
                },
              ),
            SimpleDialogOption(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(height: 25,width: 25,color: Colors.grey[200],),
                    Container(width: 10,),
                    Text('极简白',style: TextStyle(fontSize: 15),)
                  ],
                ),
                onPressed: () {
                  Navigator.of(context).pop("white");
                },
              ),
            ],
          );
        });
        if(result == null) {
          return;
        } else {
          if(result == 'dark') {
            eventBus.fire(UpdateTheme(message: 'dark'));
            SpUtil.putString(ConstantsUtil.SYSTEM_THEME, 'dark');
          } else {
            eventBus.fire(UpdateTheme(message: 'white'));
            SpUtil.putString(ConstantsUtil.SYSTEM_THEME, 'white');
          }
        }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '应用设置',
        ),
      ),
      body: ListView(
        children: <Widget>[
          _buildThemePick(context),
          _buildBgImageItem(iconData: Icons.image,name: '设置头图',onPressed: () async{
            try {
              File imageFile = await ImageUtil.getGalleryImage();
              if (imageFile == null) return;
              File cropImageFile = await ImageUtil.cropImage(
                maxHeight: 1080,
                maxWidth: 1920,
                ratioX: 1.92,
                ratioY: 1.08,
                imageFile: imageFile
              );
              if (cropImageFile == null) {
                await imageFile.delete();
                return;
              }

              ToastUtil.showLoadingToastWithText('上传中');
              String fileName = DateTime.now().millisecondsSinceEpoch.toString();
              var result = await HttpUtil.uploadImage('$fileName.png', cropImageFile);
              String serverImageName = ossUrl + '/images/' + fileName + '.png';
              print('serverImageName$result');
              SpUtil.putString(ConstantsUtil.ABLUM_BG_IMAGE, serverImageName);
              eventBus.fire(UpdateUserSetting(message: 'ablum_image'));
              ToastUtil.showTextToast('上传成功');
              

            } catch (error) {
              print(error);
              ToastUtil.showTextToast('上传失败');
            }
          }),
          _buildBgImageItem(iconData: Icons.photo_filter,name: '设置聊天背景',onPressed:() async{
            try {
              File imageFile = await ImageUtil.getGalleryImage();
              if (imageFile == null) return;
              File cropImageFile = await ImageUtil.cropImage(
                maxHeight: 1920,
                maxWidth: 1080,
                ratioX: 1.08,
                ratioY: 1.92,
                imageFile: imageFile
              );
              if (cropImageFile == null) {
                await imageFile.delete();
                return;
              }

              ToastUtil.showLoadingToastWithText('上传中');
              String fileName = DateTime.now().millisecondsSinceEpoch.toString();
              var result = await HttpUtil.uploadImage('$fileName.png', cropImageFile);
              String serverImageName = ossUrl + '/images/' + fileName + '.png';
              print('serverImageName$result');
              SpUtil.putString(ConstantsUtil.CHAT_BG_IMAGE, serverImageName);
              ToastUtil.showTextToast('上传成功');
              

            } catch (error) {
              print(error);
              ToastUtil.showTextToast('上传失败');
            }           

          }),
          _buildBgImageItem(iconData: Icons.delete_forever,name: '清除缓存',onPressed: (){
            ToastUtil.showTextToast('暂未实现');
          }),
          _buildBgImageItem(iconData: Icons.restore_page,name: '恢复默认设置',onPressed: () async{
            try {
              await SpUtil.putString(ConstantsUtil.ABLUM_BG_IMAGE, '');
              await SpUtil.putString(ConstantsUtil.CHAT_BG_IMAGE, '');
              eventBus.fire(UpdateUserSetting(message: 'ablum_image'));
              ToastUtil.showTextToast('设置成功');
            } catch (error) {
              ToastUtil.showTextToast('设置失败');
            }
          }),
          _buildVersionItme(),
        ],
      ),
    );
  }
}