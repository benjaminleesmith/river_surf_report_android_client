import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/main.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/routes/recent_reports_route.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/styles/green_terminal_colors.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/widgets/browse_wave_widget.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/widgets/progress_with_text_widget.dart';
import 'package:river_surf_report_client/com/riversurfreport/api/models/waves.dart';
import 'package:http/http.dart' as http;

class BrowseRouteState extends State<BrowseRoute> {
  String browseWavesUrl;
  String signInUrl;

  Future<Waves> futureWaves;
  String searchTerm = '';

  BrowseRouteState(this.browseWavesUrl, this.signInUrl);

  static TextStyle waveNameStyle = TextStyle(fontSize: 20,
      height: 2,
      color: GreenTerminalColors.greenTextColor,
      decoration: TextDecoration.underline
  );

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
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => RecentReportsRoute(MyApp.apiHomeUrl)));
                },
              ),
              ListTile(
                title: Text('Browse Waves', style: TextStyle(color: GreenTerminalColors.greenTextColor, fontSize: 20)),
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
    var filteredWaves = waves.waves.where((wave) {
      var lowerSearchTerm = this.searchTerm.toLowerCase();
      return wave.name.toLowerCase().contains(lowerSearchTerm) || wave.parentsString.toLowerCase().contains(lowerSearchTerm);
    }).toList();

    return ListView.builder(
        itemCount: filteredWaves.length+1,
        itemBuilder: (context, i) {
            if(i == 0) {
              return Container(
                  color: Colors.black,
                  padding: new EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                      onChanged: (text) {
                        setState(() {
                          this.searchTerm = text;
                        });
                      },
                      cursorColor: GreenTerminalColors.greenTextColor,
                      style: TextStyle(color: GreenTerminalColors.greenTextColor),
                      decoration: InputDecoration(
                          icon: Icon(Icons.search, color: GreenTerminalColors.greenTextColor),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: GreenTerminalColors.greenTextColor, width: 2.0))
                      )
                )
              );
            } else {
              return BrowseWaveWidget(wave: filteredWaves[i-1], signInUrl: this.signInUrl);
            }
        }
    );
  }
}

class BrowseRoute extends StatefulWidget {
  String browseWavesUrl;
  String signInUrl;

  BrowseRoute(this.browseWavesUrl, this.signInUrl);

  @override
  BrowseRouteState createState()
    => BrowseRouteState(this.browseWavesUrl, this.signInUrl);
}
