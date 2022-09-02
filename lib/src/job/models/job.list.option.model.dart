class JobListOptionModel {
  String companyName = '';
  String siNm = '';
  String sggNm = '';
  String category = '';
  int workingHours = -1;
  int workingDays = -1;
  String accomodation = '';
  String salary = '';

  get toMap {
    return {
      'companyName': companyName,
      'siNm': siNm,
      'sggNm': sggNm,
      'category': category,
      'workingHours': workingHours,
      'workingDays': workingDays,
      'accomodation': accomodation,
      'salary': salary,
    };
  }

  @override
  String toString() {
    return '''JobListOptionModel($toMap)''';
  }
}
