
import 'package:river_surf_report_client/com/riversurfreport/api/models/report.dart';

class Reports {
  List<Report> reports;
  String moreReportsUrl;

  Reports({this.reports, this.moreReportsUrl});

  factory Reports.fromJson(Map<String, dynamic> json) {
    var list = json['reports'] as List;
    List<Report> reportsList = list.map((i) => Report.fromJson(i)).toList();

    return Reports(
        reports: reportsList,
        moreReportsUrl: json['moreReportsUrl']
    );
  }
}