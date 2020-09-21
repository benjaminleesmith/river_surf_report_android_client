import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:river_surf_report_client/com/riversurfreport/androidclient/styles/green_terminal_colors.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/widgets/load_more_widget.dart';
import 'dart:convert';

import 'package:river_surf_report_client/com/riversurfreport/androidclient/widgets/progress_with_text_widget.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/widgets/report_widget.dart';
import 'package:river_surf_report_client/com/riversurfreport/api/models/report.dart';
import 'package:river_surf_report_client/com/riversurfreport/api/models/reports.dart';
import 'package:river_surf_report_client/com/riversurfreport/api/models/wave.dart';
import 'package:river_surf_report_client/com/riversurfreport/api/models/wave_link.dart';

class WaveRouteState extends State<WaveRoute> {
  WaveLink waveLink;

  Future<Wave> futureWave;
  Future<Reports> futureReports;
  Wave wave;
  RangeValues flowRangeValues = null;
  List<Report> reports = [];
  String moreReportsUrl;
  GlobalKey globalKey = GlobalKey();
  bool showFilters = false;

  WaveRouteState(WaveLink wave) {
    this.waveLink = wave;
  }

  @override
  void initState() {
    super.initState();
    futureWave = fetchWave(waveLink.url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(waveLink.name),
          actions: <Widget>[
            IconButton(
               icon: Icon(Icons.filter_list, color: GreenTerminalColors.greenTextColor),
               tooltip: 'Show Filters',
               onPressed: () {
                 setState(() {
                   this.showFilters = !this.showFilters;
                 });
               },
            ),
          ]
        ),
        body: Center(
            child: FutureBuilder<Wave>(
                future: futureWave,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    wave = snapshot.data;
                    if(flowRangeValues == null) {
                      flowRangeValues = RangeValues(wave.minFlow, wave.maxFlow);
                    }
                    if (futureReports == null) {
                      futureReports = fetchReports(snapshot.data.reportsUrl + "?min_flow=" + flowRangeValues.start.round().toString() + "&max_flow=" + flowRangeValues.end.round().toString());
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

    if(reports.length > 0) {
      return Column(
        children: <Widget>[
          _filterWidget(),
          Flexible(
            child: ListView.builder(
              itemCount: reports.length + 1,
              itemBuilder: (context, i) {
                if (i < reports.length) {
                  return _buildReport(reports[i], width);
                } else {
                  if(moreReportsUrl != null) {
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
                }
              },
              key: globalKey
            )
          )
        ]
      );
    } else {
      return Column(
        children: <Widget>[
          _filterWidget(),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[Text("No Reports", style: TextStyle(color: GreenTerminalColors.greenTextColor))]
            )
          )
        ]
      );
    }
  }

  Visibility _filterWidget() {
    return Visibility(
          visible: this.showFilters,
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 33, 0, 0),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                valueIndicatorTextStyle: TextStyle(color: Colors.black, fontSize: 10)
              ),
              child: RangeSlider(
                values: flowRangeValues,
                min: wave.minFlow,
                max: wave.maxFlow,
                inactiveColor: GreenTerminalColors.disabledGreen,
                activeColor: GreenTerminalColors.greenTextColor,
                divisions: 100,
                labels: RangeLabels(
                  flowRangeValues.start.round().toString(),
                  flowRangeValues.end.round().toString(),
                ),
                onChangeEnd: (RangeValues values) {
                  setState(() {
                    futureReports = null;
                    reports = [];
                  });
                },
                onChanged: (RangeValues values) {
                  setState(() {
                    flowRangeValues = values;
                  });
                },
              )
            )
          )
        );
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
