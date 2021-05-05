import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/imageeditor/custom_painter.dart';
import 'dart:ui' as ui show Image;
import 'package:vector_math/vector_math_64.dart' show Vector3;

class DrawPainterView extends StatefulWidget {
  final ui.Image file;

  const DrawPainterView({Key key, @required this.file}) : super(key: key);

  @override
  State createState() => _DrawPainterViewState();
}

class _DrawPainterViewState extends State<DrawPainterView> {
  static final List colors = [
    Colors.black,
  ];
  static final List lineWidths = [5.0];

  File imageFile;
  int selectedLine = 0;
  Color selectedColor = colors[0];
  List points = [Point(colors[0], lineWidths[0], [])];
  int curFrame = 0;
  bool isClear = false;

  double width;
  double height;

  final GlobalKey _repaintKey = new GlobalKey();

  double _scale = 1.0;
  double _previousScale = 1.0;

  double _minScale = 1.0;
  double _maxScale = 1.0;

  double mPosX = 0;
  double mPosY = 0;
  double mLastTouchX = 0;
  double mLastTouchY = 0;

  double get strokeWidth => lineWidths[selectedLine];

  Map<int, Offset> touchPositions = <int, Offset>{};

  @override
  void initState() {
    super.initState();
    height = widget.file.height.toDouble();
    width = widget.file.width.toDouble();
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

  final transformationController = TransformationController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Flutter app"),
            centerTitle: true,
          ),
          body: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return Container(
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                alignment: Alignment.center,
                child: FittedBox(
                    child: SizedBox(
                        width: widget.file.width.toDouble(),
                        height: widget.file.height.toDouble(),
                        child: _buildCanvas(widget.file))));
          }),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    reset();
                  });
                },
                tooltip: 'Erease',
                child: Icon(Icons.phonelink_erase),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCanvas(ui.Image file) {
    return StatefulBuilder(builder: (context, state) {
      return Listener(
          onPointerDown: (PointerDownEvent event) {
            print(event.pointer);
            savePointerPosition(event.pointer, event.position);
            isClear = false;
            points[curFrame].color = selectedColor;
            points[curFrame].strokeWidth = strokeWidth;
          },
          onPointerUp: (PointerUpEvent event) {
            clearPointerPosition(event.pointer);
            points.add(Point(selectedColor, strokeWidth, []));
            curFrame++;
          },
          onPointerMove: (PointerMoveEvent event) {
            savePointerPosition(event.pointer, event.position);
            if (touchPositions.length == 1) {
              RenderBox referenceBox = context.findRenderObject();
              Offset localPosition = referenceBox.globalToLocal(event.position);
              if (localPosition.dx > 0 &&
                  localPosition.dy > 0 &&
                  localPosition.dx < width &&
                  localPosition.dy < height) {
                state(() {
                  // print('onPanUpdate' +
                  //     localPosition.toString() +
                  //     "  " +
                  //     curFrame.toString() +
                  //     " " +
                  //     isClear.toString());

                  points[curFrame].points.add(localPosition);
                });
              }
              mLastTouchX = localPosition.dx;
              mLastTouchY = localPosition.dy;
            }
          },
          onPointerCancel: (opc) {
            clearPointerPosition(opc.pointer);
          },
          child: RepaintBoundary(
            child: InteractiveViewer(
              transformationController: transformationController,
              // pass the transformation controller
              onInteractionEnd: (details) {
                setState(() {
                  transformationController.toScene(Offset
                      .zero); // return to normal size after scaling has ended
                });
              },
              minScale: 0.1,
              // min scale
              maxScale: 4.0,
              // max scale
              scaleEnabled: true,
              panEnabled: false,
              boundaryMargin: EdgeInsets.only(left: 4, right: 4, top: 8, bottom: 8),
              child: CustomPaint(
                painter: CustomePainter(
                    points: points,
                    strokeColor: selectedColor,
                    strokeWidth: strokeWidth,
                    isClear: isClear,
                    mScaleFactor: _scale,
                    posPoint: PosPoint(mPosX, mPosY),
                    myBackground: file),
              ),
            ),
          ));
    });
  }

  Widget buildCanvas(ui.Image file) {
    return StatefulBuilder(builder: (context, state) {
      return Listener(
        onPointerDown: (PointerDownEvent event) {
          print(event.pointer);
          savePointerPosition(event.pointer, event.position);
          isClear = false;
          points[curFrame].color = selectedColor;
          points[curFrame].strokeWidth = strokeWidth;
        },
        onPointerUp: (PointerUpEvent event) {
          clearPointerPosition(event.pointer);
          points.add(Point(selectedColor, strokeWidth, []));
          curFrame++;
        },
        onPointerMove: (PointerMoveEvent event) {
          savePointerPosition(event.pointer, event.position);
          if (touchPositions.length == 1) {
            RenderBox referenceBox = context.findRenderObject();
            Offset localPosition = referenceBox.globalToLocal(event.position);
            if (localPosition.dx > 0 &&
                localPosition.dy > 0 &&
                localPosition.dx < width &&
                localPosition.dy < height) {
              state(() {
                // print('onPanUpdate' +
                //     localPosition.toString() +
                //     "  " +
                //     curFrame.toString() +
                //     " " +
                //     isClear.toString());

                points[curFrame].points.add(localPosition);
              });
            }
            mLastTouchX = localPosition.dx;
            mLastTouchY = localPosition.dy;
          }
        },
        onPointerCancel: (opc) {
          clearPointerPosition(opc.pointer);
        },
        child: Transform(
            transform: Matrix4.diagonal3(Vector3(_scale, _scale, 1.0)),
            origin: Offset(width / 2, height / 2),
            alignment: Alignment.center,
            child: RepaintBoundary(
              child: InteractiveViewer(
                transformationController: transformationController,
                // pass the transformation controller
                onInteractionEnd: (details) {
                  setState(() {
                    transformationController.toScene(Offset
                        .zero); // return to normal size after scaling has ended
                  });
                },
                minScale: 0.1,
                // min scale
                maxScale: 4.0,
                // max scale
                scaleEnabled: true,
                panEnabled: true,
                child: CustomPaint(
                  painter: CustomePainter(
                      points: points,
                      strokeColor: selectedColor,
                      strokeWidth: strokeWidth,
                      isClear: isClear,
                      mScaleFactor: _scale,
                      posPoint: PosPoint(mPosX, mPosY),
                      myBackground: file),
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      print("onHorizontalDragUpdate" +
                          details.localPosition.toString());
                    },
                    onDoubleTap: () {
                      _scale = 1.0;
                      mPosX = 0;
                      mPosY = 0;
                      setState(() {});
                    },
                    // onScaleStart: (ScaleStartDetails details) {
                    //     _previousScale = _scale;
                    //     setState(() {});
                    // },
                    // onScaleUpdate: (ScaleUpdateDetails details) {
                    //     _scale = _previousScale * details.scale;
                    //     if (_scale <= _minScale) {
                    //       _scale = _minScale;
                    //     }
                    //     setState(() {});
                    // },
                    // onScaleEnd: (ScaleEndDetails details) {
                    //     _previousScale = 1.0;
                    //     setState(() {});
                    // },
                  ),
                ),
              ),
            )),
      );
    });
  }

  Widget _buildBottom() {
    return Container(
      color: Colors.pink,
      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
      child: StatefulBuilder(builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              child: Text(
                'clear',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                setState(() {
                  reset();
                });
              },
            ),
            GestureDetector(
              child: Text(
                'Image',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {},
            )
          ],
        );
      }),
    );
  }

  void reset() {
    isClear = true;
    curFrame = 0;
    points.clear();
    points.add(Point(selectedColor, strokeWidth, []));
  }
}
