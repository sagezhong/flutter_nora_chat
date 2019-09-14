import 'package:extended_image/extended_image.dart';

import 'package:nora_chat/utils/jmessage_util.dart';
import 'package:nora_chat/utils/http_util.dart';
import 'package:nora_chat/utils/toast_util.dart';
import 'package:nora_chat/utils/sp_util.dart';
import 'package:nora_chat/utils/constants_util.dart';
import 'package:nora_chat/model/friends_history_model.dart';
import 'package:nora_chat/ui/widgets/user_avatar_widget.dart';
import 'package:nora_chat/event/event_bus.dart';

import 'package:flutter/material.dart';


class NewFriendsPage extends StatefulWidget {
  @override
  _NewFriendsPageState createState() => _NewFriendsPageState();
}

class _NewFriendsPageState extends State<NewFriendsPage> {
  
 List<FriendsHistoryModel> modelList = []; 
  String username = '';
  @override 
  void initState() {
    super.initState();
    _initData();
  }


  _initData() async{
    List<Map> mapList;
    mapList = SpUtil.getObjectList(ConstantsUtil.FRIEND_HISTORY);
    if (mapList == null) {
      return;
    } else {
      modelList = mapList?.map((value) {
        return FriendsHistoryModel.fromJson(value);
      })?.toList();
    }
  }

  Widget _buildTop() {
    return Card(
     child: SpUtil.getString(ConstantsUtil.ABLUM_BG_IMAGE) == '' ? Image.asset(
       'assets/images/ablum_bg.png',
       width: MediaQuery.of(context).size.width,
       height: MediaQuery.of(context).size.height / 3.5,
       fit: BoxFit.fill,

     ): ExtendedImage.network(SpUtil.getString(ConstantsUtil.ABLUM_BG_IMAGE),cache: true,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 3.5,
        fit: BoxFit.fill,
        ),
    );

  }

  List<Widget> _buildBody() {
    List<Widget> widgetList= [];
    if (modelList.length == 0) {
      widgetList.add(Container(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Text(
            '暂无好友请求',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ));
      return widgetList;
    } else {

      for ( var itemModel  in modelList) {

          Widget widgetsItem = NewFriendsPageItem(itemModel: itemModel,onPressed: (){

        },acceptOnPressed: () async{
        try {
            await jmessage.acceptInvitation(username: itemModel.username);
            String url = aliUrl + '/updateFriendsHistory';
            var result = await HttpUtil.postRequest(url, {
              'owner': itemModel.owner,
              'id': itemModel.id,
              'isAccepted': 'accept',
            });
            if (result['status'] != 200) {
              ToastUtil.showTextToast('服务器错误');
              return;
            }
            if (result['count'] != null) {
              SpUtil.putString(ConstantsUtil.UNREAD_FRIEND_COUNT, result['count']);
            }
            String url2 = aliUrl + '/getFriendsHistory';
            var result2 = await HttpUtil.getRequest(url2, {
              'username': SpUtil.getString(ConstantsUtil.USERNAME),
            });
            if (result2['status'] != 200) {
              ToastUtil.showTextToast('服务器错误');
              return;
            }
            List mapList = result2['data'];
            setState(() {
              modelList = mapList?.map((value) {

                return FriendsHistoryModel.fromJson(value as Map<String,dynamic>);
              })?.toList();
            });
            SpUtil.putObjectList(ConstantsUtil.FRIEND_HISTORY, mapList);
            eventBus.fire(FriendEvent('accept'));
          } catch (error) {
            print(error);
            ToastUtil.showTextToast('服务器连接失败');
          }

          

        },declineOnPressed: () async{
         
          try {
            await jmessage.declineInvitation(username: itemModel.username,reason: '');
            String url = aliUrl + '/updateFriendsHistory';
            var result = await HttpUtil.postRequest(url, {
              'owner': itemModel.owner,
              'id': itemModel.id,
              'isAccepted': 'decline',
            });
            if (result['status'] != 200) {
              ToastUtil.showTextToast('服务器错误');
              return;
            }
            if (result['count'] != null) {
              SpUtil.putString(ConstantsUtil.UNREAD_FRIEND_COUNT, result['count']);
            }
            String url2 = aliUrl + '/getFriendsHistory';
            var result2 = await HttpUtil.getRequest(url2, {
              'username': SpUtil.getString(ConstantsUtil.USERNAME),
            });
            if (result2['status'] != 200) {
              ToastUtil.showTextToast('服务器错误');
              return;
            }
            List mapList = result2['data'];
            setState(() {
              modelList = mapList?.map((value) {

                return FriendsHistoryModel.fromJson(value as Map<String,dynamic>);
              })?.toList();
            });
            SpUtil.putObjectList(ConstantsUtil.FRIEND_HISTORY, mapList);
            eventBus.fire(FriendEvent('decline'));
          } catch (error) {
            print(error);
            ToastUtil.showTextToast('服务器连接失败');
          }
          
        },
        );
        widgetList.add(widgetsItem);
      }
      return widgetList;
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新的朋友'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/add_friend_page');
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: _buildBody().length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return _buildTop();
          } else {
           return _buildBody()[index-1];
          }
        },
      ),
    );
  }

 
}



class NewFriendsPageItem extends StatelessWidget {
  final FriendsHistoryModel itemModel;
  final VoidCallback onPressed;
  final VoidCallback acceptOnPressed;
  final VoidCallback declineOnPressed;


  const NewFriendsPageItem({Key key, @required this.itemModel,this.onPressed,this.acceptOnPressed,this.declineOnPressed}) : super(key:key);


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      child: MaterialButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        child: Container(
          padding: EdgeInsets.only(top: 10.0,bottom: 10.0,left: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[

              UserAvatarWidget(
                  width: 35,
                  height: 35,
                  username: itemModel.username,
                ),
              Container(width: 10,),
              Expanded(
      
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      itemModel.nickname,
                      style: TextStyle(fontSize: 17),
                    ),
                    Container(height: 4.0,),
                    Text(
                      itemModel.introduce,
                      style: TextStyle(color: Colors.grey[350],fontSize: 17),
                    )
                  ],
                ),
                
              ),
              itemModel.isAccepted == 'untreated'? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    
                    onPressed: acceptOnPressed,
                    child: Text(
                      '接受',
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),
                  FlatButton(
                    onPressed: declineOnPressed,
                    child: Text(
                      '拒绝',
                      style: TextStyle(color: Colors.red[400],fontSize: 15.0),

                    ),
                  )
                ],
              ):Container(
                padding: EdgeInsets.only(right: 27),
                child: Text(
                  itemModel.isAccepted == 'accept'? '已接受' : '已拒绝',
                  style: TextStyle(color: Colors.grey[350],fontSize: 15.0),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


