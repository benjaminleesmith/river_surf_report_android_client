import 'package:flutter/material.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/styles/green_terminal_colors.dart';
import 'routes/recent_reports_route.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static const String apiHomeUrl = 'https://riversurfreport.herokuapp.com/api/home';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: RecentReportsRoute(apiHomeUrl),
        theme: ThemeData(
          fontFamily: 'VT323',
          primaryColor: Color.fromRGBO(0, 0, 0, 1.0),
          canvasColor: Color.fromRGBO(0, 0, 0, 1.0),
          accentColor: GreenTerminalColors.greenTextColor,
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