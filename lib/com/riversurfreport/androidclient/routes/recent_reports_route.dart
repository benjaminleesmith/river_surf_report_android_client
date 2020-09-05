import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:river_surf_report_client/com/riversurfreport/androidclient/styles/green_terminal_colors.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/widgets/load_more_widget.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/widgets/progress_with_text_widget.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/widgets/report_widget.dart';
import 'package:river_surf_report_client/com/riversurfreport/api/models/endpoints.dart';
import 'package:river_surf_report_client/com/riversurfreport/api/models/report.dart';
import 'package:river_surf_report_client/com/riversurfreport/api/models/reports.dart';

import 'browse_route.dart';

class RecentReportsRouteState extends State<RecentReportsRoute> {
  String endpointsUrl;

  Future<Endpoints> futureEndpoints;
  String recentReportsUrl;

  Future<Reports> futureReports;
  List<Report> reports = [];
  String moreReportsUrl;
  String browseWavesUrl;

  GlobalKey globalKey = GlobalKey();

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
        drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Image(image: AssetImage('logo-colors.png')),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: GreenTerminalColors.greenTextColor,
                      width: 6
                    )
                  )
                ),
              ),
              ListTile(
                title: Text('Recent Reports', style: TextStyle(color: GreenTerminalColors.greenTextColor, fontSize: 20)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Browse Waves', style: TextStyle(color: GreenTerminalColors.greenTextColor, fontSize: 20)),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => BrowseRoute(this.browseWavesUrl))
                  );
                },
              ),
            ],
          ),
        ),
        body: Center(
            child: FutureBuilder<Endpoints>(
                future: futureEndpoints,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (futureReports == null) {
                      recentReportsUrl = snapshot.data.recentReportsUrl;
                      browseWavesUrl = snapshot.data.browseWavesUrl;
                      futureReports =
                          fetchReports(recentReportsUrl);
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
    return RefreshIndicator(child: ListView.builder(
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
                      this.moreReportsUrl = moreReports.moreReportsUrl;
                      this.reports = reports + moreReports.reports;
                    });
                  });
                },
                child: LoadMore());
          }
        },
        key: globalKey),onRefresh: refreshReports);
  }

  Future<void> refreshReports() async {
    setState(() {
      this.reports = [];
      this.futureReports = null;
      this.moreReportsUrl = null;
    });
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
