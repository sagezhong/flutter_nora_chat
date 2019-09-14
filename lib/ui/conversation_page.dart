import 'package:flutter_easyrefresh/easy_refresh.dart';

import 'package:nora_chat/ui/widgets/common_widget.dart';
import 'package:nora_chat/ui/widgets/user_avatar_widget.dart';
import 'package:nora_chat/utils/jmessage_util.dart';
import 'package:nora_chat/event/event_bus.dart';
import 'package:nora_chat/utils/time_util.dart';
import 'package:nora_chat/ui/widgets/space_header.dart';
import 'package:nora_chat/ui/chat_page.dart';


import 'package:flutter/material.dart';
import 'dart:async';

class ConversationPage extends StatefulWidget {
  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage>
     with AutomaticKeepAliveClientMixin,WidgetsBindingObserver {

  GlobalKey<EasyRefreshState> _easyRefreshKey =
      new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey =
      new GlobalKey<RefreshHeaderState>();


  List<JMConversationInfo> modelList = [];

  bool isLoading = true;

  @override
  bool get wantKeepAlive => true;

  Timer _timer;

  @override
  initState() {



    super.initState();
    _getAllConverSation();
    _addListener();
    WidgetsBinding.instance.addObserver(this);

  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    _timer.cancel();

  }
   @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

      switch (state) {
      case AppLifecycleState.inactive:
        print('AppLifecycleState.inactive');
        break;
      case AppLifecycleState.paused:
        print('AppLifecycleState.paused');
        break;
      // 从后台切回来刷新会话
      case AppLifecycleState.resumed:
        print('AppLifecycleState.resumed');
        _updateAllConversation();
        break;
      case AppLifecycleState.suspending:
        print('AppLifecycleState.suspending');
        break;
    }
    super.didChangeAppLifecycleState(state);
  }


  _addListener() {
    eventBus.on<UpdateNoteNameAndText>().listen((event){
      _updateAllConversation();
    });

    eventBus.on<ReceiveMessage>().listen((event) async {
      _updateAllConversation();
    });

    _timer = Timer.periodic(Duration(minutes: 1), (Timer timer) {
        _updateAllConversation();
    });
  }

  _getAllConverSation() async {

    List<JMConversationInfo> conversationList = await jmessage.getConversations();
    setState(() {
      modelList = conversationList;
      isLoading = false;
    });
  }

  _updateAllConversation() async {
    if (modelList.length > 0) {
      modelList.clear();
    }
    print('数组的长度${modelList.length}');
    List<JMConversationInfo> conversationList = await jmessage.getConversations();
    if (!mounted) return;
    setState(() {
      modelList = conversationList;
    });
    await Future.delayed(Duration(milliseconds: 400),(){
      eventBus.fire(UpdateUserInfo(message: 'avatar'));
    });
  }


  List<Widget> _itemList() {
    List<Widget> widgetList = [];
    modelList.forEach((value) {
      Widget itemWidget = _buildConverSationItem(value);
      widgetList.add(itemWidget);
    });
    return widgetList;
  }

  String _getLastMessageStr(JMConversationInfo conversationInfo) {
    var latestMessage = conversationInfo.latestMessage;
    if ( latestMessage != null) {
      if (latestMessage is JMTextMessage) {
        JMTextMessage textMessage = latestMessage;
        if ((textMessage.text.contains('assets/images/face')) || textMessage.text.contains('assets/images/figure')) {
          return '[表情]';
        } else {
          return latestMessage.text;
        }
      } else if (latestMessage is JMVoiceMessage) {
        return '[语音]';
      } else {
        return '[照片]';
      }
    } else {
      return '';
    }
  }

  int _getLatestMessageTime(JMConversationInfo conversationInfo) {
    var latestMessage = conversationInfo.latestMessage;
    if (latestMessage != null) {
      if (latestMessage is JMTextMessage) {
        JMTextMessage textMessage = latestMessage;
        return textMessage.createTime;
      } else if (latestMessage is JMVoiceMessage) {
        JMVoiceMessage voiceMessage = latestMessage;
        return voiceMessage.createTime;
      } else {
        JMImageMessage imageMessage  = latestMessage;
        return imageMessage.createTime;
      }
    } else {
      return 0;
    }
  }

  Widget _buildBody() {
    if(modelList.length != 0) {
      return ListView(
        children: _itemList(),
      );
    } else {
      return Container(
        height: MediaQuery.of(context).size.height-70,
        width: MediaQuery.of(context).size.width,
        child:Center(
          child: Text(
          '暂无会话',
          style: TextStyle(fontSize: 20),
        ),
      )
      );
    }
  }

  Widget _buildConverSationItem(JMConversationInfo conversationInfo) {

    JMUserInfo userInfo = conversationInfo.target;
    int latestime = _getLatestMessageTime(conversationInfo);
    String latestimeStr;
    JMSingle userTaget = JMSingle.fromJson({
      'username': userInfo.username
    });

    if (latestime == 0) {
      latestimeStr = '';
    } else {
      latestimeStr = TimeUtil.getMessageTime(latestime);
    }

    Widget userAvatar = UserAvatarWidget(height: 50,width: 50,username: userInfo.username,);

    Widget unReadMsgCountText;
        if (conversationInfo.unreadCount > 0) {
      unReadMsgCountText = Positioned(
        child: Container(
          width: 18.0,
          height: 18.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20 / 2.0),
            color: Color(0xffff3e3e),
          ),
          child: Text(
            conversationInfo.unreadCount.toString(),
            style: TextStyle(fontSize: 12.0, color: Color(0xffffffff)),
          ),
        ),
        right: 0.0,
        top: -0.5,
      );
    } else {
      unReadMsgCountText = Positioned(
        child: Container(),
        right: 0.0,
        top: -0.5,
      );
    }
    return Card(
      elevation: 5.0,
      child: RawMaterialButton(
        onPressed: () async{
          await jmessage.resetUnreadMessageCount(target: userTaget);
          _updateAllConversation();
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
            return ChatPage(conversationInfo: conversationInfo,);
          }));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 10,right: 10),
                  child: userAvatar,
                ),
                unReadMsgCountText,
              ],
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                ),
                padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      conversationInfo.title,
                      style: TextStyle(fontSize: 17.5),
                    ),
                    Container(height: 5.0,),
                    Text(
                      _getLastMessageStr(conversationInfo),
                      style: TextStyle(color: Colors.grey,fontSize: 13.0),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                height: 40,
                padding: EdgeInsets.only(right: 10),
                child: Text(
                  latestimeStr,
                  style: TextStyle(fontSize: 12,color: Colors.grey),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new EasyRefresh(
      key: _easyRefreshKey,
      refreshHeader: SpaceHeader(
        key: _headerKey,
      ),
      // refreshFooter: SpaceFooter(
      //   key: _footerKey,
      //   loadHeight: 100,
      // ),
       child:isLoading ? Container(
         height: MediaQuery.of(context).size.height-70,
         width: MediaQuery.of(context).size.width,
         child:CommonWidget.getLoadingWidget(Theme.of(context).accentColor)
         ) :
      _buildBody(),
      onRefresh: () {
         _updateAllConversation();
      },
       
    );


  }
}