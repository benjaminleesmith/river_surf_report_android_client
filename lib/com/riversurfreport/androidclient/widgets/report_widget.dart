import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/routes/wave_route.dart';
import 'package:river_surf_report_client/com/riversurfreport/api/models/report.dart';

class ReportWidget extends StatelessWidget {
  const ReportWidget({
    Key key,
    @required this.report,
    @required this.context,
    @required this.width,
    @required this.waveLink
  }) : super(key: key);

  final Report report;
  final BuildContext context;
  final double width;
  final bool waveLink;
  static Color greenTextColor = const Color.fromRGBO(0, 255, 41, 1.0);
  static TextStyle waveNameStyle = GoogleFonts.vT323(fontSize: 20,
      height: 2,
      color: greenTextColor);
  static TextStyle flowStyle = GoogleFonts.vT323(
      fontSize: 20, height: 2, color: greenTextColor);

  @override
  Widget build(BuildContext context) {
    Widget waveName;

    if(waveLink) {
      waveName = new GestureDetector(onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WaveRoute(report.wave))
        );
      },
          child: Text(report.wave.name, style: waveNameStyle.apply(decoration: TextDecoration.underline))
      );
//      waveNameStyle = defaultWaveNameStyle;
    } else {
      waveName = Text(report.wave.name, style: waveNameStyle);
    }


    return Column(
      children: <Widget>[
        Container(
            color: Colors.black,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  waveName,
                  Text(report.flow, style: flowStyle)
                ])
        ),
        Image.network(report.imageUrl, fit: BoxFit.fitWidth, width: width, loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
          if (loadingProgress == null)
            return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                  : null,
            ),
          );
        }),
        Row(

        )
      ],
    );
  }
}