
import 'package:nora_chat/utils/jmessage_util.dart';
import 'package:nora_chat/utils/sp_util.dart';
import 'package:nora_chat/event/event_bus.dart';
import 'package:nora_chat/ui/widgets/user_avatar_widget.dart';
import 'package:nora_chat/ui/remark_page.dart';
import 'package:nora_chat/ui/chat_page.dart';

import 'package:flutter/material.dart';
import 'package:nora_chat/utils/toast_util.dart';


class ProfilePage extends StatefulWidget {
  final JMUserInfo userInfo;

  const ProfilePage(
      {Key key, @required this.userInfo})
      : super(key: key);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {

  JMUserInfo userInfo;
  JMConversationInfo conversationInfo;

  bool isOwner = false;

  @override
  void initState() {
    _initUserinfo();
    super.initState();

    _addListener();
    _determineWhetherUserHimself();
  }

  _initUserinfo() async{
    userInfo = widget.userInfo;
    JMSingle userTagert = JMSingle.fromJson({
      'username': userInfo.username
    });
    conversationInfo = await jmessage.getConversation(target: userTagert);
  }

  _addListener() {
    eventBus.on<UpdateNoteNameAndText>().listen((event){
      if(mounted) {
      setState(() {
        userInfo.noteName = event.noteName;
        userInfo.noteText = event.noteText;
      });
      }
    });
  }

  _determineWhetherUserHimself() {
    if (widget.userInfo.username == SpUtil.getString('username')) {
      if(!mounted) return;
      setState(() {
        isOwner = true;
      });
    } else {
      if(!mounted) return;
      setState(() {
        isOwner = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '简况',
        ),
        actions: <Widget>[
          isOwner ? Container(): IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return RemarkSettingPage(
                  userInfo: userInfo,
                );
              }));
            },
            icon: Icon(
              Icons.more_horiz,
            ),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Container(
            height: 5,
          ),
          _buildTop(),
          Container(
            height: 20,
          ),
          _buildBody(),
          Container(
            height: 25,
          ),
          _buildBottom()
        ],
      ),
    );
  }

  Widget _buildTop() {
    return Card(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      elevation: 5.0,
      child: Container(
        margin: EdgeInsets.only(top: 0),
        padding: EdgeInsets.only(left: 10, top: 20, bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
                flex: 1,
                //为了让头像居中对齐
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: UserAvatarWidget(
                      width: 70,
                      height: 70,
                      username: userInfo.username,
                      radius: 10,
                    )
                  ),
                  ),
                ),
            Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.only(left: 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        userInfo.noteName == ''
                            ? userInfo.nickname
                            : userInfo.noteName,
                        style: TextStyle(fontSize: 18.0),
                      ),
                      Container(
                        height: 4.0,
                      ),
                      Text(
                        '手机号：${userInfo.username}',
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 15.0),
                      ),
                      Container(
                        height: 4.0,
                      ),
                      Text(
                        '昵称：${userInfo.nickname}',
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 15.0),
                      ),
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Card(
      elevation: 5.0,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 0, left: 10,right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          '地区',
                          style:
                              TextStyle(fontSize: 18.0, ),
                        ),
                      )),
                  Expanded(
                    flex: 3,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(right: 10),
                      child:Text(
                      userInfo.region == '' ? '暂未设置地区' : userInfo.region,
                      style: TextStyle(fontSize: 18.0, ),
                    ),
                    )
                  )
                ],
              ),
            ),
            Divider(
              color: Colors.grey,
              indent: 15,
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.only(top: 40, bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Text(
                        '相册',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Divider(
              color: Colors.grey,
              indent: 15,
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, bottom: 20,right:0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text(
                        '签名',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(right: 10),
                      child:Text(
                      userInfo.signature == '' ? '暂未设置签名': userInfo.signature,
                      style: TextStyle(fontSize: 18.0),
                    ),
                    )
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBottom() {
    return Card(
      margin: EdgeInsets.only(left: 20, right: 20),
      elevation: 5.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0))),
      child: MaterialButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          // Navigator.push(context, MaterialPageRoute(builder: (context) {
          //   return ChatPage(
          //     avatarPath: widget.avatarPath,
          //     receiverAccount: userInfo.username,
          //     title: userInfo.noteName == ''
          //         ? userInfo.nickname
          //         : userInfo.noteName,
          //   );
          // }));
          if (conversationInfo == null) {
            ToastUtil.showTextToast('会话初始化失败');
            return;
          }
          Navigator.push(context, MaterialPageRoute(builder: (context){
            return ChatPage(conversationInfo: conversationInfo,);
          }));
        },
        child: Text(
          '消息',
          style: TextStyle(fontSize: 18.0),
        ),
      ),
    );
  }
}