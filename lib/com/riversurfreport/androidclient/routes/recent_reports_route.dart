import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:river_surf_report_client/com/riversurfreport/androidclient/widgets/progress_with_text_widget.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/widgets/report_widget.dart';
import 'package:river_surf_report_client/com/riversurfreport/api/models/endpoints.dart';
import 'package:river_surf_report_client/com/riversurfreport/api/models/report.dart';
import 'package:river_surf_report_client/com/riversurfreport/api/models/reports.dart';

class RecentReportsRouteState extends State<RecentReportsRoute> {
  String endpointsUrl;

  Future<Endpoints> futureEndpoints;
  Future<Reports> futureReports;

  RecentReportsRouteState(this.endpointsUrl);

  @override
  void initState() {
    super.initState();
    futureEndpoints = fetchEndpoints(endpointsUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('River Surf Report'),
        ),
        body: Center(
            child: FutureBuilder<Endpoints>(
                future: futureEndpoints,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    futureReports = fetchReports(snapshot.data.recentReportsUrl);
                    return FutureBuilder<Reports>(
                      future: futureReports,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return _buildReports(snapshot.data);
                        } else if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        }

                        return ProgressWithTextWidget(text: "fetching recent reports");
                      }
                    );
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }

                  return ProgressWithTextWidget(text: "connecting to server");
                })));
  }

  Widget _buildReports(reportsFuture) {
    var width = MediaQuery
        .of(context)
        .size
        .width;
    var reports = reportsFuture.reports;
    return ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, i) {
          return _buildReport(reports[i], width);
        });
  }

  Widget _buildReport(Report report, var width) {
    return ReportWidget(report: report, context: context, width: width, waveLink: true);
  }

  Future<Reports> fetchReports(String recentReportsUrl) async {
    final response =
    await http.get(recentReportsUrl);

    if (response.statusCode == 200) {
      return Reports.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load reports');
    }
  }

  Future<Endpoints> fetchEndpoints(String endpointsUrl) async {
    final response =
    await http.get(endpointsUrl);

    if (response.statusCode == 200) {
      return Endpoints.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load reports');
    }
  }
}

class RecentReportsRoute extends StatefulWidget {
  String endpointsUrl;

  RecentReportsRoute(this.endpointsUrl);

  @override
  RecentReportsRouteState createState() => RecentReportsRouteState(endpointsUrl);
}
