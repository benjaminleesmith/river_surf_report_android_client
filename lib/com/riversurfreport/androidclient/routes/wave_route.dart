import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:river_surf_report_client/com/riversurfreport/androidclient/widgets/progress_with_text_widget.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/widgets/report_widget.dart';
import 'package:river_surf_report_client/com/riversurfreport/api/models/report.dart';
import 'package:river_surf_report_client/com/riversurfreport/api/models/reports.dart';
import 'package:river_surf_report_client/com/riversurfreport/api/models/wave.dart';
import 'package:river_surf_report_client/com/riversurfreport/api/models/wave_link.dart';

class WaveRouteState extends State<WaveRoute> {
  static Color greenTextColor = const Color.fromRGBO(0, 255, 41, 1.0);
  TextStyle waveNameStyle = GoogleFonts.vT323(fontSize: 20,
      height: 2,
      decoration: TextDecoration.underline,
      color: greenTextColor);
  TextStyle flowStyle = GoogleFonts.vT323(
      fontSize: 20, height: 2, color: greenTextColor);

  WaveLink wave;

  Future<Wave> futureWave;
  Future<Reports> futureReports;

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
                    futureReports = fetchReports(snapshot.data.reportsUrl);
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

                  return ProgressWithTextWidget(text: "loading wave info");
                }))
    );
  }

  Future<Wave> fetchWave(String waveUrl) async {
    final response =
    await http.get(waveUrl);

    if (response.statusCode == 200) {
      return Wave.fromJson(json.decode(response.body)['wave']);
    } else {
      throw Exception('Failed to load reports');
    }
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
    return ReportWidget(report: report, context: context, waveNameStyle: waveNameStyle, flowStyle: flowStyle, width: width);
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