import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/models/wave_link.dart';

class WaveRouteState extends State<WaveRoute> {
  WaveLink wave;

  WaveRouteState(WaveLink wave) {
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
  WaveLink wave;
  WaveRoute(WaveLink wave) {
    this.wave = wave;
  }

  @override
  WaveRouteState createState() => WaveRouteState(this.wave);
}