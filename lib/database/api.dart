import 'dart:convert';

import 'package:confirmly/models/Participante.dart';
import 'package:http/http.dart' as http;

getDadosParticipante(var value) async {
  try{
    var url =
        'https://api.sympla.com.br/public/v3/events/584385/participants?ticket_number=${value[0]}${value[1]}${value[2]}${value[3]}-${value[4]}${value[5]}-${value[6]}${value[7]}${value[8]}${value[9]}';
    print(url);
    var header = {
      's_token':
      '51ab4f1a5d8d961d33cccfb3d5cc0dfc856411818db14eb1d7ad8578583e8ab3'
    };

    var res = await http.get(url, headers: header);

    var json = jsonDecode(res.body);

    var statusCode = res.statusCode;

    //print(participante.toString());
    if(statusCode != 200){
      return new Participante(0, "Não foi possível encontrar!", "", "", "", "",
          "");
    } else{
      var participante = Participante(
          json['data'][0]['id'],
          json['data'][0]['first_name'] + ' ' + json['data'][0]['last_name'],
          json['data'][0]['ticket_number'],
          json['data'][0]['ticket_sale_price'],
          json['data'][0]['ticket_name'],
          json['data'][0]['email'],
          json['data'][0]['custom_form'][1]['value']);

      return participante;
    }
  }catch(e){
    return new Participante(0, "Não foi possível encontrar!", "", "", "", "", "");
  }

}
