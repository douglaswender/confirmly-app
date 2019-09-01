import 'package:confirmly/pages/home.dart';
import 'package:confirmly/pages/seachByRa.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:fast_qr_reader_view/fast_qr_reader_view.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

//lista de cameras a serem utilizadas pela aplicação.
List<CameraDescription> cameras;

Future<Null> main() async {
   //Fetch the available cameras before initializing the app.
  try {
    PermissionStatus res = await requestCameraPermission();
    debugPrint("PERMISSION STATUS: _" + res.toString());
    if (res != PermissionStatus.denied &&
        res != PermissionStatus.dismissedForever &&
        res != PermissionStatus.disabled &&
        res != PermissionStatus.unknown) {
      //AVAILABLE CAMERAS...
      cameras = await availableCameras();
    }
  } on QRReaderException catch (e) {
    logError(e.code, e.description);
  }

  runApp(new MyApp());
}

void _portraitModeOnly() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

void initCameras() async{
  // Fetch the available cameras before initializing the app.
  try {
    PermissionStatus res = await requestCameraPermission();
    debugPrint("PERMISSION STATUS: _" + res.toString());
    if (res != PermissionStatus.denied &&
        res != PermissionStatus.dismissedForever &&
        res != PermissionStatus.disabled &&
        res != PermissionStatus.unknown) {
      //AVAILABLE CAMERAS...

      cameras = await availableCameras();
      print(cameras);
    }
  } on QRReaderException catch (e) {
    logError(e.code, e.description);
  }
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    initCameras();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    _portraitModeOnly();
    return new MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFF97070a),
        hintColor: Color(0xFFb65153),
        accentColor: Color(0xFF4b0305),
        disabledColor: Color(0xFFb65153),
        textTheme: TextTheme(
          headline: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold),
          title: TextStyle(fontSize: 20.0, fontStyle: FontStyle.normal),
          subtitle: TextStyle(fontSize: 20.0, fontStyle: FontStyle.normal,
              color: Colors.white) ,
          body1: TextStyle(fontSize: 16.0, color: Colors.white),
          body2: TextStyle(color: Colors.white),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context)=>Home(),
        '/ra': (context)=>SearchRa()
      },
    );
  }
}
