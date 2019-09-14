


import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flukit/flukit.dart';
import 'package:vibration/vibration.dart';
import 'package:path_provider/path_provider.dart';
import 'package:extended_image/extended_image.dart';

import 'package:nora_chat/event/event_bus.dart';
import 'package:nora_chat/utils/jmessage_util.dart';
import 'package:nora_chat/utils/time_util.dart';
import 'package:nora_chat/utils/file_util.dart';
import 'package:nora_chat/utils/sp_util.dart';
import 'package:nora_chat/utils/constants_util.dart';
import 'package:nora_chat/utils/image_util.dart';
import 'package:nora_chat/utils/toast_util.dart';
import 'package:nora_chat/ui/widgets/common_widget.dart';
import 'package:nora_chat/ui/widgets/view_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async';


class ChatPage extends StatefulWidget {
  final JMConversationInfo conversationInfo;
  const ChatPage(
    {
      Key key,
      @required this.conversationInfo,
    }
  ) : super(key: key);
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> 
          with WidgetsBindingObserver{


  bool isLoading = false; //是否正在加载
  bool _isShowSend = false; //是否显示发送按钮
  bool _isShowFace = false; //是否现实表情栏目
  bool  _isShowVoice = false; //是否显示语音输入栏
  bool _isShowTools = false; //是否显示工具栏
  TextEditingController _textContronller = new TextEditingController();
  FocusNode _textFieldNode = FocusNode();

  List<Widget> _guideFacelist = new List();
  List<Widget> _guideFigureList = new List();
  List<Widget> _guideToolsList = new List();
  bool _isFaceFirstList = true; //是否是表情页在前

  ScrollController _scrollControoler = new ScrollController();

  String _voiceDuration = ''; //录音时长
  String _voiceFilePath = ''; //录音文件路径
  String _androidVoiceFilePath = '';
  String voiceText = '按住 说话';

  FlutterSound _flutterSound;
  File _recordFile; //录音文件
  StreamSubscription<RecordStatus> _recorderSubscription; //录音流监听

  List<dynamic> messageList = []; //获取的消息列表
  
  String  myAvatarPath = '';
  String  targetUserAvatarPath = '';
  String _bgImagePath = SpUtil.getString(ConstantsUtil.CHAT_BG_IMAGE);
  JMSingle userTarget;
  JMUserInfo targetUserInfo;

  int from = 0; // 记录开始位置
  int limit = 20; //限制



  @override
  void initState() {
      _initInfo();

    super.initState();

    _flutterSound = FlutterSound();

    _textFieldNode.addListener(_focusNodeListener);
    _getLocalMessgae();
    _addListener();
    WidgetsBinding.instance.addObserver(this);
    
  }

  @override
  void dispose() {


    super.dispose();
    
    jmessage.exitConversation(target: userTarget).catchError((error){
      ToastUtil.showTextToast('退出会话失败');
    }).whenComplete((){
      print('退出成功了');
    });
    jmessage.removeReceiveMessageListener(_messageListener);
    WidgetsBinding.instance.removeObserver(this);
    if (_flutterSound.isRecording) {
      _flutterSound.stopRecorder();
    }
    if (_flutterSound.isPlaying) {
      _flutterSound.stopPlayer();
    }
    
  }
   @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

      switch (state) {
      case AppLifecycleState.inactive:
        print('AppLifecycleState.inactive');
        break;
      case AppLifecycleState.paused:
        jmessage.exitConversation(target: userTarget);
        print('AppLifecycleState.paused');
        break;
      // 从后台切回来刷新会话
      case AppLifecycleState.resumed:
        jmessage.enterConversation(target: userTarget);
        print('AppLifecycleState.resumed');

        break;
      case AppLifecycleState.suspending:
        print('AppLifecycleState.suspending');
        break;
    }
    super.didChangeAppLifecycleState(state);
  }


  _initInfo() async{

    targetUserInfo = widget.conversationInfo.target;
    userTarget = JMSingle.fromJson({
      'username':targetUserInfo.username
    });
    JMUserInfo myUserInfo = await jmessage.getMyInfo();
    if (myUserInfo.avatarThumbPath !=null) {
      setState(() {
        myAvatarPath = myUserInfo.avatarThumbPath;
      });
    }
    var result = await jmessage.downloadThumbUserAvatar(username:targetUserInfo.username);
    if ( result['filePath'] != null) {
      setState(() {
        targetUserAvatarPath = result['filePath'];
      });
    }
    await jmessage.enterConversation(target: userTarget);
  }

  _getLocalMessgae() async{
    
    List<dynamic> resultList = await jmessage.getHistoryMessages(
      type: userTarget,
      from: from,
      limit: limit,
      isDescend: true,
    );

    setState(() {
      messageList = resultList;
      from = messageList.length;
    });

  }


  
  
  Future<Null> _focusNodeListener() async {
    if (_textFieldNode.hasFocus) {
      setState(() {
        _isShowFace = false;
        _isShowTools = false;
        _isShowVoice = false;
      });
    }
  }

  _addListener() {
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        if(visible) {

          setState(() {
           _isShowFace = false;
          _isShowSend = false;
          _isShowVoice = false;           
          });

          try {
            _scrollControoler.position.jumpTo(0);
          } catch (error) {
            print(error);
          }

        }
      }
    );
  
    _scrollControoler.addListener((){
      if (_scrollControoler.position.pixels == _scrollControoler.position.maxScrollExtent ) {
        _loadMore();
      }
    });

    jmessage.addReceiveMessageListener(_messageListener);
  }

  void _messageListener(dynamic message) {
    //为什做这个判断是因为极光有BUG 会连推送多条相同的消息
    if (isSameMessage(currentMessage: message,previousMessage: messageList[0])) {
      return;
    }
    if (message is JMTextMessage) {
        JMTextMessage textMessage = message;
        if (textMessage.from.username == targetUserInfo.username) {
          jmessage.resetUnreadMessageCount(target: userTarget);
          if (!mounted) return;
          setState(() {
            messageList.insert(0, textMessage);
            from = from + 1;
          });
        } 
      } else if (message is JMImageMessage) {
        jmessage.resetUnreadMessageCount(target: userTarget);
        JMImageMessage imageMessage = message;
        if (imageMessage.from.username == targetUserInfo.username) {
          if(!mounted) return;
          setState(() {
            messageList.insert(0, imageMessage);
            from = from + 1;
          });
        }
      } else {
        jmessage.resetUnreadMessageCount(target: userTarget);
        JMVoiceMessage voiceMessage = message;
        print('接收到录音路径${voiceMessage.path}');
        if (voiceMessage.from.username == targetUserInfo.username) {
          if (!mounted) return;
          setState(() {
            messageList.insert(0, voiceMessage);
            from = from + 1;
          });
        }
      }
      
  }

  bool isSameMessage({dynamic currentMessage, dynamic previousMessage}) {
    if (currentMessage is JMTextMessage && previousMessage is JMTextMessage) {
      JMTextMessage textMessage = currentMessage;
      JMTextMessage preTextMessage = previousMessage;
      if (textMessage.id == preTextMessage.id) {
        return true;
      } else {
        return false;
      }
    } else if (currentMessage is JMImageMessage && previousMessage is JMImageMessage){
      JMImageMessage imageMessage = currentMessage;
      JMImageMessage preImageMessage = previousMessage;
      if (imageMessage.id == preImageMessage.id) {
        return true;
      } else {
        return false;
      }
    } else {
      JMVoiceMessage voiceMessage = currentMessage;
      JMVoiceMessage preVoiceMessage = previousMessage;
      if (voiceMessage.id == preVoiceMessage.id) {
        return true;
      } else {
        return false;
      }
    }
  }
  
  //加载更多消息
  _loadMore() async{
    if(isLoading) {
      ToastUtil.showTextToast('正在获取聊天记录中');
    } else {
      setState(() {
        isLoading = true;
      });
      try {
        List<dynamic> temList = await jmessage.getHistoryMessages(
          type: userTarget,
          from: from,
          limit: limit,
          isDescend: true,
        );

        if (temList.length == 0) {
          ToastUtil.showTextToast('已加载全部消息');
          setState(() {
            isLoading = false;
          });
        } else {
          setState(() {
            messageList.addAll(temList);
            from = from + temList.length;
            isLoading = false;
          });
        }

      } catch (error) {
        ToastUtil.showTextToast('获取失败,请重试');
      }
      
    }

  }

  _initFaceList() {
      if (_guideFacelist.length > 0) {
        _guideFacelist.clear();
      }
      if (_guideFigureList.length > 0) {
        _guideFigureList.clear();
      }

      List<String> _faceList = new List();
      String faceDeletePath = 
        FileUtil.getImagePath('face_delete',dir: 'face', format:'png');
      String facePath;
      for (int i = 0; i < 100; i++) {
        if (i < 90) {
          facePath = FileUtil.getImagePath(i.toString(), dir: 'face', format: 'gif');
        } else {
          facePath = FileUtil.getImagePath(i.toString(), dir: 'face', format: 'png');
        }

        _faceList.add(facePath);
        if (i == 19 || i == 39 || i ==59 || i == 79 || i == 99) {
          _faceList.add(faceDeletePath);
          _guideFacelist.add(_gridView(7, _faceList));
          _faceList.clear();
        }
      }

          //添加表情包
     List<String> _figureList = new List();
     for (int i = 0; i < 96; i ++) {
       if (i ==70 || i == 74) {
         String facePath = FileUtil.getImagePath(i.toString(), dir: 'figure', format:'png');
         _figureList.add(facePath);
       } else {
         String facePath2 = FileUtil.getImagePath(i.toString(), dir: 'figure', format: 'gif');
          _figureList.add(facePath2);
       }

       if (i == 9 ||
           i == 19 || 
           i == 29 ||
           i == 39 ||
           i == 49 ||
           i == 59 ||
           i == 69 ||
           i == 79 ||
           i == 89 ||
           i == 95 
       ) {
         _guideFigureList.add(_gridView(5, _figureList));
         _figureList.clear();
       }
     }
    }

  _gridView(int crossAxisCount, List<String> list) {
      return GridView.count(
        crossAxisCount: crossAxisCount,
        padding: EdgeInsets.all(0.0),
        children: list.map((String name){
          return new IconButton(
            onPressed: (){
              //发送表情
               _sendTextMessage(name);
            },
            icon:  Image.asset(
              name,
              width: crossAxisCount == 5 ? 60 : 32,
              height: crossAxisCount == 5 ? 60 : 32,
            ),
          );
        }).toList(), 

      );
    }

  _faceWidget() {
    _initFaceList();
    return Column(
      children: <Widget>[
        Flexible(
          child: Stack(
            children: <Widget>[
              Offstage(
                offstage: _isFaceFirstList,
                child: Swiper(
                  autoStart: false,
                  circular: false,
                  indicator: CircleSwiperIndicator(
                    radius: 3.0,
                    padding: EdgeInsets.only(top: 20.0),
                    itemColor: Colors.grey,
                    itemActiveColor: Theme.of(context).accentColor,
                  ),
                  children: _guideFigureList
                )
              ),
              Offstage(
                offstage: !_isFaceFirstList,
                child: Swiper(
                  autoStart: false,
                  circular: false,
                  indicator: CircleSwiperIndicator(
                    radius: 3.0,
                    padding: EdgeInsets.only(top: 20.0),
                    itemActiveColor: Theme.of(context).accentColor,
                    itemColor: Colors.grey
                  ),
                  children: _guideFacelist,
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 24,
        ),
        Divider(height: 1.0,),
        Container(
          height: 24,
          child: Row(
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.only(left: 20),
                  child: InkWell(
                    child: Icon(
                      Icons.sentiment_very_satisfied,
                      color: _isFaceFirstList ? Theme.of(context).accentColor : Colors.grey,
                      size: 22,
                    ),
                    onTap: () {
                      setState(() {
                        _isFaceFirstList = true;
                      });
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.only(left: 10),
                  child: InkWell(
                    child: Icon(
                      Icons.favorite_border,
                      color: _isFaceFirstList
                      ? Colors.grey
                      : Theme.of(context).accentColor
                    ),
                    onTap: () {
                      setState(() {
                        _isFaceFirstList = false;
                      });
                    },
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
  
  _toolsWidget() {
   
    if(_guideToolsList.length > 0) {
      _guideToolsList.clear();
    }
    List<Widget> _widgets = new List();
    _widgets.add(CommonWidget.buildIcon(Icons.insert_photo, '相册',o: (res) async {
   
      File image = await ImageUtil.getGalleryImage();
      if (image.path == null) return;
       _sendImageMessage(image.path);
    }));
    _widgets.add(CommonWidget.buildIcon(Icons.camera_alt, '拍摄', o: (res) async{
      File image = await ImageUtil.getCameraImage();
      if (image.path != null) {
       _sendImageMessage(image.path);
      }

    }));
    _widgets.add(CommonWidget.buildIcon(Icons.videocam, '视频通话'));
    _widgets.add(CommonWidget.buildIcon(Icons.location_on, '位置'));
    _widgets.add(CommonWidget.buildIcon(Icons.view_agenda, '红包'));
    _widgets.add(CommonWidget.buildIcon(Icons.swap_horiz, '转账'));
    _widgets.add(CommonWidget.buildIcon(Icons.mic, '语音输入'));
    _widgets.add(CommonWidget.buildIcon(Icons.favorite, '我的收藏'));
    _guideToolsList.add(GridView.count(
      crossAxisCount: 4,
      padding: EdgeInsets.all(0.0),
      children: _widgets,
    ));
       List<Widget> _widgets1 = new List();
    _widgets1.add(CommonWidget.buildIcon(Icons.person, '名片'));
    _widgets1.add(CommonWidget.buildIcon(Icons.folder, '文件'));
    _guideToolsList.add(GridView.count(
        crossAxisCount: 4, padding: EdgeInsets.all(0.0), children: _widgets1));
    
    return Swiper(
        autoStart: false,
        circular: false,
        indicator: CircleSwiperIndicator(
            radius: 3.0,
            padding: EdgeInsets.only(top: 10.0, bottom: 10),
            itemColor: Colors.grey,
            itemActiveColor: Theme.of(context).accentColor),
        children: _guideToolsList);

  }

  _voiceWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Center(
            child: IconButton(
              onPressed: (){
                _playRecord();
              },
              iconSize: 45,
              icon: Icon(
                Icons.headset,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    _voiceDuration,
                    style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  padding: EdgeInsets.zero,
                  child: GestureDetector(
                    onScaleStart: (res) {
                      _startRecord();
                      setState(() {
                        voiceText = '松开 停止';
                      });
                    },
                    onScaleEnd: (res) {
                      _stopRecord();
                      setState(() {
                        voiceText = '按住 说话';
                      });

                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      radius: 60,
                      child: Text(
                        voiceText,
                        style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                )
              )
            ],
          )
        ),
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Center(
                  child: IconButton(
                    onPressed: (){
                      _sendVoiceMessage();
                    },
                    iconSize: 40,
                    icon: Icon(
                      Icons.send,
                    ),
                  ),
                )
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: IconButton(
                    onPressed: (){
                      _deleteRecord();
                    },
                    iconSize: 40,
                    icon: Icon(
                      Icons.delete_forever,

                    ),
                  ),
                )
              )
            ],
          )
        )
      ],
    );
  }

  _bottmoWidget() {


    Widget widget;
    if (_isShowTools) {
      widget = _toolsWidget();
    } else if (_isShowFace) {
      widget = _faceWidget();
    } else if (_isShowVoice) {
      widget = _voiceWidget();
    }
    return widget;
  }

  _enterWidget() {
    return new Material(
      borderRadius: BorderRadius.circular(8.0),
      shadowColor: Colors.grey,
      color: Colors.grey[200],
      elevation: 0,
      
      child: new TextField(
          focusNode: _textFieldNode,
          textInputAction: TextInputAction.send,
          controller: _textContronller,
          maxLines: 5,
          minLines: 1,
          
          inputFormatters: [
           
          ], //只能输入整数
          style: TextStyle(color: Colors.black, fontSize: 18),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(10),
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.transparent,
          ),
          onChanged: (str) {
            setState(() {
              if (str.isNotEmpty) {
                _isShowSend = true;
              } else {
                _isShowSend = false;
              }
            });
          },
          onEditingComplete: () {
            if (_textContronller.text.isEmpty) {
              return;
            }
            _sendTextMessage(_textContronller.text);

            // _buildTextMessage(_textContronller.text);
          }),
    );
  }



  Widget _messageListView() {
    return Container(
      child: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              controller: _scrollControoler,
              reverse: true,
              itemCount: messageList.length,
              shrinkWrap: true,
              itemBuilder: (context, index){
                return _buildMessageList()[index];
              },
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildMessageList() {
    List<Widget> widgetList = [];
    for (int i = 0; i < messageList.length; i ++) {
      if (i == messageList.length - 1) {
        var item = messageList[i];
        if (item is JMTextMessage) {
          JMTextMessage textMessage = item;
          widgetList.add(_buildChatTextItem(
            textMessage: textMessage,
            showTime: true
          ));
        } else if (item is JMImageMessage) {
          JMImageMessage imageMessage = item;
          widgetList.add(_buildChatImageItem(
            imageMessage: imageMessage,
            showTime: true,
          ));
        } else {
          JMVoiceMessage voiceMessage = item;
          widgetList.add(_buildVoiceMessage(voiceMessage, true));
        }
      } else {
        var item = messageList[i];
        if (item is JMTextMessage) {
          JMTextMessage textMessage = item;
          int previousTime = _getPreviousMessageTime(messageList[i+1]);
          widgetList.add(_buildChatTextItem(
            textMessage: textMessage,
            showTime: TimeUtil.forMoreThanFiveMinutes(textMessage.createTime, previousTime),
            ));
        } else if (item is JMImageMessage){
          JMImageMessage imageMessage = item;
          int previousTime = _getPreviousMessageTime(imageMessage);
          widgetList.add(_buildChatImageItem(
            imageMessage: imageMessage,
            showTime: TimeUtil.forMoreThanFiveMinutes(imageMessage.createTime, previousTime)
          ));
        } else {
          JMVoiceMessage voiceMessage = item;
          int previousTime = _getPreviousMessageTime(voiceMessage);
          widgetList.add(_buildVoiceMessage(voiceMessage, TimeUtil.forMoreThanFiveMinutes(voiceMessage.createTime, previousTime)));
        }
      }
      
 
    }
    return widgetList;
  }

  Widget _body() {
    return Container(

      child:Column(
      children: <Widget>[
        Flexible(
          child: InkWell(
            child: _messageListView(),
            onTap: () {
              _hideKeyBoard();
              setState(() {
                _isShowFace = false;
                _isShowVoice = false;
                _isShowTools = false;
              });

            },
          ),
        ),
        Divider(height: 1.0,),
        Container(

          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor
          ),
          child: Container(
            // height: 54,
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: _isShowVoice
                  ? Icon(Icons.keyboard)
                  : Icon(Icons.play_circle_outline),
                  iconSize: 32,
                  onPressed: (){
                    setState(() {
                      _hideKeyBoard();
                      if (_isShowVoice) {
                        _isShowVoice = false;
                      } else {
                        _isShowVoice = true;
                        _isShowFace = false;
                        _isShowTools = false;
                      }
                    });
                  },
                ),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(top: 5,bottom: 5),
                    child:  _enterWidget(),
                  )
                ),
                IconButton(
                  icon: _isShowFace
                  ? Icon(Icons.keyboard)
                  : Icon(Icons.sentiment_very_satisfied),
                  iconSize: 32,
                  onPressed: (){
                    _hideKeyBoard();
                    setState(() {
                      if(_isShowFace) {
                        _isShowFace = false;
                        FocusScope.of(context).requestFocus(_textFieldNode);
                      } else {
                        _isShowFace = true;
                        _isShowVoice =false;
                        _isShowTools =false;
                      }
                    });
                  },
                ),
                _isShowSend
                  ? InkWell(
                    onTap: (){
                      if(_textContronller.text.length == 0) {
                        return;
                      }
                      _sendTextMessage(_textContronller.text);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 40,
                      height: 32,
                      margin: EdgeInsets.only(right: 8.0),
                      child: Text(
                        '发送',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).accentColor,
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                    ),
                  )
                : IconButton(
                  icon: Icon(Icons.add_circle_outline),
                  iconSize: 32,
                  onPressed: () {
                    _hideKeyBoard();
                    setState(() {
                      if (_isShowTools) {
                        _isShowTools = false;
                        //  _isShowSend = true;
                      } else {
                        _isShowTools = true;
                        _isShowFace = false;
                        _isShowVoice = false;
                        // _isShowSend = false;
                      }
                    });
                      
                  },
                )

              ],
            ),
          ),
        ),
        (_isShowFace || _isShowTools || _isShowVoice)
        ? Container(
          height: 210,
          child: _bottmoWidget(),
        )
        : SizedBox(
          height: 0,
        )
      ],
    ));
  }
 ///录音的一系列方法
  _startRecord() async {

    //这里要区分ios 和 安卓 问题出现在 jmessage里 安卓里面的语音本地记录是这里的路径
    // if (Platform.isAndroid) {
    //   print('是安卓');
    //   try {
    //   //获取持久化目录

    //     //获取临时目录
    //     String temporaryDir = (await getTemporaryDirectory()).path;
    //     var soundDir = Directory('$temporaryDir/sound');
    //     if (!soundDir.existsSync()) {soundDir.createSync();}
    //     await Vibration.vibrate();

    //     var voiceFilePath = await _flutterSound.startRecorder('${soundDir.path}/${DateTime.now().millisecondsSinceEpoch}');
    //     _voiceFilePath = voiceFilePath;
    //     print('startRecorder:$_voiceFilePath');
    //    _recorderSubscription = _flutterSound.onRecorderStateChanged.listen((e){
    //      DateTime date = new DateTime.fromMillisecondsSinceEpoch(e.currentPosition.toInt());
    //     setState(() {
    //            _voiceDuration = '${date.minute.toString().padLeft(2,'0')}:${date.second.toString().padLeft(2,'0')}';
    //         });
    //   });       
    //   } catch (error) {
    //     ToastUtil.showTextToast('录音失败');
    //   }



    // } else {
      // String dir2 = (await getApplicationDocumentsDirectory()).path;
      // print('这里的路径是什么$dir2');
      String dir = (await getTemporaryDirectory()).path;
      var soundDir = Directory('$dir/sound');
      if (!soundDir.existsSync()) {soundDir.createSync();}
  
      try {
      await Vibration.vibrate();
      var voiceFilePath = await _flutterSound.startRecorder('${soundDir.path}/${DateTime.now().millisecondsSinceEpoch}');
      if(Platform.isAndroid) {
        _voiceFilePath = voiceFilePath;
      } else {
        _voiceFilePath = voiceFilePath.substring(7);
      }
      print('startRecorder: $_voiceFilePath');
      _recorderSubscription = _flutterSound.onRecorderStateChanged.listen((e){
        DateTime date = new DateTime.fromMillisecondsSinceEpoch(e.currentPosition.toInt());


        setState(() {
                  _voiceDuration = '${date.minute.toString().padLeft(2,'0')}:${date.second.toString().padLeft(2,'0')}';
            });
          
  
      });
      } catch (error) {
        print('开始录音$error');
        ToastUtil.showTextToast('手机权限错误，请检查');
      }
    // }
      
      
  }

  _stopRecord() async {
   
    String result = await _flutterSound.stopRecorder();
    print('stopPlayer: $result');
    _recordFile = File(_voiceFilePath);
    print('录音文件的路径${_recordFile.path}');
     try {
    if(Platform.isAndroid) {
        String documentDir = (await getApplicationDocumentsDirectory()).path;
        var voiceDir = Directory('$documentDir/file/voice/${SpUtil.getString('username')}');
        if (!voiceDir.existsSync()) { voiceDir.createSync(recursive: true);}
        File androidVoiceFile = await _recordFile.copy('${voiceDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp3');
        _androidVoiceFilePath = androidVoiceFile.path;
        print('安卓的路径是什么$_androidVoiceFilePath');   
    }


    } catch (error) {
      print('录音错误是什么$error');
      ToastUtil.showTextToast('录音错误');
    }

  }

  _playRecord() async{
    
    if (_voiceFilePath == '') {
      ToastUtil.showTextToast('没有录音');
    } else {
      if (_flutterSound.isPlaying) {
        _flutterSound.stopPlayer().then((result){
          ToastUtil.showTextToast('停止试听');
        });
        return;
      }
      try {
      String path = await _flutterSound.startPlayer(_voiceFilePath);
      print('startplay: $path');
      ToastUtil.showTextToast('开始试听');
      } catch (error) {
        print('试听失败$error');
        ToastUtil.showTextToast('试听失败');
      }
    }
  }

  _deleteRecord() {

    if (_recordFile != null) {
      _recordFile.delete()
        .then((result){
          print(result);
          ToastUtil.showTextToast('删除成功');
          setState(() {
            _voiceDuration = '';
            _voiceFilePath = '';
          });
        })
        .catchError((error){
          print('删除失败$error');
          ToastUtil.showTextToast('删除错误，录音不存在');
      });
    } 
  }

/// 发送消息的一系列方法

_sendTextMessage(String text) async{

  try {
    JMTextMessage message = await jmessage.sendTextMessage(
      type: userTarget,text:text 
    );
    setState(() {
      messageList.insert(0, message);
      from = from + 1;
      _textContronller.text = '';
    });
    eventBus.fire(ReceiveMessage(message: 'new'));
    _scrollControoler.jumpTo(0);
  } catch (error) {
    ToastUtil.showTextToast('发送失败');
  }
  
}

_sendVoiceMessage() async{
  String path = '';
  if (Platform.isAndroid) {
    path = _androidVoiceFilePath;
  } else {
     path = _voiceFilePath;
  }
      
  if (path == '') {
    ToastUtil.showTextToast('没有录音');
  } else {


    ToastUtil.showLoadingToastWithText('上传中');
    try {

 


      JMVoiceMessage message = await jmessage.sendVoiceMessage(
        type: userTarget,
        path: path
      );



      print('消息的路径${message.path}');
      setState(() {
        messageList.insert(0, message);
        from = from + 1;
      });
      ToastUtil.dismissMyToast();
      _recordFile.delete().then((result){
        setState(() {
          _voiceDuration = '';
          _voiceFilePath = '';
        });
      });
      eventBus.fire(ReceiveMessage(message: 'new'));
      _scrollControoler.jumpTo(0);

    } catch (error) {
      ToastUtil.showTextToast('发送失败');
    }
  }
}

_sendImageMessage(String path) async{
  ToastUtil.showLoadingToastWithText('上传中');
  try {
    JMImageMessage message = await jmessage.sendImageMessage(
      type: userTarget,
      path: path,
    );
    setState(() {
      messageList.insert(0, message);
      from = from + 1;
    });
    ToastUtil.dismissMyToast();
    eventBus.fire(ReceiveMessage(message: 'new'));

  } catch (error) {
    ToastUtil.showTextToast('发送失败');
  }
}

 _hideKeyBoard() {
    _textFieldNode.unfocus();
  }


Widget _buildChatTextItem({
  JMTextMessage textMessage,
  bool showTime,

  }) {
  


  bool isEmoji = false;
  if (textMessage.text.contains('assets/images/face') || textMessage.text.contains('assets/images/figure')) {
    isEmoji = true;
  }

  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
    showTime ?  Container(
     padding: EdgeInsets.all(5.0),
     margin: EdgeInsets.only(top: 0,bottom: 20),
     decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.black12,
      ),
      child: Text(
         TimeUtil.getMessageTime(textMessage.createTime),
        style: TextStyle(fontSize: 10,),
      ),
    ): Container(),
    textMessage.isSend ?
    Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Container(
          ),
        ),
        Expanded(
         flex: 5,
          child: Align(
            alignment: Alignment.topRight,
            child: isEmoji ? _buildEmoji(textMessage.text,textMessage.isSend):
               Container(
                 padding: EdgeInsets.only(top: 10,bottom: 10,left: 10,right: 10),
                 margin: EdgeInsets.only(right: 10,left: 10),
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(5.0),
                   color: Colors.green[200]
                 ),
                 child: Text(
                   textMessage.text,
                   style: TextStyle(fontSize: 18,color: Colors.black),
                 ),
               ),
             ),
           ),
           Expanded(
             flex: 1,
             child: Align(
               alignment: Alignment.topCenter,
               child: Padding(
                 padding: EdgeInsets.only(right: 10,),
                 child: Image.file(
                    File(myAvatarPath),
                    fit: BoxFit.fitWidth,
                  ),
               )
             ),
           )
         ],
       ) :Row(
         mainAxisAlignment: MainAxisAlignment.start,
         crossAxisAlignment: CrossAxisAlignment.start,
         children: <Widget>[
           Expanded(
             flex: 1,
             child: Align(
               alignment: Alignment.topCenter,
               child: Padding(
                 padding: EdgeInsets.only(left: 10),
                 child: Image.file(
                   File(targetUserAvatarPath),
                   fit: BoxFit.fitWidth,
                 ),
               )
             ),
           ),
           Expanded(
             flex: 5,
             child: Align(
               alignment: Alignment.topLeft,
               child: isEmoji ? _buildEmoji(textMessage.text,textMessage.isSend) : Container(
                 padding: EdgeInsets.only(top: 10,bottom: 10,left: 10,right: 10),
                 margin: EdgeInsets.only(right: 10,left: 10),
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(5.0),
                   color: Colors.blue[200],
                 ),
                 child: Text(
                   textMessage.text,
                   style: TextStyle(fontSize: 18,color: Colors.black),
                 ),
               ),
             ),
           ),
           Expanded(
             flex: 1,
             child: Container(),
           )
         ],
       ),
       Container(height: 20,),
      ],
    );
}

  Widget _buildEmoji(String text ,bool isSend){
    if(text.contains('assets/images/face')) {
      return Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.only(left: 10,right:10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: isSend ? Colors.green[200] : Colors.blue[200]
          ),
        child: Image.asset(
          text,
          width: 24,
          height: 24,
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.only(left: 10,right: 10),
        child: Image.asset(
          text,
          width: 64,
          height: 64
        ),
      );
    }
  }
  

  Widget _buildChatImageItem({
    JMImageMessage imageMessage,
    bool showTime,
  }) {

    
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        showTime ? Container(
          padding: EdgeInsets.all(5.0),
          margin: EdgeInsets.only(top: 0,bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Colors.black12,
          ),
          child: Text(
            TimeUtil.getMessageTime(imageMessage.createTime),
            style: TextStyle(fontSize: 10,),
          ),
        ) : Container(),
       imageMessage.isSend ?Row(
         mainAxisAlignment: MainAxisAlignment.start,
         crossAxisAlignment: CrossAxisAlignment.start,
         children: <Widget>[
           Expanded(
             flex: 1,
             child: Container(

             ),
           ),
           Expanded(
             flex: 5,
             child: Align(
               alignment: Alignment.topRight,
               child: 
               Container(
                 
                 margin: EdgeInsets.only(right: 10,left: 10),
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(5.0),
                  //  color: Colors.green[200]
                 ),
                 child:GestureDetector(
                   onTap: (){
                    //  Navigator.push(context, MaterialPageRoute(builder: (context){
                    //    return ViewImagePage(
                    //      thumbPath: thumbImage,
                    //    );
                    //  }));
                    Navigator.push(context,PageRouteBuilder(
                        transitionDuration: Duration(milliseconds: 500),
                        pageBuilder: (BuildContext context, Animation animation,
                          Animation secondaryAnimation) {
                            return new FadeTransition(
                              opacity: animation,
                              child: ViewImagePage(
                                thumbPath: imageMessage.thumbPath,
                                messageId: imageMessage.serverMessageId == null ? '': imageMessage.serverMessageId,
                              ),
                            );
                          }
                    ));
                   },
                   onLongPress: (){
                    //  _downloadThumbImage(messageId);
                   },
                   child: Hero(
                     tag: imageMessage.serverMessageId == null ? '' : imageMessage.serverMessageId,
                    child: imageMessage.thumbPath == null ? Image.asset(
                      'assets/images/load_error.png',
                      height: 150,
                      width: 150,
                      fit: BoxFit.contain,
                    ) : Image.file(
                     File( imageMessage.thumbPath),
                     height: 150,
                     width: 150,
                     fit: BoxFit.contain,
                   ),
                   )
                 )
               ),
             ),
           ),
           Expanded(
             flex: 1,
             child: Align(
               alignment: Alignment.topCenter,
               child: Padding(
                 padding: EdgeInsets.only(right: 10,),
                 child: Image.file(
                    File(myAvatarPath),
                    fit: BoxFit.fitWidth,
                  ),
               )
             ),
           )
         ],
       ) :Row(
         mainAxisAlignment: MainAxisAlignment.start,
         crossAxisAlignment: CrossAxisAlignment.start,
         children: <Widget>[
           Expanded(
             flex: 1,
             child: Align(
               alignment: Alignment.topCenter,
               child: Padding(
                 padding: EdgeInsets.only(left: 10),
                 child: Image.file(
                   File(targetUserAvatarPath),
                   fit: BoxFit.fitWidth,
                 ),
               )
             ),
           ),
           Expanded(
             flex: 5,
             child: Align(
               alignment: Alignment.topLeft,
               child: Container(
                 margin: EdgeInsets.only(right: 10,left: 10),
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(5.0),
                  //  color: Colors.blue[200],
                 ),
                 child:GestureDetector(
                   onTap: (){
                    //  Navigator.push(context, MaterialPageRoute(builder: (context){
                    //    return ViewImagePage(
                    //      thumbPath: thumbImage,
                    //    );
                    // //  }));
                    Navigator.push(context,PageRouteBuilder(
                        transitionDuration: Duration(milliseconds: 500),
                        pageBuilder: (BuildContext context, Animation animation,
                          Animation secondaryAnimation) {
                            return new FadeTransition(
                              opacity: animation,
                              child: ViewImagePage(
                                thumbPath: imageMessage.thumbPath,
                                messageId: imageMessage.serverMessageId == null ? '' :imageMessage.serverMessageId
                              ),
                            );
                          }
                    ));
                   },
                   child: Hero(
                     tag: imageMessage.serverMessageId == null ? '' : imageMessage.serverMessageId,
                   child:imageMessage.thumbPath == null ? Image.asset(
                     'assets/images/load_error.png',
                     width: 150,
                     height: 150,
                     fit: BoxFit.contain,
                   ) :  Image.file(
                   File(imageMessage.thumbPath),
                   height: 150,
                   width: 150,
                   fit: BoxFit.contain,
                 )
                 )
                 )
               ),
             ),
           ),
           Expanded(
             flex: 1,
             child: Container(),
           )
         ],
       ),
       Container(height: 20,),
        
      ],
    );
  }

  _buildVoiceMessage(
    JMVoiceMessage voiceMessage,
    bool showTime,
  ) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        showTime ?  Container(
          padding: EdgeInsets.all(5.0),
          margin: EdgeInsets.only(top: 0,bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Colors.black12,
          ),
          child: Text(
            TimeUtil.getMessageTime(voiceMessage.createTime),
            style: TextStyle(fontSize: 10,),
          ),
        ) : Container(),
       voiceMessage.isSend ?Row(
         mainAxisAlignment: MainAxisAlignment.start,
         crossAxisAlignment: CrossAxisAlignment.start,
         children: <Widget>[
           Expanded(
             flex: 1,
             child: Container(

             ),
           ),
           Expanded(
             flex: 5,
             child: Align(
               alignment: Alignment.topRight,
               child:GestureDetector(
                   onLongPress: (){
                    //  _downloadVoice();
                   },
                   onTap: (){
                     _startPlayMessageVoice(voiceMessage.path);
                   },
               child: Container(
                 width: 100,
                 padding: EdgeInsets.all(10),
                 margin: EdgeInsets.only(right: 10,left: 10),
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(5.0),
                   color: Colors.green[200]
                 ),

                   child:Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     crossAxisAlignment: CrossAxisAlignment.center,
                     children: <Widget>[
                       Text(
                         '${voiceMessage.duration.toInt().toString()}s',
                         style: TextStyle(color: Colors.black,fontSize: 16),
                       ),
                       Container(width: 4,),
                       Icon(
                         Icons.keyboard_voice,
                         color: Colors.black26,
                         size: 24,
                       )
                     ],
                   ) 
                 
                 ),
               )
             ),
           ),
           Expanded(
             flex: 1,
             child: Align(
               alignment: Alignment.topCenter,
               child: Padding(
                 padding: EdgeInsets.only(right: 10,),
                 child: Image.file(
                    File(myAvatarPath),
                    fit: BoxFit.fitWidth,
                  ),
               )
             ),
           )
         ],
       ) :Row(
         mainAxisAlignment: MainAxisAlignment.start,
         crossAxisAlignment: CrossAxisAlignment.start,
         children: <Widget>[
           Expanded(
             flex: 1,
             child: Align(
               alignment: Alignment.topCenter,
               child: Padding(
                 padding: EdgeInsets.only(left: 10),
                 child: Image.file(
                   File(targetUserAvatarPath),
                   fit: BoxFit.fitWidth,
                 ),
               )
             ),
           ),
           Expanded(
             flex: 5,
             child: Align(
               alignment: Alignment.topLeft,
                 child:GestureDetector(
                    onTap: () {
                      _startPlayMessageVoice(voiceMessage.path);
                    },
                    onLongPress: () {
                      // _downloadVoice();
                    },
                    child: Container(
                      width: 100,
                 padding: EdgeInsets.all(10),
                 margin: EdgeInsets.only(right: 10,left: 10),
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(5.0),
                    color: Colors.blue[200],
                 ),

                    child: Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     crossAxisAlignment: CrossAxisAlignment.center,
                     children: <Widget>[
                       Text(
                         '${voiceMessage.duration.toInt().toString()}s',
                         style: TextStyle(color: Colors.black,fontSize: 16),
                       ),
                       Container(width: 2,),
                       Icon(
                         Icons.keyboard_voice,
                         color: Colors.black26,
                         size: 18,
                       )
                     ],
                   ) 
                 ) 
               ),
             ),
           ),
           Expanded(
             flex: 1,
             child: Container(),
           )
         ],
       ),
       Container(height: 20,),
        
      ],
    );
  }

  _startPlayMessageVoice(String path) {
    print('播放前的路径$path');
    if (_flutterSound.isPlaying) {
      _flutterSound.stopPlayer().then((value) {
        ToastUtil.showTextToast('停止播放');
      })
      .catchError((error) {
        ToastUtil.showTextToast('停止错误');
      });
    } else {
      _flutterSound.startPlayer(path).then((value) {
        ToastUtil.showTextToast('开始播放');
      })
      .catchError((error) {
        print('消息播放错误$error');
        ToastUtil.showTextToast('播放错误');
      });
    }
  }

  int _getPreviousMessageTime(dynamic message) {
    if (message is JMTextMessage) {
      JMTextMessage textMessage = message;
      return textMessage.createTime;
    } else if (message is JMImageMessage) {
      JMImageMessage imageMessage = message;
      return imageMessage.createTime;
    } else {
      JMVoiceMessage voiceMessage = message;
      return voiceMessage.createTime;
    }
  }
  

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text(
          widget.conversationInfo.title,
        ),
        centerTitle: true,
        elevation: 5.0,
      ),
      body:Stack(
        children: <Widget>[
          //为什么要这么写 防止键盘弹出导致背景图被压缩
          SingleChildScrollView(
            child:Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: _bgImagePath == '' ? BoxDecoration():
          BoxDecoration(
            image:  DecorationImage(
              image: ExtendedNetworkImageProvider(
              _bgImagePath,
              cache: true
            ),
              fit: BoxFit.fill,
               ),
          ),

          )
          ),
          _body()
        ],
      )
      
    );
  }
}


