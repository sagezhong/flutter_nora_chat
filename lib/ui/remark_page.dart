
import 'package:nora_chat/utils/jmessage_util.dart';
import 'package:nora_chat/utils/toast_util.dart';
import 'package:nora_chat/event/event_bus.dart';

import 'package:flutter/material.dart';




class RemarkSettingPage extends StatefulWidget {
  final JMUserInfo userInfo;
  const RemarkSettingPage({Key key, @required this.userInfo}) : super(key: key);
  @override
  _RemarkSettingPageState createState() => _RemarkSettingPageState();
}

class _RemarkSettingPageState extends State<RemarkSettingPage> {
  bool canBeClick = false;
  bool showDeleteIcon = false;
  TextEditingController remarkController = TextEditingController();
  FocusNode remarkFocusNode = FocusNode();
  TextEditingController infomationController = TextEditingController();
  FocusNode infomationFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initInfo();
    _addListener();
  }

  @override
  void dispose() {
    super.dispose();
    remarkController.dispose();
    infomationController.dispose();
    remarkFocusNode.dispose();
    infomationFocusNode.dispose();
  }

  _addListener() {
    remarkController.addListener(() {
      if (remarkController.text != widget.userInfo.noteName) {
        setState(() {
          canBeClick = true;
        });
      } else {
        setState(() {
          canBeClick = false;
        });
      }
    });

    infomationController.addListener(() {
      if (infomationController.text != widget.userInfo.noteText) {
        setState(() {
          canBeClick = true;
        });
      } else {
        setState(() {
          canBeClick = false;
        });
      }
    });
  }

  _initInfo() {
    remarkController.text = widget.userInfo.noteName;
    infomationController.text = widget.userInfo.noteText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
        actions: <Widget>[
          IconButton(
            onPressed: _commitChanges(),
            icon: Icon(
              Icons.check,
              color: canBeClick ? Theme.of(context).accentColor : Colors.grey[600],
            ),
          )
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 15, left: 15, bottom: 10),
              child: Text(
                '备注',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            _buildTop(),
            Padding(
              padding: EdgeInsets.only(top: 15, left: 15, bottom: 10),
              child: Text(
                '信息备注',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            _buildBody(),
            Container(
              height: 20,
            ),
            _buildBottom(),
            Container(
              height: 20,
            ),
            Padding(
              
              padding: EdgeInsets.only(left: 0, right: 0,),
              child: Card(
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
                  },
                  child: Text(
                    '删除好友',
                    style: TextStyle(fontSize: 18.0,color: Colors.red),
                  ),
                ),
              ),
              // child: RaisedButton(
              //   elevation: 5.0,
              //   textColor: Colors.red,
                
              //   shape: const RoundedRectangleBorder(
              //       borderRadius: BorderRadius.all(Radius.circular(10.0))),
              //   onPressed: () {},
              //   child: Padding(
              //     padding: EdgeInsets.only(top: 10,bottom: 10),
              //     child: Text(
              //       '删除好友',
              //       style: TextStyle(fontSize: 18),
              //     ),
              //   ),
                
              // ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTop() {
    return Card(
      elevation: 5.0,
      child: Padding(
        padding: EdgeInsets.only(left: 10),
        child: TextField(
          controller: remarkController,
          focusNode: remarkFocusNode,
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: 18, ),
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '请输入信息',
              suffix: Padding(
                child: GestureDetector(
                  onTap: () {
                    remarkController.text = '';
                  },
                  child: Icon(
                    Icons.delete_forever,
                    size: 18.0,

                  ),
                ),
                padding: EdgeInsets.only(right: 10),
              )),
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Card(
      elevation: 5.0,
      child: Padding(
        padding: EdgeInsets.only(left: 10),
        child: TextField(
          maxLines: 4,
          minLines: 1,
          controller: infomationController,
          focusNode: infomationFocusNode,
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: 18, ),
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '请输入备注',
              suffix: Padding(
                child: GestureDetector(
                  onTap: () {
                    infomationController.text = '';
                  },
                  child: Icon(
                    Icons.delete_forever,
                    size: 18.0,

                  ),
                ),
                padding: EdgeInsets.only(right: 10),
              )),
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
        ),
      ),
    );
  }

  Widget _buildBottom() {
    return Card(
      elevation: 5.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: Padding(
                padding: EdgeInsets.only(left: 10, top: 10),
                child: Text(
                  '消息免打扰',
                  style: TextStyle(fontSize: 18, ),
                ),
              )),
              Container(
                  padding: EdgeInsets.only(right: 10),
                  child: Switch(
                    value: false,
                    onChanged: (value) {},
                  ))
            ],
          ),
          Divider(
            indent: 10,
            color: Colors.grey,
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: Padding(
                padding: EdgeInsets.only(left: 10, top: 0),
                child: Text(
                  '心情屏蔽',
                  style: TextStyle(fontSize: 18, ),
                ),
              )),
              Container(
                  padding: EdgeInsets.only(right: 10),
                  child: Switch(
                    value: false,
                    onChanged: (value) {},
                  ))
            ],
          ),
          Divider(
            indent: 10,
            color: Colors.grey,
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: Padding(
                padding: EdgeInsets.only(left: 10, top: 0, bottom: 10),
                child: Text(
                  '加入黑名单',
                  style: TextStyle(fontSize: 18, ),
                ),
              )),
              Container(
                  padding: EdgeInsets.only(right: 10),
                  child: Switch(
                    value: false,
                    onChanged: (value) {},
                  ))
            ],
          ),
        ],
      ),
    );
  }

  Function _commitChanges() {
    if (canBeClick) {
      return () async{

        if(remarkController.text == '') {
          ToastUtil.showTextToast('设置过备注后备注不能为空');
        } else if (infomationController.text == '') {
          ToastUtil.showTextToast('设置过信息备注后不能为空');
        } else {
        try {
          await jmessage.updateFriendNoteName(username: widget.userInfo.username,
          noteName: remarkController.text);
          await jmessage.updateFriendNoteText(username: widget.userInfo.username,
          noteText: infomationController.text);
           await _notifyEvent();
           await _hideKeyboard();
           await ToastUtil.showTextToast('修改成功');
          
        } catch (error){
          ToastUtil.showTextToast('修改失败,请重试');
        }
      }
      };
    } else {
      return null;
    }
  }

  _hideKeyboard() {
    remarkFocusNode.unfocus();
    infomationFocusNode.unfocus();
  }

  _notifyEvent() {
   UpdateNoteNameAndText event = UpdateNoteNameAndText(noteText: infomationController.text,
    noteName: remarkController.text);
    eventBus.fire(event);
  }
}