import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/models/wave.dart';

class WaveRouteState extends State<WaveRoute> {
  Wave wave;

  WaveRouteState(Wave wave) {
    this.wave = wave;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(wave.name),
        ),
        body: Text('Wave')
    );
  }
}

class WaveRoute extends StatefulWidget {
  Wave wave;
  WaveRoute(Wave wave) {
    this.wave = wave;
  }

  @override
  WaveRouteState createState() => WaveRouteState(this.wave);
}