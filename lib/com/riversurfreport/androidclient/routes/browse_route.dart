import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/main.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/routes/recent_reports_route.dart';

class BrowseRouteState extends State<BrowseRoute> {
  String browseWavesUrl;

  BrowseRouteState(this.browseWavesUrl);

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
        body: Center(child: Text(this.browseWavesUrl)));
  }
}

class BrowseRoute extends StatefulWidget {
  String browseWavesUrl;

  BrowseRoute(this.browseWavesUrl);

  @override
  BrowseRouteState createState()
    => BrowseRouteState(browseWavesUrl);
}
