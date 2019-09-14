import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'dart:io';

var dio = Dio(new BaseOptions(
  connectTimeout: 10000,
  receiveTimeout: 10000,
));

String aliUrl = 'http://120.78.126.169';

String accessKeySecret = '68clcXWdWVK5GQ41Ga1EoxaRAgWgU3';
String ossAccessKeyId = 'LTAIBm5VKCsqzqS4';
String ossUrl = 'http://sagezhong.oss-cn-shenzhen.aliyuncs.com';

/// ### 网络工具类
/// Content-Type为json Response-Type也是json 根据情况修改
class HttpUtil{


  /// ### 发出一个get请求
  /// * [url] 请求url
  /// * [params] 请求参数
  static Future getRequest(String url,Map<String, dynamic> params)  async{
      var response = await dio.get(url,queryParameters: params);
      return response.data;
  }

  /// ### 发出一个post请求
  /// * [url] 请求url
  /// * [params] 请求参数
  static Future postRequest(String url,Map<String, dynamic> params) async {
    var response = await dio.post(url,data: params);
    return response.data;
  }

  ///上传图片到阿里云OSS
  static Future uploadImage(String fileName, File fileObject) async {
        String policyText =
        '{"expiration": "2021-01-01T12:00:00.000Z","conditions": [["content-length-range", 0, 10485760000]]}';
    List<int> policyTextUtf8 = utf8.encode(policyText);
    String policyBase64 = base64.encode(policyTextUtf8);
    List<int> policy = utf8.encode(policyBase64);

    // 利用accessKeySecret签名Policy
    List<int> keyM = utf8.encode(accessKeySecret);
    List<int> signaturePre  = new Hmac(sha1, keyM).convert(policy).bytes;
    String signature = base64.encode(signaturePre);

    BaseOptions options = new BaseOptions();
    options.responseType = ResponseType.plain;
    Dio dio = new Dio(options);

    // 构建formData数据
    FormData data = new FormData.from({
      'key' : 'images/' + fileName,
      'policy': policyBase64,
      'OSSAccessKeyId': ossAccessKeyId,
      'success_action_status' : '200',
      'signature': signature,
      'file': new UploadFileInfo(fileObject, fileName)
    });
    
      Response response = await dio.post(ossUrl,data: data);
      return response.headers;
      
  
  }
  //    //构建policy expriation设置该Policy的失效时间，超过这个失效时间之后，就没有办法通过这个policy上传文件了, content-length-range设置上传文件的大小限制
  //   String policyText = 
  //   '{"expiration": "2020-01-01T12:00:00.000Z","conditions": [["content-length-range", 0, 10485760000]]}';
  //   List<int> policyTextUtf8 = utf8.encode(policyText);
  //   String policyBase64 = base64.encode(policyTextUtf8);
  //   List<int> policy = utf8.encode(policyBase64);

  //   // 利用accessKeySecret签名
  //   List<int> keyM = utf8.encode(accessKeySecret);
  //   List<int> signaturePre = Hmac(sha1, keyM).convert(policy).bytes;
  //   String signature = base64.encode(signaturePre);
    
  //   //用新的dio对象 应该要求的格式不一样
  //   BaseOptions options = BaseOptions(
  //     responseType: ResponseType.plain,
  //     contentType:  ContentType.parse("multipart/form-data"),
  //   );

  //   Dio uploadDio = Dio(options);

  //   // 构造上传data
  //   FormData data = FormData.from({
  //     'key': 'images/' + fileName, //路径
  //     'policy': policyBase64,
  //     'OSSAcessKeyId': ossAccessKeyId,
  //     'success_action_status': '200',
  //     'signature': signature,
  //     'file': new UploadFileInfo(fileObject, fileName)
  //   });

  //   var response = await uploadDio.post(ossUrl,data: data);
  //   return response.data;

  // }
}