import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirmly/models/Participante.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


getDadosCheckin(Participante participante, String strDataAtual) async {
  var exists;
  var data;

  print(participante.getTicketNumber + '|' + strDataAtual);
  try {
    await Firestore.instance
        .collection('checks')
        .document(participante.getTicketNumber + '|' + strDataAtual)
        .get()
        .then((ds) {
      exists = ds.exists;
      data = ds.data;
    });

    print("teste: " + exists.toString());
    print(data);

    if (exists) {
      if (data['checkin'] == null) {
        return [participante, false, false, true];
      } else {
        if (data['checkout'] != null) {
          participante.setCheckin = data['checkin'];
          participante.setCheckout = data['checkout'];
          return [participante, true, true, true];
        } else {
          participante.setCheckin = data['checkin'];
          return [participante, true, false, true];
        }
      }
    } else {
      return [participante, false, false, false];
    }
  } catch (e) {
    participante.setId = 0;
    return [participante, false, false, false];
  }
}

setCheckin(Participante participante, String strDataAtual) {
  try {
    Firestore.instance
        .collection('checks')
        .document(participante.getTicketNumber + '|' + strDataAtual)
        .setData({
      'name': participante.getName,
      'ticket_number': participante.getTicketNumber,
      'ticket_name': participante.getTicketName,
      'ticket_sale_price': participante.getTicketSalePrice,
      'email': participante.getEmail,
      'ra': participante.getRa,
      'checkin': DateTime.now(),
      'updated': DateTime.now(),
    });
  } catch (e) {}
}

setCheckout(Participante participante, String strDataAtual) {
  try {
    Firestore.instance
        .collection('checks')
        .document(participante.getTicketNumber + '|' + strDataAtual)
        .setData({
      'name': participante.getName,
      'ticket_number': participante.getTicketNumber,
      'ticket_name': participante.getTicketName,
      'ticket_sale_price': participante.getTicketSalePrice,
      'email': participante.getEmail,
      'ra': participante.getRa,
      'checkin': participante.getCheckin,
      'checkout': DateTime.now(),
      'updated': DateTime.now(),
    });
  } catch (e) {}
}

getDadosCheckinByRa(Participante participante, String strDataAtual) async{
  var exists;
  var data;

  print(participante.getRa + '|' + strDataAtual);
  try {
    await Firestore.instance
        .collection('checks')
        .document(participante.getRa + '|' + strDataAtual)
        .get()
        .then((ds) {
      exists = ds.exists;
      data = ds.data;
    });

    print("teste: " + exists.toString());
    print(data);

    if (exists) {
      if (data['checkin'] == null) {
        return [participante, false, false, true];
      } else {
        if (data['checkout'] != null) {
          participante.setCheckin = data['checkin'];
          participante.setCheckout = data['checkout'];
          participante.setTicketName = data['ticket_name'];
          return [participante, true, true, true];
        } else {
          participante.setCheckin = data['checkin'];
          participante.setTicketName = data['ticket_name'];
          return [participante, true, false, true];
        }
      }
    } else {
      return [participante, false, false, false];
    }
  } catch (e) {
    participante.setId = 0;
    return [participante, false, false, false];
  }
}
getDadosByRa(String ra, String dropDownVal) async{
  Participante p;
  try{
    await Firestore.instance.collection('alunos').document(ra).get().then((ds){
      p = new Participante("", ds["nome"], "", "", dropDownVal,
          ds["email"], ds["ra"]);
    });
    //print(p.getEmail);
  } catch(e){
    return new Participante(0, "Não foi possível encontrar!", "", "", "", "", "");
  }
  return p;
}

setCheckinByRa(Participante participante, String strDataAtual) {
  try {
    Firestore.instance
        .collection('checks')
        .document(participante.getRa + '|' + strDataAtual)
        .setData({
      'name': participante.getName,
      'ticket_number': participante.getTicketNumber,
      'ticket_name': participante.getTicketName,
      'ticket_sale_price': participante.getTicketSalePrice,
      'email': participante.getEmail,
      'ra': participante.getRa,
      'checkin': DateTime.now(),
      'updated': DateTime.now(),
    });
  } catch (e) {}
}

setCheckoutByRa(Participante participante, String strDataAtual) {
  try {
    Firestore.instance
        .collection('checks')
        .document(participante.getRa + '|' + strDataAtual)
        .setData({
      'name': participante.getName,
      'ticket_number': participante.getTicketNumber,
      'ticket_name': participante.getTicketName,
      'ticket_sale_price': participante.getTicketSalePrice,
      'email': participante.getEmail,
      'ra': participante.getRa,
      'checkin': participante.getCheckin,
      'checkout': DateTime.now(),
      'updated': DateTime.now(),
    });
  } catch (e) {}
}

renderListChecks() {
  return StreamBuilder(
    stream: Firestore.instance.collection('checks').limit(3).orderBy('updated', descending: true).snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const Text('Conectando...');
      if(snapshot.hasError) return Text("Algo inexperado ocorreu!");
      return Padding(
        padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 5),
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10)
                  , bottomRight: Radius.circular(10))
          ),
          margin: EdgeInsets.only(top: 0),
          color: Theme.of(context).primaryColor,
          child: ListView.builder(
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
                _buildListItem(context, snapshot.data.documents[index]),
          ),
        ),
      );
    },
  );
}

_buildListItem(BuildContext context, DocumentSnapshot document) {
  return Card(
    child: ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(document['name']),
          document['checkout'] == null ? Text(DateFormat('HH:mm dd/MM/yyyy').format
            (document['checkin'].toDate())) :
          Text(DateFormat('HH:mm dd/MM/yyyy').format
            (document['checkout'].toDate()))
        ],
      ),
      subtitle: Text(document['ticket_name']),
      leading: document['checkout'] == null ? Image.asset('assets/icon/checkin'
          '.png'):Image.asset('assets/icon/checkout.png')
    ),
  );
}
