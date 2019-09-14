
import 'package:nora_chat/event/event_bus.dart';
import 'package:nora_chat/utils/jmessage_util.dart';

import 'package:flutter/material.dart';
import 'package:nora_chat/utils/toast_util.dart';


class UserSettingPage extends StatefulWidget {

  final JMUserInfo userInfo;
  const UserSettingPage({Key key,this.userInfo}) : super(key: key);

  @override
  _UserSettingPageState createState() => _UserSettingPageState();
}

class _UserSettingPageState extends State<UserSettingPage> {
  String signature = '';

  @override
  void initState() {
    _initUserInfo();
    super.initState();
  }

  _initUserInfo() {
    setState(() {
      signature = widget.userInfo.signature;
    });
  }


  Widget _buildItem({BuildContext context, String mainName, String subName,IconData iconData,VoidCallback onPressed}) {
    return Card(
      elevation: 5.0,
      child: MaterialButton( 
        padding: EdgeInsets.all(0),
        onPressed: onPressed,
        child:Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 10,bottom: 10),
                    child: Icon(iconData,size: 32,),
                  ),
                  Container(
                    child: Text(
                      mainName,
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                padding: EdgeInsets.only(left: 20,top: 5,bottom: 5),
                alignment: Alignment.centerRight,
                child: Text(
                  subName,
                  softWrap: true,
                  style: TextStyle(fontSize: 16,color: Colors.grey),
                ),
              ),
    
            ),
            Expanded(
              flex: 1,
              child: Container(

                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 5),
                        child: Icon(Icons.arrow_forward_ios),
              
              
            
               ),
             ),
          ],
        ) 
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我的'),
        centerTitle: true,
      ),
      body: ListView(
      children: <Widget>[
        _buildItem(
          context: context,
          mainName: '签名',
          subName: signature == '' ? '未设置' : signature,
          iconData: Icons.book,
          onPressed: (){
            _showSignAlert(context: context,title: '修改签名',hintText: signature);
          }
        ),
      ],
    ),
    );
  }

  _showSignAlert({BuildContext context,Widget contentWidet,String title,String hintText}) async{
    
    TextEditingController textEditingController = TextEditingController();
    try {
      var result = await showDialog(
        context: context,
        builder: (context) {

          return AlertDialog(
            title: Text(title),
            content: TextField(
              minLines: 2,
              maxLines: 2,
              controller: textEditingController,
              maxLength: 30,
              maxLengthEnforced: true,
              decoration: InputDecoration(
                hintText: hintText,
              ),
            ),
            actions: <Widget>[
              MaterialButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text('取消'),
              ),
              MaterialButton(
                onPressed: (){
                  String result = textEditingController.text;
                  Navigator.of(context).pop(result);
                },
                child: Text('确定'),
              )
            ],
          );
        }
      );
      if (result == null) return;
      await jmessage.updateMyInfo(signature: result);
      setState(() {
        signature = result;
      });
      eventBus.fire(UpdateUserSetting(message: 'info'));
      ToastUtil.showTextToast('修改成功');
    } catch (error) {

    }
  }
}