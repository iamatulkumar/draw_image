import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:ui' as ui show Image;

class Point {
  Color color = Colors.black;
  List points;
  double strokeWidth = 5.0;
  double mScaleFactor;

  Point(this.color, this.strokeWidth, this.points);
}

class PosPoint {
  double mPosX = 0;
  double mPosY = 0;
  PosPoint(this.mPosX, this.mPosY);
}

class CustomePainter extends CustomPainter {
  final double strokeWidth;
  final Color strokeColor;
  Paint _linePaint;
  final bool isClear;
  final List points;
  final double mScaleFactor;
  final ui.Image myBackground;
  final PosPoint posPoint;

  CustomePainter({
    @required this.points,
    @required this.strokeColor,
    @required this.strokeWidth,
    @required this.myBackground,
    this.mScaleFactor,
    this.isClear = true,
    this.posPoint
  }) {
    _linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
  }

  void paint(Canvas canvas, Size size) {

    // canvas.translate(left*mScaleFactor, top*mScaleFactor);
   // canvas.scale(mScaleFactor,mScaleFactor);
    if(myBackground !=null) {
      final left = (size.width - myBackground.width) / 2;
      final top = (size.height - myBackground.height) / 2;
      canvas.drawImage(myBackground, Offset(left,top), Paint());
    }

    if (isClear || points == null || points.length == 0) {
      return;
    }
    for (int i = 0; i < points.length; i++) {
      List curPoints = points[i].points;
      for (int i = 0; i < curPoints.length - 1; i++) {
        if (curPoints[i] != null && curPoints[i + 1] != null)
          canvas.drawLine(curPoints[i], curPoints[i + 1], _linePaint);
      }
    }
  }

  bool shouldRepaint(CustomePainter other) => true;
}
