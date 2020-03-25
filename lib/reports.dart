import 'package:river_surf_report_client/report.dart';

class Reports {
  List<Report> reports;

  Reports({this.reports});

  factory Reports.fromJson(Map<String, dynamic> json) {
    var list = json['reports'] as List;
    List<Report> reportsList = list.map((i) => Report.fromJson(i)).toList();

    return Reports(
        reports: reportsList
    );
  }
}