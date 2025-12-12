class Address {
  final String id;
  final String street;
  final String number;
  final String district;
  final String city;
  final String state;
  final String zipcode;

  Address({
    this.id = '',
    required this.street,
    required this.number,
    required this.district,
    required this.city,
    required this.state,
    required this.zipcode,
  });

  Address copyWith({
    String? id,
    String? street,
    String? number,
    String? district,
    String? city,
    String? state,
    String? zipcode,
  }) {
    return Address(
      id: id ?? this.id,
      street: street ?? this.street,
      number: number ?? this.number,
      district: district ?? this.district,
      city: city ?? this.city,
      state: state ?? this.state,
      zipcode: zipcode ?? this.zipcode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "street": street,
      "number": number,
      "district": district,
      "city": city,
      "state": state,
      "zipcode": zipcode,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map, String id) {
    return Address(
      id: id,
      street: map["street"] ?? "",
      number: map["number"] ?? "",
      district: map["district"] ?? "",
      city: map["city"] ?? "",
      state: map["state"] ?? "",
      zipcode: map["zipcode"] ?? "",
    );
  }

  @override
  String toString() {
    return "$street, Nº $number\n$district - $city/$state";
  }
}
