
import 'package:nora_chat/event/event_bus.dart';
import 'package:nora_chat/utils/http_util.dart';
import 'package:nora_chat/utils/sp_util.dart';
import 'package:nora_chat/utils/toast_util.dart';
import 'package:vibration/vibration.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

import 'package:nora_chat/utils/jmessage_util.dart';
import 'package:nora_chat/utils/constants_util.dart';
import 'package:nora_chat/ui/left_drawer_page.dart';
import 'package:nora_chat/ui/conversation_page.dart';
import 'package:nora_chat/ui/address_book_page.dart';
import 'package:nora_chat/ui/ablum_page.dart';

import 'package:flutter/material.dart';



class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> 
    with SingleTickerProviderStateMixin {
    
  PageController _pageController = PageController(initialPage: 0);
  int _navIndex = 0;
  List<String> title = ['Nora','通讯录','心情'];
  final JPush jpush = JPush();

  String username = SpUtil.getString(ConstantsUtil.USERNAME);



  @override
  void initState() {
    super.initState();
    jpush.applyPushAuthority(new NotificationSettingsIOS(
      sound: true,
      alert: false,
      badge: false,
    ));
    _addListener();
  }

  void _addListener() {
    
    jmessage.addContactNotifyListener((event) async{
      try {
        await Vibration.vibrate();
        JMUserInfo userInfo = await jmessage.getUserInfo(username: event.fromUserName);

        if (event.type == JMContactNotifyType.invite_received) {
          String url = aliUrl + '/addFriendsHistory';
          var result = await HttpUtil.postRequest(url, {
            'nickname': userInfo.nickname,
            'avatarPath': '',
            'introduce': event.reason,
            'username': event.fromUserName,
            'owner': username
          });
          if (result['status'] != 200) {ToastUtil.showTextToast('有消息处理失败'); return;}
          String count = (int.parse(SpUtil.getString(ConstantsUtil.UNREAD_FRIEND_COUNT)) + 1).toString();
          String url2 = aliUrl + '/updateUserUnreadCount';
          var result2 = await HttpUtil.postRequest(url2, {
            'username': username,
            'count': count
          });
          if (result2['status'] != 200) {ToastUtil.showTextToast('有消息处理失败'); return;}
          await SpUtil.putString(ConstantsUtil.UNREAD_FRIEND_COUNT, count);
          await _fireMessgaeEvent();
          String url3 = aliUrl + '/getFriendsHistory';
          var result3 = await HttpUtil.getRequest(url3, {
            'username': username
          });
          if (result3['status'] == 200) {
            List friendsHistory = result3['data'];

            await SpUtil.putObjectList(ConstantsUtil.FRIEND_HISTORY, friendsHistory);
          }
          ToastUtil.showTextToast('有新的好友请求');
        } else if (event.type == JMContactNotifyType.invite_accepted) {
          //这是是接受了邀请的逻辑
          _fireMessgaeEvent();

          JMSingle targetUser = JMSingle.fromJson({
            'username': event.fromUserName
          });
          JMConversationInfo conversationInfo = await jmessage.createConversation(target: targetUser);
          JMTextMessage textMessage = await conversationInfo.sendTextMessage(text: '我们已经成为好友');
          conversationInfo = null;
          print(textMessage);
        } else if (event.type == JMContactNotifyType.invite_declined) {
          String url = aliUrl + '/addMessageHistory';
          var result = await HttpUtil.postRequest(url, {
            'username': username,
            'title': '好友申请被拒绝',
            'content': '${userInfo.nickname}拒绝了你的好友申请',
            'date': DateTime.now().millisecondsSinceEpoch.toString(),
          });
          print('看一下消息$result');
          if (result['status'] != 200) {ToastUtil.showTextToast('消息处理失败'); return;}

          List messageList = result['data'];
          await SpUtil.putObjectList(ConstantsUtil.MESSAGE_HISTORY, messageList);
          ToastUtil.showTextToast('${event.fromUserName}拒绝了你的好友申请');
        }

     } catch (error) {
      ToastUtil.showTextToast('服务器连接失败,有消息处理失败');
      print(error);
     }
    });

    //接收到新消息
    jmessage.addReceiveMessageListener((message) {
      eventBus.fire(ReceiveMessage(message: 'new'));
    });
  }

  _fireMessgaeEvent() async{
    FriendEvent event = FriendEvent('');
    eventBus.fire(event);
  }



  //pop菜单点击方法
  _itemBeclicked(String value) {
    if (value == 'first') {
       Navigator.pushNamed(context, '/add_friend_page');
    }
  }



  Widget _buildAppBar(int index) {
    return AppBar(
      centerTitle: true,
      title: Text(title[index]),
      elevation: 5.0,  
      actions: <Widget>[
        PopupMenuButton(
          icon: Icon(Icons.add),
          padding: EdgeInsets.zero,
          onSelected: _itemBeclicked,
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'first',
                  child: ListTile(
                    leading: Icon(
                      Icons.person_add,
                    ),
                    title: Text(
                      '添加好友',
                    ),
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'second',
                  child: ListTile(
                    leading: Icon(
                      Icons.chat,
                    ),
                    title: Text(
                      '新增会话',
                    ),
                  ),
                )
              ],
        ),
      ],
    );
  }

  Widget _buildBody() {
    return PageView(
      controller: _pageController,
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        ConversationPage(),
        AddressBookPage(),
        AblumPage(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(_navIndex),
      body: _buildBody(),
      drawer: LeftDrawerPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (index) {
          setState(() {
            _navIndex = index;
          });
          _pageController.jumpToPage(index);
        },
        unselectedItemColor: Theme.of(context).accentColor,
        fixedColor: Theme.of(context).accentColor,
        // fixedColor: Theme.of(context).accentColor,
        // selectedItemColor: Theme.of(context).accentColor,
        type: BottomNavigationBarType.shifting,
        items: [
          BottomNavigationBarItem(
            icon: Icon( Icons.chat,), title: Text('会话')
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervisor_account),title: Text('联系人'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.share),title: Text('心情'),
          )
        ],
      ),
    );
  }
}