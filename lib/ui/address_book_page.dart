

import 'package:nora_chat/utils/jmessage_util.dart';
import 'package:nora_chat/utils/sp_util.dart';
import 'package:nora_chat/ui/profile_page.dart';
import 'package:nora_chat/ui/widgets/user_avatar_widget.dart';
import 'package:nora_chat/event/event_bus.dart';
import 'package:nora_chat/utils/constants_util.dart';
import 'package:nora_chat/ui/widgets/common_widget.dart';

import 'package:flutter/material.dart';

class AddressBookPage extends StatefulWidget {
  @override
  _AddressBookPageState createState() => _AddressBookPageState();
}

class _AddressBookPageState extends State<AddressBookPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String unReadCount = '0';
  List<JMUserInfo> friendsList = [];
  bool isLoading = true; //是否在加载

  @override
  void initState() {
    super.initState();

    unReadCount = SpUtil.getString(ConstantsUtil.UNREAD_FRIEND_COUNT);
    _addListener();
    _getFriends();
  }

  _addListener() {
    eventBus.on<FriendEvent>().listen((event) {
      if (!mounted) return;
      setState(() {
        unReadCount = SpUtil.getString(ConstantsUtil.UNREAD_FRIEND_COUNT);
      });
      _updateFriends();
    });

  }

  _getFriends() async {

    if (friendsList.length > 0) {
      friendsList.clear();
    }
    JMUserInfo myInfo = await jmessage.getMyInfo();

    friendsList.add(myInfo);
    List<JMUserInfo> userInfoList = await jmessage.getFriends();
    setState(() {
      friendsList.addAll(userInfoList);
       isLoading = false;
    });

 
  }

  _updateFriends() async{
  
    JMUserInfo myInfo = await jmessage.getMyInfo();
    if (friendsList.length > 0) {
      friendsList.clear();
    }

    friendsList.add(myInfo);
    List<JMUserInfo> userInfoList = await jmessage.getFriends();
    if (!mounted) return;
    setState(() {
      friendsList.addAll(userInfoList);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Widget> _buildBody(int index) {
    List<Widget> widgetList = [];
    friendsList.forEach((item) {
      var widget = _buildItem(item);
      widgetList.add(widget);
    });

    return widgetList;
  }

  Widget _buildTop() {
    return Container(
      padding: EdgeInsets.only(
        top: 10,
        bottom: 10,
      ),
      child: Card(
          elevation: 5,
          child: MaterialButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.pushNamed(context, '/new_friend_page');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      color: Colors.orange[400],
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  margin:
                      EdgeInsets.only(top: 10, bottom: 10, right: 10, left: 10),
                  padding: EdgeInsets.all(5.0),
                  child: Icon(
                    Icons.group_add,
                    size: 30.0,
                    color: Colors.black87,
                  ),
                ),
                Expanded(
                  child: Text(
                    '新的朋友',
                    style: TextStyle( fontSize: 18.0),
                  ),
                ),
                unReadCount != '0'
                    ? Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(right: 15),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.red[500],
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Text(
                          unReadCount,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      )
                    : Container()
              ],
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return isLoading ? CommonWidget.getLoadingWidget(Theme.of(context).accentColor) : ListView.builder(
      itemCount: _buildBody(0).length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return _buildTop();
        } else {
          return _buildBody(index)[index - 1];
        }
      },
    );
  }

  Widget _buildItem(JMUserInfo userInfo) {
     return Card(
        elevation: 5.0,
        child: MaterialButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return ProfilePage(userInfo: userInfo,);
            }));
          },
          padding: EdgeInsets.zero,
          child: Container(
            padding: EdgeInsets.only(top: 10, bottom: 10,left: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                UserAvatarWidget(username: userInfo.username,height: 35,width: 35,),
                Container(
                  padding: EdgeInsets.only(left: 15),
                  child: Text(
                    userInfo.noteName == ''
                        ? userInfo.nickname
                        : userInfo.noteName,
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.normal),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}

