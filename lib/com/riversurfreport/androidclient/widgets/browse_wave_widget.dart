import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/routes/wave_route.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/styles/green_terminal_colors.dart';
import 'package:river_surf_report_client/com/riversurfreport/api/models/browse_wave.dart';
import 'package:river_surf_report_client/com/riversurfreport/api/models/wave_link.dart';

class BrowseWaveWidget extends StatelessWidget {
  final BrowseWave wave;

  const BrowseWaveWidget({@required this.wave});

  static TextStyle waveNameStyle = TextStyle(fontSize: 20,
      height: 2,
      color: GreenTerminalColors.greenTextColor,
      decoration: TextDecoration.underline
  );

  static TextStyle waveParentStyle = TextStyle(fontSize: 14,
      height: 2,
      color: GreenTerminalColors.greenTextColor,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.black,
      child:
        Column(
            children: <Widget>[
              Container(
                  child: new GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => WaveRoute(WaveLink(name: wave.name, url: wave.url)))
                        );
                      },
                      child: Text(wave.name, style: waveNameStyle)
                  )
              ),
              Container(
                  color: Colors.black,
                  child: Text(wave.parentsString, style: waveParentStyle)
              ),
              Container(
                color: GreenTerminalColors.greenTextColor,
                height: 2,
                margin: new EdgeInsets.fromLTRB(0, 10, 0, 0)
              )

            ]
        )
    );
  }
}