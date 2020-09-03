// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/styles/green_terminal_colors.dart';
import 'routes/recent_reports_route.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static const String apiHomeUrl = 'http://riversurfreport.herokuapp.com/api/home';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
//        debugShowCheckedModeBanner: false,
        home: RecentReportsRoute(apiHomeUrl),
        theme: ThemeData(
          primaryColor: Color.fromRGBO(0, 0, 0, 1.0),
          appBarTheme: AppBarTheme(
            textTheme: TextTheme(
              title: TextStyle(
                color: GreenTerminalColors.greenTextColor,
                fontSize: 20
              )
            ),
            iconTheme: IconThemeData(
              color: GreenTerminalColors.greenTextColor
            )
          )
        ),

    );
  }
}