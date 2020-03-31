import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgressWithTextWidget extends StatelessWidget {
  const ProgressWithTextWidget({
    Key key,
    @required this.text,
  }) : super(key: key);

  final String text;


  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 200.0),
        SizedBox(
          height: 200.0,
          child: Stack(
            children: <Widget>[
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  child: new CircularProgressIndicator(
                    strokeWidth: 15,
                    value: 1.0,
                  ),
                ),
              ),
              Center(child: Text(text)),
            ],
          ),
        ),
      ],
    );
  }
}