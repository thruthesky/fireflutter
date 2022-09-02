class AddressSearchModel {
  int totalCount = 0;
  String errorCode;
  List<AddressModel> addresses = [];
  AddressSearchModel({
    required this.totalCount,
    required this.errorCode,
    required this.addresses,
  });

  factory AddressSearchModel.fromJson(Map<String, dynamic> json) {
    return AddressSearchModel(
      totalCount: int.tryParse(json['results']['common']['totalCount']) ?? 0,
      errorCode: json['results']['common']['errorCode'],
      addresses: ((json['results']['juso'] ?? []) as List)
          .map((e) => AddressModel.fromMap(e))
          .toList(),
    );
  }
}

class AddressModel {
  /// 우편번호
  String zipNo;

  /// 읍면동
  String emdNm;
  String rn;
  String jibunAddr;

  /// 영문 시,도 명
  String siNm;

  /// 영문 시,군,구 명.
  /// 주의: 공백을 구분으로 "Gwonseon-gu, Suwon-si" (수원시 권선구) 와 같이 들어갈 수 있는데, 공백이 있으면 뒷 부분(시)만 저장한다.
  String sggNm;

  ///
  String admCd;
  String udrtYn;
  String lnbrMnnm;

  /// 영문 도로명 주소
  String roadAddr;

  /// 한글 도로명 주소
  String korAddr;
  String lnbrSlno;
  String buldMnnm;
  String bdKdcd;
  String rnMgtSn;
  String liNm;
  String mtYn;
  String buldSlno;
  AddressModel({
    required this.zipNo,
    required this.emdNm,
    required this.rn,
    required this.jibunAddr,
    required this.siNm,
    required this.sggNm,
    required this.admCd,
    required this.udrtYn,
    required this.lnbrMnnm,
    required this.roadAddr,
    required this.korAddr,
    required this.lnbrSlno,
    required this.buldMnnm,
    required this.bdKdcd,
    required this.rnMgtSn,
    required this.liNm,
    required this.mtYn,
    required this.buldSlno,
  });

  factory AddressModel.fromMap(Map<String, dynamic> json) {
    return AddressModel(
      zipNo: json['zipNo'] ?? '',
      emdNm: json['emdNm'] ?? '',
      rn: json['rn'] ?? '',
      jibunAddr: json['jibunAddr'] ?? '',
      siNm: json['siNm'] ?? '',
      sggNm: ((json['sggNm'] ?? '') as String).split(' ').last,
      admCd: json['admCd'] ?? '',
      udrtYn: json['udrtYn'] ?? '',
      lnbrMnnm: json['lnbrMnnm'] ?? '',
      roadAddr: json['roadAddr'] ?? '',
      korAddr: json['korAddr'] ?? '',
      lnbrSlno: json['lnbrSlno'] ?? '',
      buldMnnm: json['buldMnnm'] ?? '',
      bdKdcd: json['bdKdcd'] ?? '',
      rnMgtSn: json['rnMgtSn'] ?? '',
      liNm: json['liNm'] ?? '',
      mtYn: json['mtYn'] ?? '',
      buldSlno: json['buldSlno'] ?? '',
    );
  }
  @override
  String toString() {
    return '''AddressModel(
'zipNo': $zipNo,
'emdNm': $emdNm,
'rn': $rn,
'jibunAddr': $jibunAddr,
'siNm': $siNm,
'sggNm': $sggNm,
'admCd': $admCd,
'udrtYn': $udrtYn,
'lnbrMnnm': $lnbrMnnm,
'roadAddr': $roadAddr,
'korAddr': $korAddr,
'lnbrSlno': $lnbrSlno,
'buldMnnm': $buldMnnm,
'bdKdcd': $bdKdcd,
'rnMgtSn': $rnMgtSn,
'liNm': $liNm,
'mtYn': $mtYn,
'buldSlno': $buldSlno,
    );''';
  }
}
