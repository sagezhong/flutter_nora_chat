import 'package:extended_image/extended_image.dart';

import 'package:flutter/material.dart';
import 'dart:io';

class ViewImagePage extends StatefulWidget {
  final String thumbPath;
  final String messageId;
  const ViewImagePage({Key key, @required this.thumbPath,this.messageId});
  @override
  _ViewImagePageState createState() => _ViewImagePageState();
}

class _ViewImagePageState extends State<ViewImagePage> {

  @override
  Widget build(BuildContext context) {
      print('看一下tag${widget.messageId}');
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
      child: Hero(
        tag: widget.messageId,
        child: widget.thumbPath == null ? ExtendedImage.asset(
          'assets/images/load_error.png',
          fit: BoxFit.contain,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          mode: ExtendedImageMode.Gesture,
          gestureConfig: GestureConfig(
            minScale: 1.0,
            animationMinScale: 0.5,
            maxScale: 3.0,
            animationMaxScale: 3.5,
            speed: 1.0,
            inertialSpeed: 100.0,
            initialScale: 1.0,
            inPageView: false
          ),

        ) : ExtendedImage.file(
          File(widget.thumbPath),
          fit: BoxFit.contain,
          width:MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          mode: ExtendedImageMode.Gesture,
          gestureConfig: GestureConfig(
            minScale: 1.0,
            animationMinScale: 0.5,
            maxScale: 3.0,
            animationMaxScale: 3.5,
            speed: 1.0,
            inertialSpeed: 100.0,
            initialScale: 1.0,
            inPageView: false
          ),
        ),
        )
      ),
    );
  }
}