import 'package:confirmly/database/firebase.dart';
import 'package:confirmly/models/Participante.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SearchRa extends StatefulWidget {
  @override
  _SearchRaState createState() => _SearchRaState();
}

class _SearchRaState extends State<SearchRa> {
  TextEditingController controller = new TextEditingController();

  String strDataAtual;
  String dropdownValue;

  final _formKey = GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  var dropItems = [
    DropdownMenuItem(
      value: 'Gratuito',
      child: Text("Gratuito"),
    ),
    DropdownMenuItem(
      value: 'Palestras',
      child: Text("Palestras"),
    ),
    DropdownMenuItem(
      value: 'Minicurso 1',
      child: Text("Minicurso 1"),
    ),
    DropdownMenuItem(
      value: 'Minicurso 1 + Palestras',
      child: Text("Minicurso 1 + Palestras"),
    ),
    DropdownMenuItem(
      value: 'Minicurso 2',
      child: Text("Minicurso 2"),
    ),
    DropdownMenuItem(
      value: 'Minicurso 2 + Palestras',
      child: Text("Minicurso 2 + Palestras"),
    ),
    DropdownMenuItem(
      value: 'Minicurso 3',
      child: Text("Minicurso 3"),
    ),
    DropdownMenuItem(
      value: 'Minicurso 3 + Palestras',
      child: Text("Minicurso 3 + Palestras"),
    ),
    DropdownMenuItem(
      value: 'Minicurso 4',
      child: Text("Minicurso 4"),
    ),
    DropdownMenuItem(
      value: 'Minicurso 4 + Palestras',
      child: Text("Minicurso 4 + Palestras"),
    ),
    DropdownMenuItem(
      value: 'Minicurso 5',
      child: Text("Minicurso 5"),
    ),
    DropdownMenuItem(
      value: 'Minicurso 5 + Palestras',
      child: Text("Minicurso 5 + Palestras"),
    ),
  ];

  //variáveis de controle
  bool read = false;
  bool exists = false;
  bool checkin = false;
  bool checkout = false;
  bool loading = false;

  String dia, mes;
  insereRa(String ra) async {
    Participante p = await getDadosByRa(ra, dropdownValue);
    //print("teste de participante by ra: "+ p.getName);
    p.setTicketName = dropdownValue;
    var v = await getDadosCheckinByRa(p, strDataAtual);
    if (v[3]) {
      if (v[1]) {
        print("já fez check in");
        setState(() {
          checkin = true;
          exists = true;
        });
      } else {
        print("N fez check in");
        setState(() {
          checkin = false;
          exists = true;
        });
      }

      if (v[2]) {
        print("Já fez check out");
        setState(() {
          checkout = true;
          exists = true;
        });
      } else {
        print("N fez check out");
        setState(() {
          checkout = false;
          exists = true;
        });
      }
    } else {
      print("registro não existe");
      setState(() {
        checkin = false;
        checkout = false;
        exists = false;
      });
    }
    showModalInfos(p);
    print(ra);
  }

  validaForm(){
    if (_formKey.currentState.validate()) {
      return true;
    }else{
      return false;
    }
  }

  Future<void> showModalInfos(Participante participante) async {
    setState(() {
      loading = false;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          backgroundColor: Theme.of(context).primaryColor,
          title: participante.getId != 0
              ? Text(
                  'Aluno encontrado!',
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
                  child: Text(
                    "RA inválido ou problemas na conexão com o "
                    "servidor.",
                    style: TextStyle(color: Colors.white),
                  ),
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
                                  setCheckoutByRa(participante, strDataAtual);
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
                                  setCheckinByRa(participante, strDataAtual);
                                  setState(() {
                                    exists = false;
                                  });
                                  Navigator.popUntil(
                                      context,
                                      ModalRoute.withName(
                                          Navigator.defaultRouteName));
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
                      setState(() {
                        loading = false;
                      });
                    },
                  ),
                ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DateTime now = DateTime.now();
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
    dropdownValue = dropItems[0].value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).hintColor,
      appBar: AppBar(
        title: Text("Cadastrar aluno por RA"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Card(
              color: Theme.of(context).primaryColor,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text("Tipo do ingresso: "),
                  ),
                  new Theme(
                    data: Theme.of(context).copyWith(
                        canvasColor: Theme.of(context).primaryColor
                    ),
                    child: DropdownButton<String>(
                      style: TextStyle(inherit: true),
                      iconEnabledColor: Colors.white,
                      value: dropdownValue,
                      items: dropItems,
                      onChanged: (value){
                        setState(() {
                          dropdownValue = value;
                        });
                      },
                    ),// Your Dropdown Code Here,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text("RA: "),
                  ),
                  Form(
                    key: _formKey,
                    child: Container(
                      width: 100,
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Ex: 1930672',
                          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70)
                          ),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70)
                          ),
                        ),
                        validator: (val){
                          if(val.isEmpty){
                            return 'Inválido';
                          }
                          return null;
                        },
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                        controller: controller,
                        keyboardType: TextInputType.number,
                        onFieldSubmitted: (term) {
                          var ret = validaForm();
                          if(ret){
                            setState(() {
                              loading = true;
                            });
                            insereRa(controller.text);
                          }
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RaisedButton(
                      color: Theme.of(context).accentColor,
                      child: Text("OK", style: TextStyle(color: Colors.white),),
                      onPressed: () async {
                        var ret = validaForm();
                        if(ret){
                          setState(() {
                            loading = true;
                          });
                          insereRa(controller.text);
                        }
                      },
                    ),
                  ),
                  loading
                      ? Center(
                    child: LinearProgressIndicator(
                      backgroundColor: Theme.of(context).accentColor,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.red,
                      ),
                    ),
                  )
                      : Container(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
