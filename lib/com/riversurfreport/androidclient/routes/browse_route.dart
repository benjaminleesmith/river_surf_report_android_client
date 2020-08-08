import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/main.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/routes/recent_reports_route.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/widgets/browse_wave_widget.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/widgets/progress_with_text_widget.dart';
import 'package:river_surf_report_client/com/riversurfreport/api/models/waves.dart';
import 'package:http/http.dart' as http;

class BrowseRouteState extends State<BrowseRoute> {
  String browseWavesUrl;

  Future<Waves> futureWaves;

  BrowseRouteState(this.browseWavesUrl);

  @override
  void initState() {
    super.initState();
    futureWaves = fetchWaves(browseWavesUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Browse Waves'),
        ),
        drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text('River Surf Report'),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                title: Text('Recent Reports'),
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => RecentReportsRoute(MyApp.apiHomeUrl)));
                },
              ),
              ListTile(
                title: Text('Browse Waves'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        body: Center(
            child: FutureBuilder<Waves>(
              future: futureWaves,
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  return _buildWaves(snapshot.data);
                } else if (snapshot.hasError) {
                  return Text(snapshot.error);
                } else {
                  return ProgressWithTextWidget(text: "fetching waves");
                }
              }
            )
        )
    );
  }

  Future<Waves> fetchWaves(String browseWavesUrl) async {
    final response = await http.get(browseWavesUrl);

    if(response.statusCode == 200) {
      return Waves.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load waves');
    }
  }

  Widget _buildWaves(Waves waves) {
    return ListView.builder(itemCount: waves.waves.length, itemBuilder: (context, i) {
      return BrowseWaveWidget(wave: waves.waves[i]);
    });
  }
}

class BrowseRoute extends StatefulWidget {
  String browseWavesUrl;

  BrowseRoute(this.browseWavesUrl);

  @override
  BrowseRouteState createState()
    => BrowseRouteState(browseWavesUrl);
}
