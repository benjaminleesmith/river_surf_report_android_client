import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/routes/wave_route.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/styles/green_terminal_colors.dart';
import 'package:river_surf_report_client/com/riversurfreport/api/models/report.dart';
import 'package:intl/intl.dart';

class ReportWidget extends StatefulWidget {
  const  ReportWidget({
    Key key,
    @required this.report,
    @required this.context,
    @required this.width,
    @required this.waveLink,
    this.signInUrl
  }) : super(key: key);

  final Report report;
  final BuildContext context;
  final double width;
  final bool waveLink;
  final String signInUrl;
  static TextStyle waveNameStyle = TextStyle(fontSize: 20,
      height: 2,
      color: GreenTerminalColors.greenTextColor);
  static TextStyle flowStyle = TextStyle(
      fontSize: 20, height: 2, color: GreenTerminalColors.greenTextColor);

  @override
  _ReportWidgetState createState() => _ReportWidgetState(this.signInUrl);
}

class _ReportWidgetState extends State<ReportWidget> {
  bool showDetails = false;
  String signInUrl;

  _ReportWidgetState(String signInUrl) {
    this.signInUrl = signInUrl;
  }

  @override
  Widget build(BuildContext context) {
    Widget waveName;

    if(widget.waveLink) {
      waveName = GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WaveRoute(widget.report.wave, this.signInUrl))
          );
        },
        child: Text(widget.report.wave.name, style: ReportWidget.waveNameStyle.apply(decoration: TextDecoration.underline))
      );
    } else {
      waveName = Text(DateFormat('MMM d, yyyy').format(widget.report.date), style: ReportWidget.waveNameStyle);
    }

    List<Widget> imageStack = <Widget>[];

    imageStack.add(
      Image.network(
        widget.report.imageUrl,
        fit: BoxFit.fitWidth,
        width: widget.width,
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
          if (loadingProgress == null)
            return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                : null,
            ),
          );
        }
      )
    );

    if(showDetails) {
      List<Widget> detailsStack = <Widget>[];

      detailsStack.add(Text("Stars: "+("\u2605" * widget.report.stars), style: TextStyle(color: GreenTerminalColors.greenTextColor, fontSize: 16)));
      detailsStack.add(Text("Notes: "+widget.report.notes, style: TextStyle(color: GreenTerminalColors.greenTextColor)));
      if(widget.waveLink) {
        detailsStack.add(Text("Date: "+DateFormat('MMM d, yyyy').format(widget.report.date), style: TextStyle(color: GreenTerminalColors.greenTextColor)));
      }

      imageStack.add(
        Container(
          color: Colors.black.withOpacity(0.8),
          width: widget.width,
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          child: Column(
            children: detailsStack
          )
        )
      );
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
                  Text(widget.report.flow, style: ReportWidget.flowStyle)
                ])
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              showDetails = !showDetails;
            });
          },
          child: Stack(
            children: imageStack,
          ),
        ),
        Row(

        )
      ],
    );
  }
}