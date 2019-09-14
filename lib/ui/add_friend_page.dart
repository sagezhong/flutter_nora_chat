
import 'package:nora_chat/utils/http_util.dart';
import 'package:nora_chat/utils/toast_util.dart';
import 'package:nora_chat/utils/jmessage_util.dart';

import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';

class AddFriendPage extends StatefulWidget {
  @override
  _AddFriendPageState createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {

  TextEditingController searchController = TextEditingController();
  TextEditingController confimController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  FocusNode confimFocusNode = FocusNode();


  bool isSearch = false; //是否搜索
  JMUserInfo userInfo; // 用户模型
  String avatarPath = '';
  Widget _buildSearchWidget() {
    return Container(
      decoration: BoxDecoration(
        // color: Colors.black12
      ),
      padding: EdgeInsets.only(top: 10,bottom: 10,left: 15,right: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
           child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: 1.5,
                color: Theme.of(context).accentColor
              ),
              borderRadius: BorderRadius.circular(8.0)

            ),
            margin: EdgeInsets.only(top: 10.0,bottom:10.0),
            padding: EdgeInsets.only(left: 15.0),
            child: TextField(
              controller: searchController,
              focusNode: searchFocusNode, 
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 16,),
              decoration: InputDecoration(

                border: InputBorder.none,
                hintText: '输入手机号',
                icon: Icon(
                  Icons.search,
                  size: 24,

                ),
                suffixIcon:GestureDetector(
                  onTap: () {
                    searchController.text = '';
                  },
                  child: Icon(
                    Icons.delete_forever,
                    size: 20.0,
                  ),
                )
              ),
              keyboardType: TextInputType.emailAddress,
              onSubmitted: (String string) {
                _search();
              },
              textInputAction: TextInputAction.search,
            ),
          ),
          ),
          Container(
              child: FlatButton(
                onPressed: (){
                  _search();
                },
                // padding: EdgeInsets.all(5.0),
                child: Text(
                  '搜索',
                  style: TextStyle(
                    fontSize: 17.0,
                  ),
                ),
              ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          '添加好友',
          style: TextStyle(fontSize: 18,),
        ),
      ),
       body:InkWell(
         onTap: () {
           FocusScope.of(context).requestFocus(FocusNode());
         },
         child: _buildBody(),
       ) 
    );
  }

  Widget _buildBody() {
   return Container(

              padding: EdgeInsets.only(bottom: 10,top: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: _buildSearchWidget(),
                  ),
                  Expanded(
                    flex: 4,
                    child: isSearch ?Card(
                      margin: EdgeInsets.only(left: 15,right: 15),
                      elevation: 10.0,
                      shape:  const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14.0))),
                      child:
                      Container(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.only(left: 10,right: 10, top: 10,bottom: 10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                    child: avatarPath == '' ? Image.asset(
                                      'images/flower.png',
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.fill,
                                    ): Image.file(
                                      File(avatarPath),
                                      height: 50,
                                      width: 50,
                                      fit: BoxFit.fill,
                                    )
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                   padding: EdgeInsets.all(10.0), 
                                   child: Column(
                                     mainAxisAlignment: MainAxisAlignment.center,
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: <Widget>[
                                       Text(
                                         '昵称：${userInfo.nickname}',
                                         style: TextStyle(
                                           fontSize: 18.0,
                                         ),
                                       ),
                                       Container(
                                         height: 4.0,
                                       ),
                                       Text(
                                         '手机号：${userInfo.username}',
                                         style: TextStyle(
                                           fontSize: 18.0,
                                         ),
                                       )
                                     ],
                                   ),
                                  ),
                                )
                              ],
                            ),
                            Divider(height: 16,color: Colors.black54,),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(height: 4.0,),
                                  Text(
                                    '地区：${userInfo.region}',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  Container(height: 4.0,),
                                  Text(
                                    '签名：${userInfo.signature}',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  Container(height: 4.0,)
                                ],
                              ),
                            ),
                            Divider(color: Colors.black54,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1.5,
                                        color: Theme.of(context).accentColor
                                      ),
                                      borderRadius: BorderRadius.circular(8.0)
 
                                    ),
                                    margin: EdgeInsets.only(top: 10.0,left: 10.0,right: 10.0),
                                    child: TextField(
                                      focusNode: confimFocusNode,
                                      controller: confimController,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(10.0),
                                        border: InputBorder.none,
                                        hintText: '请输入验证消息'
                                      ),
                                      textInputAction: TextInputAction.done,
                                      maxLines: 4,
                                      minLines: 4,
                                      onSubmitted: (string) {
                                        
                                        FocusScope.of(context).requestFocus(FocusNode());

                                      },
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Container(height: 20,),
                            Center(
                              child: OutlineButton(
                                borderSide: BorderSide(
                                  color: Theme.of(context).accentColor,
                                  width: 1.5
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                onPressed: (){
                                   _sendMessage();
                                },
                                highlightedBorderColor: Colors.black12,
                                child: Text(
                                  '发送'
                                ),
                                
                              ),
                            )
                            
                          ],
                        ),
                      )
                    ) : Container(),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(),
                  )
                ],
              ),
            );
  }

  _search() async {
    setState(() {
      isSearch = false;
    });


    if (searchController.text.length == 0) {
     await ToastUtil.showTextToast('手机号不能为空');
    } else { 
      try {
        searchFocusNode.unfocus();
        await ToastUtil.showLoadingToastWithText('查询中');
        String requestUrl = aliUrl + '/searchUser';   
        var result = await HttpUtil.getRequest(requestUrl, {'username': searchController.text});
        if (result['status'] == 200) {
          userInfo = await jmessage.getUserInfo(username: searchController.text);
          Map path = await jmessage.downloadThumbUserAvatar(username: searchController.text);

          setState(() {
            isSearch = true;
             avatarPath = path['filePath'];
          });
          await ToastUtil.dismissMyToast();
        } else {
          await ToastUtil.showTextToast('此用户不存在');
        }

      } catch (error) {
        await ToastUtil.showTextToast('此用户不存在或连接服务器失败');
      }    
        // HttpUtil().getRequest(requestUrl, {"username":searchController.text},successCallback: (result) async{
        //   if(result["status"] == 200) {
        //     userInfo = await jmessage.getUserInfo(username: searchController.text);
        //     print(userInfo.toJson());
        //     Map path = await jmessage.downloadThumbUserAvatar(username: searchController.text);
        //     avatarPath = path["filePath"];
        //     print(path);
        //     setState(() {
        //       isSearch = true;
        //     }); 
        //     ToastUtil.dismissMyToast();
        //   } else {
        //     await ToastUtil.showTextToast('此用不不存在');
        //   }
        // },errorCallback: (error) {
        //   ToastUtil.showTextToast('与服务器连接失败');
        // });
        
    }
  }

  _sendMessage () async {
    print('执行了吗');
    if (confimController.text.length == 0) {
      ToastUtil.showTextToast('请输入验证消息');
    } else {

      try {
        await jmessage.sendInvitationRequest(username: searchController.text,
        reason: confimController.text);
        ToastUtil.showTextToast('请求已经发送');
        Navigator.pop(context);
      } catch (error) {
        print(error);
        ToastUtil.showTextToast('请求发送失败');
      }
    }
  }
}