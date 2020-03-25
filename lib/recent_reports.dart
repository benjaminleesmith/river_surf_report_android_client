import 'dart:convert';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:river_surf_report_client/report.dart';
import 'package:http/http.dart' as http;
import 'package:river_surf_report_client/reports.dart';

class RecentReportsState extends State<RecentReports> {
  var _reports;
  Future<Reports> futureReports;
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  void initState() {
    super.initState();
    futureReports = fetchReports();
  }



  @override
  Widget build(BuildContext context) {
//    _reports.addAll(generateWordPairs().take(10));
    _reports = fetchReports();
    return Scaffold(
      appBar: AppBar(
        title: Text('River Surf Report'),
      ),
      body: Center(
        child: FutureBuilder<Reports> (
          future: _reports,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _buildReports(snapshot.data);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            // By default, show a loading spinner.
            return CircularProgressIndicator();
          }
        )
      )
    );
  }

  Widget _buildReports(reportsFuture) {
    var width = MediaQuery.of(context).size.width;
    var reports = reportsFuture.reports;
    print(reports);
    return ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, i) {
          return _buildRow(reports[i], width);
        });
  }

  Widget _buildRow(Report report, var width) {
    return Row(
        children: <Widget>[
          Image.network(
            report.imageUrl,
            fit: BoxFit.fitWidth,
            width: width,
          )
        ],
    );
  }

  Future<Reports> fetchReports() async {
    final response = await http.get('http://riversurfreport.herokuapp.com/api/reports');

    if (response.statusCode == 200) {
      return Reports.fromJson(json.decode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load reports');
    }
  }
}

class RecentReports extends StatefulWidget {
  @override
  RecentReportsState createState() => RecentReportsState();
}