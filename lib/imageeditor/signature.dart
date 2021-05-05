import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;
import 'package:vector_math/vector_math_64.dart' show Vector3;

/// signature canvas. Controller is required, other parameters are optional.
/// widget/canvas expands to maximum by default.
/// this behaviour can be overridden using width and/or height parameters.
class Signature extends StatefulWidget {
  /// constructor
  const Signature(
      {@required this.controller,
      Key key,
      this.backgroundColor = Colors.grey,
      this.width,
      this.height,
      this.image})
      : super(key: key);

  /// signature widget controller
  final SignatureController controller;

  /// signature widget width
  final double width;

  /// signature widget height
  final double height;

  final File image;

  /// signature widget background color
  final Color backgroundColor;

  @override
  State createState() => SignatureState();
}

/// signature widget state
class SignatureState extends State<Signature> {
  /// Helper variable indicating that user has left the canvas so we can prevent linking next point
  /// with straight line.
  ui.Image _image;
  bool _isOutsideDrawField = false;
  double _scale = 1.0;
  double _previousScale = 1.0;

  Map<int, Offset> touchPositions = <int, Offset>{};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadImage();
  }

  _loadImage() async {
    ByteData bd = await rootBundle.load("graphic/screenshot.png");

    final Uint8List bytes = Uint8List.view(bd.buffer);

    final ui.Codec codec = await ui.instantiateImageCodec(bytes);

    final ui.Image image = (await codec.getNextFrame()).image;

    setState(() => _image = image);
  }
//await file.readAsBytes();
  Future<ui.Image> loadUiImage(File file) async {

    final Uint8List bytes = await file.readAsBytes();

    final ui.Codec codec = await ui.instantiateImageCodec(bytes);

    final ui.Image image = (await codec.getNextFrame()).image;

    setState(() => _image = image);
  }

  void savePointerPosition(int index, Offset position) {
    setState(() {
      touchPositions[index] = position;
    });
  }

  void clearPointerPosition(int index) {
    setState(() {
      touchPositions.remove(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double maxWidth = widget.width ?? double.infinity;
    final double maxHeight = widget.height ?? double.infinity;

    final GestureDetector signatureCanvas = GestureDetector(
      onScaleStart: (ScaleStartDetails details) {
        _previousScale = _scale;
        setState(() {});
      },
      onScaleUpdate: (ScaleUpdateDetails details) {
        _scale = _previousScale * details.scale;
        setState(() {});
      },
      onScaleEnd: (ScaleEndDetails details) {
        _previousScale = 1.0;
        setState(() {});
      },
      onVerticalDragUpdate: (DragUpdateDetails details) {
        //NO-OP
      },
      child: Transform(
        transform: Matrix4.diagonal3(Vector3(_scale, _scale, _scale)),
        child: Container(
          decoration: BoxDecoration(color: widget.backgroundColor),
          child: Listener(
            onPointerDown: (PointerDownEvent event) => {
              print(event.pointer),
              //widget.controller.addPoint(Point(event.position,PointType.tap)),
              _addPoint(
                event,
                PointType.tap,
              ),
              savePointerPosition(event.pointer, event.position)
            },
            onPointerUp: (PointerUpEvent event) => {
              _addPoint(
                event,
                PointType.tap,
              ),
              clearPointerPosition(event.pointer)
            },
            onPointerMove: (PointerMoveEvent event) => {
              _addPoint(
                event,
                PointType.move,
              ),
              savePointerPosition(event.pointer, event.position),
            },
            onPointerCancel: (opc) {
              clearPointerPosition(opc.pointer);
            },
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _SignaturePainter(widget.controller, _image),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minWidth: maxWidth,
                      minHeight: maxHeight,
                      maxWidth: maxWidth,
                      maxHeight: maxHeight),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Center(
      child: InteractiveViewer(
        panEnabled: false,
        // Set it to false to prevent panning.
        boundaryMargin: EdgeInsets.all(80),
        minScale: 0.8,
        maxScale: 4,
        child: signatureCanvas,
      ),
    );
  }

  void _addPoint(PointerEvent event, PointType type) {
    print("+++++" + event.toString());
    final Offset o = event.localPosition;
    //SAVE POINT ONLY IF IT IS IN THE SPECIFIED BOUNDARIES
    if ((widget.width == null || o.dx > 0 && o.dx < widget.width) &&
        (widget.height == null || o.dy > 0 && o.dy < widget.height)) {
      // IF USER LEFT THE BOUNDARY AND AND ALSO RETURNED BACK
      // IN ONE MOVE, RETYPE IT AS TAP, AS WE DO NOT WANT TO
      // LINK IT WITH PREVIOUS POINT

      PointType t = type;
      if (_isOutsideDrawField) {
        t = PointType.tap;
      }
      setState(() {
        //IF USER WAS OUTSIDE OF CANVAS WE WILL RESET THE HELPER VARIABLE AS HE HAS RETURNED
        _isOutsideDrawField = false;
        if (touchPositions.length == 1) {
          widget.controller.addPoint(Point(o, t));
        }
      });
    } else {
      //NOTE: USER LEFT THE CANVAS!!! WE WILL SET HELPER VARIABLE
      //WE ARE NOT UPDATING IN setState METHOD BECAUSE WE DO NOT NEED TO RUN BUILD METHOD
      _isOutsideDrawField = true;
    }
  }
}

/// type of user display finger movement
enum PointType {
  /// one touch on specific place - tap
  tap,

  /// finger touching the display and moving around
  move,
}

/// one point on canvas represented by offset and type
class Point {
  /// constructor
  Point(this.offset, this.type);

  /// x and y value on 2D canvas
  Offset offset;

  /// type of user display finger movement
  PointType type;
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter(this._controller, this.image)
      : _penStyle = Paint(),
        super(repaint: _controller) {
    _penStyle
      ..color = _controller.penColor
      ..strokeWidth = _controller.penStrokeWidth;
  }

  final SignatureController _controller;
  final Paint _penStyle;
  final ui.Image image;

  @override
  Future paint(Canvas canvas, Size size) async {
    final List<Point> points = _controller.value;
    if (image != null) {
      canvas.drawImage(image, Offset(0.0, 0.0), Paint());
      canvas.scale(0.3,0.3);
    }

    if (points.isEmpty) {
      return;
    }

    for (int i = 0; i < (points.length - 1); i++) {
      if (points[i + 1].type == PointType.move) {
        canvas.drawLine(
          points[i].offset,
          points[i + 1].offset,
          _penStyle,
        );
      } else {
        canvas.drawCircle(
          points[i].offset,
          _penStyle.strokeWidth / 2,
          _penStyle,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter other) => true;
}

/// class for interaction with signature widget
/// manages points representing signature on canvas
/// provides signature manipulation functions (export, clear)
class SignatureController extends ValueNotifier<List<Point>> {
  /// constructor
  SignatureController(
      {List<Point> points,
      this.penColor = Colors.black,
      this.penStrokeWidth = 3.0,
      this.exportBackgroundColor})
      : super(points ?? <Point>[]);

  /// color of a signature line
  final Color penColor;

  /// boldness of a signature line
  final double penStrokeWidth;

  /// background color to be used in exported png image
  final Color exportBackgroundColor;

  /// getter for points representing signature on 2D canvas
  List<Point> get points => value;

  /// setter for points representing signature on 2D canvas
  set points(List<Point> points) {
    value = points;
  }

  /// add point to point collection
  void addPoint(Point point) {
    value.add(point);
    notifyListeners();
  }

  void removePoint(Point point) {
    value.removeLast();
    notifyListeners();
  }

  /// check if canvas is empty (opposite of isNotEmpty method for convenience)
  bool get isEmpty {
    return value.isEmpty;
  }

  /// check if canvas is not empty (opposite of isEmpty method for convenience)
  bool get isNotEmpty {
    return value.isNotEmpty;
  }

  /// clear the canvas
  void clear() {
    value = <Point>[];
  }

  /// convert to
  Future<ui.Image> toImage() async {
    // if (isEmpty) {
    //   return null;
    // }
    //
    // double minX = double.infinity, minY = double.infinity;
    // double maxX = 0, maxY = 0;
    // for (Point point in points) {
    //   if (point.offset.dx < minX) {
    //     minX = point.offset.dx;
    //   }
    //   if (point.offset.dy < minY) {
    //     minY = point.offset.dy;
    //   }
    //   if (point.offset.dx > maxX) {
    //     maxX = point.offset.dx;
    //   }
    //   if (point.offset.dy > maxY) {
    //     maxY = point.offset.dy;
    //   }
    // }
    //
    // final ui.PictureRecorder recorder = ui.PictureRecorder();
    // final ui.Canvas canvas = Canvas(recorder)
    //
    //   ..translate(-(minX - penStrokeWidth), -(minY - penStrokeWidth));
    // if (exportBackgroundColor != null) {
    //   final ui.Paint paint = Paint()..color = exportBackgroundColor;
    //   canvas.drawPaint(paint);
    // }
    // _SignaturePainter(this).paint(canvas, Size.infinite);
    // final ui.Picture picture = recorder.endRecording();
    // return picture.toImage(
    //   (maxX - minX + penStrokeWidth * 2).toInt(),
    //   (maxY - minY + penStrokeWidth * 2).toInt(),
    // );
  }

  /// convert canvas to dart:ui Image and then to PNG represented in Uint8List
  Future<Uint8List> toPngBytes() async {
    if (!kIsWeb) {
      final ui.Image image = await toImage();
      if (image == null) {
        return null;
      }
      final ByteData bytes = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return bytes?.buffer.asUint8List();
    } else {
      return _toPngBytesForWeb();
    }
  }

  // 'image.toByteData' is not available for web. So we are using the package
  // 'image' to create an image which works on web too
  Uint8List _toPngBytesForWeb() {
    if (isEmpty) {
      return null;
    }
    final int pColor = img.getColor(
      penColor.red,
      penColor.green,
      penColor.blue,
    );

    final Color backgroundColor = exportBackgroundColor ?? Colors.transparent;
    final int bColor = img.getColor(backgroundColor.red, backgroundColor.green,
        backgroundColor.blue, backgroundColor.alpha.toInt());

    double minX = double.infinity;
    double maxX = 0;
    double minY = double.infinity;
    double maxY = 0;

    for (Point point in points) {
      minX = min(point.offset.dx, minX);
      maxX = max(point.offset.dx, maxX);
      minY = min(point.offset.dy, minY);
      maxY = max(point.offset.dy, maxY);
    }

    //point translation
    final List<Point> translatedPoints = <Point>[];
    for (Point point in points) {
      translatedPoints.add(Point(
          Offset(
            point.offset.dx - minX + penStrokeWidth,
            point.offset.dy - minY + penStrokeWidth,
          ),
          point.type));
    }

    final int width = (maxX - minX + penStrokeWidth * 2).toInt();
    final int height = (maxY - minY + penStrokeWidth * 2).toInt();

    // create the image with the given size
    final img.Image signatureImage = img.Image(width, height);
    // set the image background color
    img.fill(signatureImage, bColor);

    // read the drawing points list and draw the image
    // it uses the same logic as the CustomPainter Paint function
    for (int i = 0; i < translatedPoints.length - 1; i++) {
      if (translatedPoints[i + 1].type == PointType.move) {
        img.drawLine(
            signatureImage,
            translatedPoints[i].offset.dx.toInt(),
            translatedPoints[i].offset.dy.toInt(),
            translatedPoints[i + 1].offset.dx.toInt(),
            translatedPoints[i + 1].offset.dy.toInt(),
            pColor,
            thickness: penStrokeWidth);
      } else {
        // draw the point to the image
        img.fillCircle(
          signatureImage,
          translatedPoints[i].offset.dx.toInt(),
          translatedPoints[i].offset.dy.toInt(),
          penStrokeWidth.toInt(),
          pColor,
        );
      }
    }
    // encode the image to PNG
    return Uint8List.fromList(img.encodePng(signatureImage));
  }
}
