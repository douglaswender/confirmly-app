class Participante {
  // ignore: non_constant_identifier_names
  var _id, _name, _ticket_number, _ticket_sale_price, _ticket_name, _email, _ra,
      _checkin, _checkout;

  Participante(this._id, this._name, this._ticket_number, this
      ._ticket_sale_price,
      this._ticket_name, this._email, this._ra);

  get getName => _name;

  set setName(value) {
    _name = value;
  }

  @override
  String toString() {
    return 'Participante{name: $_name, ticket_number: $_ticket_number, ticket_sale_price: $_ticket_sale_price, ticket_name: $_ticket_name, email: $_email, ra: $_ra}';
  }

  get getId => _id;

  set setId(value) {
    _id = value;
  }

  get getTicketNumber => _ticket_number;

  set setTicketNumber(value) {
    _ticket_number = value;
  }

  get getTicketSalePrice => _ticket_sale_price;

  set setTicketSalePrice(value) {
    _ticket_sale_price = value;
  }

  get getTicketName => _ticket_name;

  set setTicketName(value) {
    _ticket_name = value;
  }

  get getEmail => _email;

  set setEmail(value) {
    _email = value;
  }

  get getRa => _ra;

  set setRa(value) {
    _ra = value;
  }

  get getCheckin => _checkin;

  set setCheckin(value) {
    _checkin = value;
  }

  get getCheckout => _checkout;

  set setCheckout(value) {
    _checkout = value;
  }
}
