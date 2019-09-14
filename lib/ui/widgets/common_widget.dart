import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:flutter/material.dart';

class CommonWidget {
  static Widget getLoadingWidget(Color color) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(10),
        child: SpinKitFadingCircle(
          size: 40,
          color: color,
          duration: Duration(seconds: 2),
        ),
      ),
    );
  }

    static Widget buildIcon(IconData icon, String text, {Future<void> Function(Object) o}) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 8,
        ),
        InkWell(
            onTap: () {
              if (null != o) {
                o(null);
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                width: 54,
                height: 54,
                color: Colors.black12,
                child: Icon(icon, size: 28),
              ),
            )),
        SizedBox(
          height: 5,
        ),
        Text(
          text,
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}