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
        return DrawPainterView(file: imageResource);
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
