import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/styles/green_terminal_colors.dart';

class LoadMore extends StatelessWidget {
  static TextStyle loadMoreStyle = TextStyle(
      fontSize: 24,
      height: 3,
      color: GreenTerminalColors.greenTextColor,
      decoration: TextDecoration.underline);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.black,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text("Load More Reports", style: loadMoreStyle)
            ]));
  }
}
