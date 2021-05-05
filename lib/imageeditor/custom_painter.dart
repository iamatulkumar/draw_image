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
    this.mScaleFactor = 1.0,
    this.isClear = true,
    this.posPoint
  }) {
    _linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
  }

  void paint(Canvas canvas, Size size) {

    final left = (size.width - myBackground.width) / 2;
    final top = (size.height - myBackground.height) / 2;
    canvas.translate(left, top);
    canvas.scale(mScaleFactor, mScaleFactor);

    if(myBackground !=null) {
      final left = (size.width - myBackground.width) / 2;
      final top = (size.height - myBackground.height) / 2;
      // df = left
      // dt = top
      canvas.drawImage(myBackground, Offset(left,top), Paint());
    }
    if (isClear || points == null || points.length == 0) {
      return;
    }
    for (int i = 0; i < points.length; i++) {
      // _linePaint..color = points[i].color;
      // _linePaint..strokeWidth = points[i].strokeWidth;
      List curPoints = points[i].points;
      // if (curPoints == null || curPoints.length == 0) {
      //   break;
      // }
      for (int i = 0; i < curPoints.length - 1; i++) {
        if (curPoints[i] != null && curPoints[i + 1] != null)
          canvas.drawLine(curPoints[i], curPoints[i + 1], _linePaint);
//      canvas.drawPoints(PointMode.polygon, curPoints, _linePaint);
      }
    }
  }

  bool shouldRepaint(CustomePainter other) => true;
}
