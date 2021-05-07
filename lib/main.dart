// import 'package:flutter/material.dart';
// import 'dart:io';
//
// import 'package:flutter_app/image_editor_pro.dart';
// import 'package:zoom_widget/zoom_widget.dart';
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key key, this.title}) : super(key: key);
//   final String title;
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   File _image;
//
//   Future<void> getimageditor() =>
//       Navigator.push(context, MaterialPageRoute(builder: (context) {
//         return ImageEditorPro(
//           appBarColor: Colors.blue,
//           bottomBarColor: Colors.blue,
//         );
//       })).then((geteditimage) {
//         if (geteditimage != null) {
//           setState(() {
//             _image = geteditimage;
//           });
//         }
//       }).catchError((er) {
//         print(er);
//       });
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body:Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: (){getimageditor();},
//         tooltip: 'Increment',
//         child: Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app/imageeditor/draw_painter_view.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui' as ui show Image;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'imageeditor/custom_painter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;

  var width = 300;
  var height = 300;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<ui.Image> loadUiImage(File file) async {
    final Uint8List bytes = await file.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.Image image = (await codec.getNextFrame()).image;
    return image;
  }

  Future<void> getimageditor(ui.Image imageResource) =>
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return DrawPainterView(file: imageResource, imageFile: _image,);
      })).then((geteditimage) {
        if (geteditimage != null) {
          setState(() {
            _image = geteditimage;
          });
        }
      }).catchError((er) {
        print(er);
      });

  @override
  Widget build(BuildContext conte) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: Container(
              width: width.toDouble(),
              height: height.toDouble(),
              child: _image != null
                  ? Image.file(
                      _image,
                      height: height.toDouble(),
                      width: width.toDouble(),
                      fit: BoxFit.fitWidth,
                    )
                  : Container())),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              bottomsheets();
            },
            tooltip: 'Increment',
            child: Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: () async {
              if(_image !=null) {
                var image = await loadUiImage(_image);
                getimageditor(image);
              } else {
                _showToast(conte);
              }
            },
            tooltip: 'Increment',
            child: Icon(Icons.arrow_right),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _showToast(BuildContext context) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Please select image"),
    ));
  }

  final picker = ImagePicker();

  void bottomsheets() {
    setState(() {});
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(blurRadius: 10.9, color: Colors.grey[400])
          ]),
          height: 170,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('Select Image Options'),
              ),
              Divider(
                height: 1,
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: InkWell(
                        onTap: () {},
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              IconButton(
                                  icon: Icon(Icons.photo_library),
                                  onPressed: () async {
                                    var image = await picker.getImage(
                                        source: ImageSource.gallery);
                                    var decodedImage =
                                        await decodeImageFromList(
                                            File(image.path).readAsBytesSync());

                                    setState(() {
                                      height = decodedImage.height;
                                      width = decodedImage.width;
                                      _image = File(image.path);
                                    });
                                    Navigator.pop(context);
                                  }),
                              SizedBox(width: 10),
                              Text('Open Gallery')
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 24),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            IconButton(
                                icon: Icon(Icons.camera_alt),
                                onPressed: () async {
                                  var image = await picker.getImage(
                                      source: ImageSource.camera);
                                  var decodedImage = await decodeImageFromList(
                                      File(image.path).readAsBytesSync());

                                  setState(() {
                                    height = decodedImage.height;
                                    width = decodedImage.width;
                                    _image = File(image.path);
                                  });
                                  Navigator.pop(context);
                                }),
                            SizedBox(width: 10),
                            Text('Open Camera')
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

// import 'package:flutter/material.dart';
// class _GesturePainter extends CustomPainter {
//   const _GesturePainter({
//     @required this.zoom,
//     @required this.offset,
//     @required this.swatch,
//     @required this.forward,
//     @required this.scaleEnabled,
//     @required this.tapEnabled,
//     @required this.doubleTapEnabled,
//     @required this.longPressEnabled,
//   });
//   final double zoom;
//   final Offset offset;
//   final MaterialColor swatch;
//   final bool forward;
//   final bool scaleEnabled;
//   final bool tapEnabled;
//   final bool doubleTapEnabled;
//   final bool longPressEnabled;
//   @override
//   void paint(Canvas canvas, Size size) {
//     final Offset center = size.center(Offset.zero) * zoom + offset;
//     final double radius = size.width / 2.0 * zoom;
//     final Gradient gradient = RadialGradient(
//       colors: forward
//           ? <Color>[swatch.shade50, swatch.shade900]
//           : <Color>[swatch.shade900, swatch.shade50],
//     );
//     final Paint paint = Paint()
//       ..shader = gradient.createShader(Rect.fromCircle(
//         center: center,
//         radius: radius,
//       ));
//     canvas.drawCircle(center, radius, paint);
//   }
//   @override
//   bool shouldRepaint(_GesturePainter oldPainter) {
//     return oldPainter.zoom != zoom
//         || oldPainter.offset != offset
//         || oldPainter.swatch != swatch
//         || oldPainter.forward != forward
//         || oldPainter.scaleEnabled != scaleEnabled
//         || oldPainter.tapEnabled != tapEnabled
//         || oldPainter.doubleTapEnabled != doubleTapEnabled
//         || oldPainter.longPressEnabled != longPressEnabled;
//   }
// }
// class GestureDemo extends StatefulWidget {
//   const GestureDemo({Key key}) : super(key: key);
//   @override
//   GestureDemoState createState() => GestureDemoState();
// }
// class GestureDemoState extends State<GestureDemo> {
//   Offset _startingFocalPoint;
//   Offset _previousOffset;
//   Offset _offset = Offset.zero;
//   double _previousZoom;
//   double _zoom = 1.0;
//   static const List<MaterialColor> kSwatches = <MaterialColor>[
//     Colors.red,
//     Colors.pink,
//     Colors.purple,
//     Colors.deepPurple,
//     Colors.indigo,
//     Colors.blue,
//     Colors.lightBlue,
//     Colors.cyan,
//     Colors.green,
//     Colors.lightGreen,
//     Colors.lime,
//     Colors.yellow,
//     Colors.amber,
//     Colors.orange,
//     Colors.deepOrange,
//     Colors.brown,
//     Colors.grey,
//     Colors.blueGrey,
//   ];
//   int _swatchIndex = 0;
//   MaterialColor _swatch = kSwatches.first;
//   MaterialColor get swatch => _swatch;
//   bool _forward = true;
//   bool _scaleEnabled = true;
//   bool _tapEnabled = true;
//   bool _doubleTapEnabled = true;
//   bool _longPressEnabled = true;
//   void _handleScaleStart(ScaleStartDetails details) {
//     setState(() {
//       _startingFocalPoint = details.focalPoint;
//       _previousOffset = _offset;
//       _previousZoom = _zoom;
//     });
//   }
//   void _handleScaleUpdate(ScaleUpdateDetails details) {
//     setState(() {
//       _zoom = _previousZoom * details.scale;
//       // Ensure that item under the focal point stays in the same place despite zooming
//       final Offset normalizedOffset = (_startingFocalPoint - _previousOffset) / _previousZoom;
//       _offset = details.focalPoint - normalizedOffset * _zoom;
//     });
//   }
//   void _handleScaleReset() {
//     setState(() {
//       _zoom = 1.0;
//       _offset = Offset.zero;
//     });
//   }
//   void _handleColorChange() {
//     setState(() {
//       _swatchIndex += 1;
//       if (_swatchIndex == kSwatches.length)
//         _swatchIndex = 0;
//       _swatch = kSwatches[_swatchIndex];
//     });
//   }
//   void _handleDirectionChange() {
//     setState(() {
//       _forward = !_forward;
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       fit: StackFit.expand,
//       children: <Widget>[
//         GestureDetector(
//           onScaleStart: _scaleEnabled ? _handleScaleStart : null,
//           onScaleUpdate: _scaleEnabled ? _handleScaleUpdate : null,
//           onTap: _tapEnabled ? _handleColorChange : null,
//           onDoubleTap: _doubleTapEnabled ? _handleScaleReset : null,
//           onLongPress: _longPressEnabled ? _handleDirectionChange : null,
//           child: CustomPaint(
//             painter: _GesturePainter(
//               zoom: _zoom,
//               offset: _offset,
//               swatch: swatch,
//               forward: _forward,
//               scaleEnabled: _scaleEnabled,
//               tapEnabled: _tapEnabled,
//               doubleTapEnabled: _doubleTapEnabled,
//               longPressEnabled: _longPressEnabled,
//             ),
//           ),
//         ),
//         Positioned(
//           bottom: 0.0,
//           left: 0.0,
//           child: Card(
//             child: Container(
//               padding: const EdgeInsets.all(4.0),
//               child: Column(
//                 children: <Widget>[
//                   Row(
//                     children: <Widget>[
//                       Checkbox(
//                         value: _scaleEnabled,
//                         onChanged: (bool value) { setState(() { _scaleEnabled = value; }); },
//                       ),
//                       const Text('Scale'),
//                     ],
//                   ),
//                   Row(
//                     children: <Widget>[
//                       Checkbox(
//                         value: _tapEnabled,
//                         onChanged: (bool value) { setState(() { _tapEnabled = value; }); },
//                       ),
//                       const Text('Tap'),
//                     ],
//                   ),
//                   Row(
//                     children: <Widget>[
//                       Checkbox(
//                         value: _doubleTapEnabled,
//                         onChanged: (bool value) { setState(() { _doubleTapEnabled = value; }); },
//                       ),
//                       const Text('Double Tap'),
//                     ],
//                   ),
//                   Row(
//                     children: <Widget>[
//                       Checkbox(
//                         value: _longPressEnabled,
//                         onChanged: (bool value) { setState(() { _longPressEnabled = value; }); },
//                       ),
//                       const Text('Long Press'),
//                     ],
//                   ),
//                 ],
//                 crossAxisAlignment: CrossAxisAlignment.start,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
// void main() {
//   runApp(MaterialApp(
//     theme: ThemeData.dark(),
//     home: Scaffold(
//       appBar: AppBar(title: const Text('Gestures Demo')),
//       body: const GestureDemo(),
//     ),
//   ));
// }