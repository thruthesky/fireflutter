class AddressModel {
  final int rnum;
  final String code;
  final String name;

  AddressModel({
    required this.rnum,
    required this.code,
    required this.name,
  });

  factory AddressModel.fromJson(Map<dynamic, dynamic> json) {
    return AddressModel(
      rnum: json['rnum'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rnum': rnum,
      'code': code,
      'name': name,
    };
  }

  @override
  toString() {
    return toJson().toString();
  }
}
