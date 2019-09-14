import 'package:nora_chat/ui/login_page/login_theme.dart' as login_theme;
import 'package:nora_chat/ui/login_page/bubble_indication_painter.dart';
import 'package:nora_chat/utils/http_util.dart';
import 'package:nora_chat/utils/jmessage_util.dart';
import 'package:nora_chat/utils/sp_util.dart';
import 'package:nora_chat/utils/constants_util.dart';
import 'package:nora_chat/utils/toast_util.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override 
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
  with SingleTickerProviderStateMixin {
    final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

    final FocusNode myFocusNodeMobileLogin = FocusNode();
    final FocusNode myFocusNodePasswordLogin = FocusNode();

    final FocusNode myFocusNodePassword = FocusNode();
    final FocusNode myFocusNodeMobile = FocusNode();
    final FocusNode myFocusNodeName = FocusNode();
    
    TextEditingController loginMobileController = new TextEditingController();
    TextEditingController loginPasswordController = new TextEditingController();

    bool _obscureTextLogin = true;
    bool _obscureTextSignup = true;
    bool _obscureTextSignupConfirm = true;

    bool logInButtonCanBeClick = true;

    TextEditingController signupMobileController = new TextEditingController();
    TextEditingController signupNameController = new TextEditingController();
    TextEditingController signupPasswordController = new TextEditingController();
    TextEditingController signupConfirmPasswordController = new TextEditingController();

    PageController _pageController;

    Color left = Colors.black;
    Color right = Colors.white;

    @override 
    Widget build(BuildContext context) {
      return Scaffold(
        key: _scaffoldKey,
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll){
            overscroll.disallowGlow();
        },

            // width: MediaQuery.of(context).size.width,
            // height: MediaQuery.of(context).size.height,
            // decoration: BoxDecoration(
            //   gradient: LinearGradient(
            //     colors: [
            //       Theme.Colors.loginGradienStart,
            //       Theme.Colors.loginGradienEnd
            //     ],
            //     begin: const FractionalOffset(0.0, 0.0),
            //     end: const FractionalOffset(1.0, 1.0),
            //     stops: [0.0, 1.0],
            //     tileMode: TileMode.clamp
            //   )
            // ),
            child: SingleChildScrollView(
            // child: _buildBody(context),
              child: InkWell(
                child: _buildBody(context),
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
              },
            ),
          ),
         
        ),
      );
    }
  

    @override 
    void dispose() {
      myFocusNodeMobile.dispose();
      myFocusNodePassword.dispose();
      myFocusNodeName.dispose();
      myFocusNodeMobileLogin.dispose();
      myFocusNodePasswordLogin.dispose();
      super.dispose();
    }

  @override 
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    _pageController = PageController();
    loginMobileController.text = SpUtil.getString(ConstantsUtil.USERNAME);
    // loginMobileController.text = SpUtil.getString('username');
  }

  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 16.0),
      ),
      backgroundColor: Colors.black54,
      duration: Duration(seconds: 2),
    ));
  }
  
  ///生成菜单栏方法
  Widget _buildMenuBar(BuildContext context) {
    return Container(
      width: 300,
      height: 50,
      decoration: BoxDecoration(
        color: Color(0x552B2B2B),
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      child: CustomPaint(
        painter: TabIndicationPainter(pageController: _pageController),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _onSignInButtonPress,
                child: Text(
                  "已有",
                  style: TextStyle(color: left,fontSize: 16.0),
                ),
              ),
            ),
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _onSignUpButtonPress,
                child: Text(
                  '新的',
                  style: TextStyle(
                    color: right,
                    fontSize: 16.0
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  ///生成登陆页面
  Widget _buildSignIn(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              Card(
                elevation: 2.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: 300,
                  height: 170,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 15.0,bottom: 15.0,left: 25.0,right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodeMobileLogin,
                          controller: loginMobileController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 16.0,color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.phone_iphone,
                              color: Colors.black,
                              size: 20.0,
                            ),
                            hintText: "请输入账号",
                            hintStyle: TextStyle(fontSize: 17.0,color: Colors.grey)
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 15.0,bottom: 15.0,left: 25.0,right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodePasswordLogin,
                          controller: loginPasswordController,
                          obscureText: _obscureTextLogin,
                          style: TextStyle(fontSize: 16.0, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.lock,
                              size: 22.0,
                              color: Colors.black,
                            ),
                            hintText: '请输入密码',
                            hintStyle: TextStyle(
                              fontSize: 17.0,
                              color: Colors.grey
                            ),
                            suffixIcon: GestureDetector(
                              onTap: _toggleLogin,
                              child: Icon(
                                Icons.remove_red_eye,
                                size: 15.0,
                                color: Colors.black,
                              ),
                            )
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 150),
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: login_theme.Colors.loginGradienStart,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                    BoxShadow(
                      color: login_theme.Colors.loginGradienEnd,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                  ],
                  gradient: new LinearGradient(
                    colors: [
                      login_theme.Colors.loginGradienEnd,
                      login_theme.Colors.loginGradienStart
                    ],
                    begin: const FractionalOffset(0.2, 0.2),
                    end: const FractionalOffset(1.0, 1.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp
                  ),
                ),
                child: MaterialButton(
                  highlightColor: Colors.transparent,
                  splashColor: login_theme.Colors.loginGradienEnd,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7.50,horizontal: 42.0),
                    child: Text(
                      "登录",
                      style: TextStyle(color: Colors.white,fontSize: 25.0),
                    ),
                  ),
                  onPressed: _loginBtnClicked(),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: FlatButton(
              onPressed: () {},
              child: Text(
                "忘记密码?",
                style: TextStyle(decoration: TextDecoration.underline, fontSize: 16.0, color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    gradient: new LinearGradient(
                      colors: [
                        Colors.white10,
                        Colors.white
                      ],
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(1.0, 1.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp
                    ),
                  ),
                  width: 100.0,
                  height: 1.0,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 5.0, right: 5.0),
                  child: Text(
                    '或',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.white10,
                      ],
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(1.0, 1.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp,
                    ),
                  ),
                  width: 100.0,
                  height: 1.0,
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 5.0, right: 40.0),
                child: GestureDetector(
                  onTap: () {
                    showInSnackBar('暂未实现微信登陆');
                    // jmessage.getMyInfo().then((result){
                    //   print(result.username);
                    // }).catchError((error){
                    //   print('发生了错误');
                    // });
                  } ,
                  child: Container(
                    padding: const EdgeInsets.all(13.0),
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Image.asset(
                      'assets/images/wechat.png',
                      width: 25,
                      height: 25,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: GestureDetector(
                  onTap: () => showInSnackBar('暂未实现bilibili登陆'),
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white
                    ),
                    child: Image.asset(
                      'assets/images/bilibili.png',
                      height: 25,
                      width: 25,
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  ///生成注册页面
  Widget _buildSignUp(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              Card(
                elevation: 2.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                child: Container(
                  width: 300.0,
                  height: 320.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          top: 15.0, bottom: 15.0, left: 25.0, right: 25.0
                        ),
                        child: TextField(
                          focusNode: myFocusNodeName,
                          controller: signupNameController,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.perm_identity,
                              color: Colors.black,
                            ),
                            hintText: "用户名",
                            hintStyle: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey
                            )
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: 15.0, bottom: 15.0, left: 25.0, right: 25.0
                        ),
                        child: TextField(
                          focusNode: myFocusNodeMobile,
                          controller: signupMobileController,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(fontSize: 16.0, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.phone_iphone,
                              color: Colors.black,
                            ),
                            hintText: '手机号',
                            hintStyle: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: 15.0, bottom: 15.0, left: 25.0, right: 25.0
                        ),
                        child: TextField(
                          focusNode: myFocusNodePassword,
                          controller: signupPasswordController,
                          obscureText: _obscureTextSignup,
                          style: TextStyle(fontSize: 16.0, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.lock,
                              color: Colors.black,
                            ),
                            hintText: "密码",
                            hintStyle: TextStyle(fontSize: 16.0,color: Colors.grey),
                            suffixIcon: GestureDetector(
                              onTap: _toggleSignup,
                              child: Icon(
                                Icons.remove_red_eye,
                                size: 15.0,
                                color: Colors.black,
                              ),
                            )
                          ),
                        ),
                      ),
                      Container(
                        width: 250,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: 15.0, bottom: 15.0, left: 25.0, right: 25.0
                        ),
                        child: TextField(
                          controller: signupConfirmPasswordController,
                          obscureText: _obscureTextSignupConfirm,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.lock,
                              color: Colors.black,
                            ),
                            hintText: '确认密码',
                            hintStyle: TextStyle(fontSize: 16.0,color: Colors.grey),
                            suffixIcon: GestureDetector(
                              onTap: _toggleSignupConfirm,
                              child: Icon(
                                Icons.remove_red_eye,
                                size: 15.0,
                                color: Colors.black,
                              ),
                            )
                          ),
                        ),
                      )

                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 300.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: login_theme.Colors.loginGradienStart,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0
                    ),
                    BoxShadow(
                      color: login_theme.Colors.loginGradienEnd,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0
                    ),
                  ],
                  gradient: LinearGradient(
                    colors: [
                      login_theme.Colors.loginGradienEnd,
                      login_theme.Colors.loginGradienStart
                    ],
                    begin: const FractionalOffset(0.2, 0.2),
                    end: const FractionalOffset(1.0, 1.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp
                  ),
                ),
                child: MaterialButton(
                  highlightColor: Colors.transparent,
                  splashColor: login_theme.Colors.loginGradienEnd,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 7.50, horizontal: 42.0
                    ),
                    child: Text(
                      '注册',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                  onPressed: (){
                    _registerBtnClicked();
                  },
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  ///生成主体页面 
  Widget _buildBody(BuildContext context) {
    return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height >= 675.0 ? MediaQuery.of(context).size.height : 675.0,
            decoration: new BoxDecoration(
              gradient: new LinearGradient(
                colors: [
                  login_theme.Colors.loginGradienStart,
                  login_theme.Colors.loginGradienEnd
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 1.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp 
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 45.0),
                  child: Image(
                    width: 140.0,
                    height: 140.0,
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/login_bg.png'),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: _buildMenuBar(context),
                ),
                Expanded(
                  flex: 2,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (i) {
                      if (i == 0) {
                        setState(() {
                          right = Colors.white;
                          left = Colors.black;
                        });
                      } else if (i == 1) {
                        setState(() {
                          right = Colors.black;
                          left = Colors.white;
                        });
                      }
                    },
                    children: <Widget>[
                      new ConstrainedBox(
                        constraints: const BoxConstraints.expand(),
                        child: _buildSignIn(context),
                      ),
                      new ConstrainedBox(
                        constraints: const BoxConstraints.expand(),
                        child: _buildSignUp(context),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }

  void _onSignInButtonPress() {
     _pageController.animateToPage(0,
     duration: Duration(milliseconds: 500), curve: Curves.decelerate);  
  }

  void _onSignUpButtonPress() {
    _pageController?.animateToPage(1,
    duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _toggleLogin(){
    setState(() {
      _obscureTextLogin = !_obscureTextLogin;
    });
  }

  void _toggleSignup(){
    setState(() {
      _obscureTextSignup = !_obscureTextSignup;
    });
  }

  void _toggleSignupConfirm() {
    setState(() {
      _obscureTextSignupConfirm = !_obscureTextSignupConfirm;
    });
  }

  Function _loginBtnClicked() {
    if (logInButtonCanBeClick) {
      return (){
       if(loginMobileController.text.length == 0) {
       showInSnackBar('请输入手机号码');
    } else if (loginPasswordController.text.length == 0) {
      showInSnackBar('密码不能为空');
    } else {
      _loginByMobileAndPassword(loginMobileController.text, loginPasswordController.text);
    }
      };
    } else {
      return null;
    }

  }

  
   _loginByMobileAndPassword (String mobileStr, String passwordStr) async{
     ToastUtil.showLoadingToastWithText('登陆中...');
      setState(() {
        logInButtonCanBeClick = false;
      });
      try {
        String url = aliUrl + '/login';
        var result = await HttpUtil.postRequest(url, {
          'username': mobileStr,
          'password': passwordStr,
        });

        if (result['status'] == 200 ) {
          _jMessageLogin(mobileStr, passwordStr);
        } else {
          showInSnackBar(result['message']);
          ToastUtil.dismissMyToast();
          setState(() {
            logInButtonCanBeClick = true;
          });
        }

      } catch (error) {
        showInSnackBar('服务器连接失败');
        ToastUtil.dismissMyToast();
        setState(() {
          logInButtonCanBeClick = true;
        });
      }
  }

  void _registerBtnClicked() {
    if(signupNameController.text.length == 0) {
      showInSnackBar('用户名不能为空');
    } else if (signupMobileController.text.length == 0) {
      showInSnackBar('手机号不能为空');
    } else if (signupPasswordController.text.length == 0) {
      showInSnackBar('密码不能为空');
    } else if (signupConfirmPasswordController.text != signupPasswordController.text) {
      showInSnackBar('两次密码不一致');
    } else {
      _signUpWithData(signupNameController.text, signupMobileController.text, signupPasswordController.text);
    }
  }

  void _signUpWithData(String name, String moblie, String password ) async {
    String url = aliUrl + '/userRegister';
    try {
      var result = await HttpUtil.postRequest(url, {
        'username': moblie,
        'password': password,
        'nickname': name,
      });

      if (result['status'] == 200) {
        showInSnackBar(result['message']);
        _onSignInButtonPress();
        loginMobileController.text = moblie;
      } else {
        showInSnackBar(result['message']);
      }

    } catch (error) {
      showInSnackBar('连接服务器失败');
    }
  }
 
  _jMessageLogin(String username, String password) async {

    try {
   await jmessage.login(username: username, password: password);
   JMUserInfo user = await jmessage.getMyInfo();
   print(user.toJson());
   if (user.username == null) {
     showInSnackBar('登陆失败，请重试');
     ToastUtil.dismissMyToast();
     setState(() {
       logInButtonCanBeClick = true;
     });
   } else  {
     await SpUtil.putString(ConstantsUtil.USERNAME, username);
     await _initUserMessage(username);
      await ToastUtil.showTextToast('登陆成功');
     await Navigator.pushReplacementNamed(context, '/main_page');

   }
    } catch (error) {
      showInSnackBar('登陆失败，请重试');
      ToastUtil.dismissMyToast();
      setState(() {
        logInButtonCanBeClick = true;
      });
    }
  }
  _initUserMessage(String username) async {
    String url = aliUrl + '/getUserMessage';
    try {
      var result = await HttpUtil.getRequest(url, {'username':username});
      if (result['data'] != null) {
        Map resultMap = result['data'];
        List friendsList = resultMap['friendsHistory'];
        List messageList = resultMap['messageHistory'];
        String count = resultMap['numberUnreadMessages'];
        await SpUtil.putObjectList(ConstantsUtil.FRIEND_HISTORY, friendsList);
        await SpUtil.putObjectList(ConstantsUtil.MESSAGE_HISTORY, messageList);
        await SpUtil.putString(ConstantsUtil.UNREAD_FRIEND_COUNT, count);
      } else {
        SpUtil.putObjectList(ConstantsUtil.FRIEND_HISTORY, []);
        SpUtil.putObjectList(ConstantsUtil.MESSAGE_HISTORY, []);
        SpUtil.putString(ConstantsUtil.UNREAD_FRIEND_COUNT, '0');
      }
    String url2 = aliUrl + '/getUserSetting';
    var result2 = await HttpUtil.getRequest(url2, {'username': username});
    if (result2['data'] != null) {
      Map resultMap = result['data'];
      await SpUtil.putString(ConstantsUtil.ABLUM_BG_IMAGE, resultMap['ablumBgImage']);
      await SpUtil.putString(ConstantsUtil.CHAT_BG_IMAGE, resultMap['chatBgImage']);
    } else {
      await SpUtil.putString(ConstantsUtil.CHAT_BG_IMAGE, '');
      await SpUtil.putString(ConstantsUtil.ABLUM_BG_IMAGE, '');
    }
    } catch (error) {
      throw error;
    }
  }
}
