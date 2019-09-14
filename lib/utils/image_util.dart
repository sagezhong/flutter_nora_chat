import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:flutter/material.dart';


class ImageUtil {
  /*
  * 从相机取图片
  */
  static Future getCameraImage() async {
    return await ImagePicker.pickImage(source: ImageSource.camera);
  }

  /*
  * 从相册取图片
  */
  static Future getGalleryImage() async {
    return await ImagePicker.pickImage(source: ImageSource.gallery);
  }

  static Future<File> cropImage({File imageFile,int maxWidth,int maxHeight,double ratioX, double ratioY,}) async {
    return ImageCropper.cropImage(
      sourcePath: imageFile.path,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      ratioX: ratioX,
      ratioY: ratioY,
    );

  }
}