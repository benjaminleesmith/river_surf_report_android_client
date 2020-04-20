import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:river_surf_report_client/com/riversurfreport/androidclient/widgets/load_more_widget.dart';
import 'dart:convert';

import 'package:river_surf_report_client/com/riversurfreport/androidclient/widgets/progress_with_text_widget.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/widgets/report_widget.dart';
import 'package:river_surf_report_client/com/riversurfreport/api/models/report.dart';
import 'package:river_surf_report_client/com/riversurfreport/api/models/reports.dart';
import 'package:river_surf_report_client/com/riversurfreport/api/models/wave.dart';
import 'package:river_surf_report_client/com/riversurfreport/api/models/wave_link.dart';

class WaveRouteState extends State<WaveRoute> {
  WaveLink wave;

  Future<Wave> futureWave;
  Future<Reports> futureReports;
  List<Report> reports = [];
  String moreReportsUrl;
  GlobalKey globalKey = GlobalKey();

  WaveRouteState(WaveLink wave) {
    this.wave = wave;
  }

  @override
  void initState() {
    super.initState();
    futureWave = fetchWave(wave.url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(wave.name),
        ),
        body: Center(
            child: FutureBuilder<Wave>(
                future: futureWave,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (futureReports == null) {
                      futureReports = fetchReports(snapshot.data.reportsUrl);
                      return FutureBuilder<Reports>(
                          future: futureReports,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              reports = snapshot.data.reports;
                              moreReportsUrl = snapshot.data.moreReportsUrl;
                              return _buildReports();
                            } else if (snapshot.hasError) {
                              return Text("${snapshot.error}");
                            }

                            return ProgressWithTextWidget(
                                text: "fetching recent reports");
                          });
                    } else {
                      return _buildReports();
                    }
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }

                  return ProgressWithTextWidget(text: "loading wave info");
                })));
  }

  Future<Wave> fetchWave(String waveUrl) async {
    final response = await http.get(waveUrl);

    if (response.statusCode == 200) {
      return Wave.fromJson(json.decode(response.body)['wave']);
    } else {
      throw Exception('Failed to load reports');
    }
  }

  Future<Reports> fetchReports(String recentReportsUrl) async {
    final response = await http.get(recentReportsUrl);

    if (response.statusCode == 200) {
      return Reports.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load reports');
    }
  }

  Widget _buildReports() {
    var width = MediaQuery.of(context).size.width;
    return ListView.builder(
        itemCount: reports.length + 1,
        itemBuilder: (context, i) {
          if (i < reports.length) {
            return _buildReport(reports[i], width);
          } else {
            return new GestureDetector(
                onTap: () {
                  Future<Reports> futureMoreReports =
                      _fetchMoreReports(moreReportsUrl);
                  futureMoreReports.then((moreReports) {
                    setState(() {
                      this.moreReportsUrl = moreReports.moreReportsUrl;
                      this.reports = reports + moreReports.reports;
                    });
                  });
                },
                child: LoadMore());
          }
        },
        key: globalKey);
  }

  Future<Reports> _fetchMoreReports(String moreReportsUrl) async {
    final response = await http.get(moreReportsUrl);

    if (response.statusCode == 200) {
      return Reports.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load more reports');
    }
  }

  Widget _buildReport(Report report, var width) {
    return ReportWidget(
        report: report, context: context, width: width, waveLink: false);
  }
}

class WaveRoute extends StatefulWidget {
  WaveLink wave;

  WaveRoute(WaveLink wave) {
    this.wave = wave;
  }

  @override
  WaveRouteState createState() => WaveRouteState(this.wave);
}
