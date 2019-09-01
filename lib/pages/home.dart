import 'package:confirmly/database/api.dart';
import 'package:confirmly/database/firebase.dart';
import 'package:confirmly/models/Participante.dart';
import 'package:confirmly/pages/seachByRa.dart';
import 'package:fast_qr_reader_view/fast_qr_reader_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../main.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  QRReaderController controller;
  AnimationController animationController;
  Animation<double> verticalPosition;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //variáveis utilizáveis:
  Participante participante = new Participante(0, "", "", "", "", "", "");
  String strDataAtual;
  DateTime now;

  String dia, mes;

  //variáveis de controle
  bool read = false;
  bool exists = false;
  bool checkin = false;
  bool checkout = false;

  @override
  void initState() {
    now = DateTime.now();

    if(now.day < 10){
      dia = '0${now.day}';
    }else{
      dia = now.day.toString();
    }

    if(now.month < 10){
      mes = '0${now.month}';
    }else{
      mes = now.month.toString();
    }
    strDataAtual = '$dia$mes${now.year.toString()}';
    super.initState();
    animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 3),
    );
    animationController.addListener(() {
      this.setState(() {});
    });
    animationController.forward();
    verticalPosition = Tween<double>(begin: 0.0, end: 300.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.linear))
      ..addStatusListener((state) {
        if (state == AnimationStatus.completed) {
          animationController.reverse();
        } else if (state == AnimationStatus.dismissed) {
          animationController.forward();
        }
      });
    if (cameras != null) {
      onNewCameraSelected(cameras[0]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).hintColor,
      key: _scaffoldKey,
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(top: 10, left: 10, bottom: 10),
          child: Image.asset('assets/icon/confirmly-beta.png'),
        ),
        title: Text("Confirmly"),
      ),
      endDrawer: Drawer(
        child: Container(
          color: Theme.of(context).hintColor,
          child: ListView(
            children: <Widget>[
              Container(
                height: 100,
                child: UserAccountsDrawerHeader(
                  accountName: Text(
                    "IV SAES",
                    style: TextStyle(fontSize: 18),
                  ),
                  accountEmail: Text(
                    "caes.utfpr@gmail.com",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
              ListTile(
                title: Text("Digitar RA"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, CupertinoPageRoute(
                    builder: (context)=>SearchRa()
                  ));
                },
              ),
              Divider(
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(8.0, 5.0, 8.0, 5.0),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                new Card(
                    child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 10.0, bottom: 10),
                      child: Center(
                          child: Text(
                        "Informe o QRCode do participante",
                        style: Theme.of(context).textTheme.title,
                      )),
                    ),
                    new Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: new Center(
                        child: Container(
                          child: _cameraPreviewWidget(),
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.4,
                        ),
                      ),
                    ),
                  ],
                )),
                Padding(
                  padding: const EdgeInsets.only(top: 33.0),
                  child: Center(
                    child: Stack(
                      children: <Widget>[
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.4,
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.red, width: 2.0)),
                          ),
                        ),
                        Positioned(
                          top: verticalPosition.value,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: 2.0,
                            color: Colors.red,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                read ? CircularProgressIndicator() : Container(),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
            child: Card(
              color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10))),
                margin: EdgeInsets.all(0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 40,
                  alignment: Alignment.center,
                  child: Text(
                    "Leituras realizadas: ",
                    style: Theme.of(context).textTheme.body1, textAlign:
                  TextAlign.center,
                  ),
                )),
          ),
          Expanded(
            child: renderListChecks(),
          ),
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'No camera selected',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return new AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: new QRReaderPreview(controller),
      );
    }
  }

  void onCodeRead(dynamic value) async {
    setState(() {
      read = true;
    });
    //get dados do QRCODE através da API do SYMPLA
    participante = await getDadosParticipante(value);

    //get dados de checkin através do firebase
    var dadosFirebase = await getDadosCheckin(participante, strDataAtual);
    //participante = await getDadosCheckin(participante);
    //showInSnackBar(value.toString() + " : "+participante.toString());
    print(dadosFirebase);
    setState(() {
      read = false;
    });
    if (dadosFirebase[3]) {
      if (dadosFirebase[1]) {
        print("já fez check in");
        setState(() {
          checkin = true;
        });
      } else {
        print("N fez check in");
        setState(() {
          checkin = false;
        });
      }

      if (dadosFirebase[2]) {
        print("Já fez check out");
        setState(() {
          checkout = true;
        });
      } else {
        print("N fez check out");
        setState(() {
          checkout = false;
        });
      }
    } else {
      print("registro não existe");
      setState(() {
        checkin = false;
        checkout = false;
      });
    }

    showModalInfos(participante);
    // ... do something
    // wait 5 seconds then start scanning again.
    new Future.delayed(const Duration(seconds: 3), controller.startScanning);
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = new QRReaderController(cameraDescription, ResolutionPreset.low,
        [CodeFormat.qr, CodeFormat.pdf417], onCodeRead);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on QRReaderException catch (e) {
      logError(e.code, e.description);
      showInSnackBar('Error: ${e.code}\n${e.description}');
    }

    if (mounted) {
      setState(() {});
      controller.startScanning();
    }
  }

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(message),
      duration: Duration(seconds: 3),
    ));
  }

  Future<void> showModalInfos(Participante participante) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          backgroundColor: Theme.of(context).primaryColor,
          title: participante.getId != 0
              ? Text(
                  'Participante encontrado!',
                  style: Theme.of(context).textTheme.subtitle,
                )
              : Text(
                  'Erro! Verifique sua conexão com a internet!',
                  style: Theme.of(context).textTheme.subtitle,
                ),
          content: participante.getId != 0
              ? new Container(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Nome: " + participante.getName,
                          style: Theme.of(context).textTheme.body2,
                        ),
                        Text(
                          "Ingresso: " + participante.getTicketName,
                          style: Theme.of(context).textTheme.body2,
                        ),
                        Text(
                          "RA: " + participante.getRa,
                          style: Theme.of(context).textTheme.body2,
                        ),
                        participante.getCheckin != null
                            ? Text(
                                "Checkin: " +
                                    DateFormat("HH:mm dd/MM/yyyy").format(
                                        participante.getCheckin.toDate()),
                                style: Theme.of(context).textTheme.body2)
                            : Text(
                                "Checkin: Ainda "
                                "não realizado!",
                                style: Theme.of(context).textTheme.body2,
                              ),
                        participante.getCheckout != null
                            ? Text(
                                "Checkout: " +
                                    DateFormat("HH:mm dd/MM/yyyy").format(
                                        participante.getCheckout.toDate()),
                                style: Theme.of(context).textTheme.body2)
                            : Text(
                                "Checkout: "
                                "Ainda "
                                "não realizado!",
                                style: Theme.of(context).textTheme.body2,
                              )
                      ],
                    ),
                  ),
                )
              : Container(
                  height: 100,
                  width: 100,
                ),
          actions: participante.getId != 0
              ? <Widget>[
            checkin && checkout
                ? Text("")
                : checkin
                ? ButtonTheme(
              height: 40,
              minWidth: MediaQuery.of(context).size.width * 0.2,
              child: RaisedButton(
                color: Theme.of(context).accentColor,
                child: Text(
                  "Checkout",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  setCheckout(participante, strDataAtual);
                  setState(() {
                    exists = false;
                  });
                  Navigator.popUntil(
                      context,
                      ModalRoute.withName(
                          Navigator.defaultRouteName));
                },
              ),
            )
                : ButtonTheme(
              height: 40,
              minWidth: MediaQuery.of(context).size.width * 0.2,
              child: RaisedButton(
                color: Theme.of(context).accentColor,
                child: Text(
                  "Checkin",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  setCheckin(participante, strDataAtual);
                  setState(() {
                    exists = false;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ),
            ButtonTheme(
              height: 40,
              minWidth: MediaQuery.of(context).size.width * 0.2,
              child: RaisedButton(
                color: Theme.of(context).accentColor,
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ]
              : <Widget>[
            RaisedButton(
              color: Theme.of(context).accentColor,
              child: Text(
                'Voltar',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');
