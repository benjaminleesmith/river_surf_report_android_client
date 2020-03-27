import 'dart:convert';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/models/report.dart';
import 'package:http/http.dart' as http;
import 'package:river_surf_report_client/com/riversurfreport/androidclient/models/reports.dart';
import 'package:google_fonts/google_fonts.dart';

class RecentReportsState extends State<RecentReports> {
  Future<Reports> futureReports;
  static Color greenTextColor = const Color.fromRGBO(0, 255, 41, 1.0);
  TextStyle waveNameStyle = GoogleFonts.vT323(fontSize: 20, height: 2, decoration: TextDecoration.underline, color: greenTextColor);
  TextStyle flowStyle = GoogleFonts.vT323(fontSize: 20, height: 2, color: greenTextColor);

  @override
  void initState() {
    super.initState();
    futureReports = fetchReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('River Surf Report'),
        ),
        body: Center(
            child: FutureBuilder<Reports>(
                future: futureReports,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return _buildReports(snapshot.data);
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }

                  return CircularProgressIndicator();
                })));
  }

  Widget _buildReports(reportsFuture) {
    var width = MediaQuery.of(context).size.width;
    var reports = reportsFuture.reports;
    print(reports);
    return ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, i) {
          return _buildReport(reports[i], width);
        });
  }

  Widget _buildReport(Report report, var width) {
    return Column(
      children: <Widget>[
        Container(
          color: Colors.black,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text(report.wave.name, style: waveNameStyle),
                Text(report.flow, style: flowStyle)
              ])
        ),
        Image.network(report.imageUrl, fit: BoxFit.fitWidth, width: width),
        Row(

        )
      ],
    );
  }

  Future<Reports> fetchReports() async {
    final response =
        await http.get('http://riversurfreport.herokuapp.com/api/reports');

    if (response.statusCode == 200) {
      return Reports.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load reports');
    }
  }
}

class RecentReports extends StatefulWidget {
  @override
  RecentReportsState createState() => RecentReportsState();
}
