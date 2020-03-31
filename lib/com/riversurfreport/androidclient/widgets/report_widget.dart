import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/models/report.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/routes/wave_route.dart';

class ReportWidget extends StatelessWidget {
  const ReportWidget({
    Key key,
    @required this.report,
    @required this.context,
    @required this.waveNameStyle,
    @required this.flowStyle,
    @required this.width
  }) : super(key: key);

  final Report report;
  final BuildContext context;
  final TextStyle waveNameStyle;
  final TextStyle flowStyle;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
            color: Colors.black,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  new GestureDetector(onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WaveRoute(report.wave))
                    );
                  },
                      child: Text(report.wave.name, style: waveNameStyle)
                  ),
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