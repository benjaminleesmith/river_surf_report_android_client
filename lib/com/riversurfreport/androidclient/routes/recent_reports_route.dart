import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  List<Report> reports = [];
  String moreReportsUrl;
  GlobalKey globalKey = GlobalKey();

  static Color greenTextColor = const Color.fromRGBO(0, 255, 41, 1.0);
  static TextStyle loadMoreStyle = GoogleFonts.vT323(fontSize: 24,
      height: 3,
      color: greenTextColor,
      decoration: TextDecoration.underline);

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
                    if (futureReports == null) {
                      futureReports =
                          fetchReports(snapshot.data.recentReportsUrl);
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

                  return ProgressWithTextWidget(text: "connecting to server");
                })));
  }

  Widget _buildReports() {
    var width = MediaQuery.of(context).size.width;
    return ListView.builder(
        itemCount: reports.length + 1,
        itemBuilder: (context, i) {
          if (i < reports.length) {
            return ReportWidget(
                report: reports[i],
                context: context,
                width: width,
                waveLink: true);
          } else {
            return new GestureDetector(
                onTap: () {
                  Future<Reports> futureMoreReports =
                      _fetchMoreReports(moreReportsUrl);
                  futureMoreReports.then((moreReports) {
                    setState(() {
                      print('set state');
                      this.moreReportsUrl = moreReports.moreReportsUrl;
                      this.reports = reports + moreReports.reports;
                    });
                  });
                },
                child: Container(
                    color: Colors.black,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Text("Load More Reports", style: loadMoreStyle)
                        ])
                ));
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

  Future<Reports> fetchReports(String recentReportsUrl) async {
    final response = await http.get(recentReportsUrl);

    if (response.statusCode == 200) {
      return Reports.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load recent reports');
    }
  }

  Future<Endpoints> fetchEndpoints(String endpointsUrl) async {
    final response = await http.get(endpointsUrl);

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
  RecentReportsRouteState createState() =>
      RecentReportsRouteState(endpointsUrl);
}
