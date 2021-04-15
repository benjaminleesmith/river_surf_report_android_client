import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/styles/green_terminal_colors.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/widgets/custom_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:river_surf_report_client/com/riversurfreport/androidclient/widgets/progress_with_text_widget.dart';
import 'package:river_surf_report_client/com/riversurfreport/api/models/session.dart';
import 'package:uuid/uuid.dart';

import '../../aws/s3/aws_s3.dart';

class AddReportRouteState extends State<AddReportRoute> {
  String createReportUrl;
  String signInUrl;

  String email;
  String password;
  String errorMessage;

  String token = 'fetching';
  String AWSAccessKeyID;
  String AWSSecretAccessKey;

  bool uploadingImage = false;
  PickedFile imageFile;

  String uploadedImageUrl = null;
  int cfs;
  int stars = 0;
  DateTime reportDateTime = DateTime.now();
  String notes;

  AddReportRouteState(String createReportUrl, String signInUrl) {
    this.createReportUrl = createReportUrl;
    this.signInUrl = signInUrl;
    FlutterSession().get("token").then((value) => {
      setState(() {
        this.token = value;
      })
    });
    FlutterSession().get("AWSAccessKeyID").then((value) => {
      setState(() {
        this.AWSAccessKeyID = value;
      })
    });
    FlutterSession().get("AWSSecretAccessKey").then((value) => {
      setState(() {
        this.AWSSecretAccessKey = value;
      })
    });
    this.errorMessage = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Surf Report")
      ),
      body: _getBody(context)
    );
  }

  Widget _getBody(BuildContext context) {
    if (this.token == "fetching") {
      return ProgressWithTextWidget(text: "");
    } else if(this.token == null) {
      return _loggedOutWidget(context);
    } else if(this.token != null){
      if(!this.uploadingImage && uploadedImageUrl == null) {
        return _choosePhoto(context);
      } else if(this.uploadingImage) {
        return ProgressWithTextWidget(text: "uploading photo");
      } else if(!this.uploadingImage && uploadedImageUrl != null) {
        return _setReportMetadata(context);
      }
    }
  }

  Widget _setReportMetadata(BuildContext context) {
    return ListView(
      children: <Widget>[
        Container(
          child: Image.file(File(imageFile.path))
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          child: Container(
            color: Colors.black,
            padding: new EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "CFS",
                labelStyle: TextStyle(color: GreenTerminalColors.greenTextColor, fontSize: 18),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: GreenTerminalColors.greenTextColor, width: 2.0)),
              ),
              onChanged: (text) {
                setState(() {
                  this.cfs = int.parse(text);
                });
              },
              autofocus: true,
              cursorColor: GreenTerminalColors.greenTextColor,
              style: TextStyle(color: GreenTerminalColors.greenTextColor, fontSize: 18),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.number
            )
          )
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          child: Container(
            color: Colors.black,
            padding: new EdgeInsets.symmetric(horizontal: 20.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Stars",
                labelStyle: TextStyle(color: GreenTerminalColors.greenTextColor, fontSize: 18),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: GreenTerminalColors.greenTextColor, width: 2.0))
              ),
              onChanged: (String newValue) {
                setState(() {
                  this.stars = newValue == null ? 0 : int.parse(newValue);
                });
              },
              value: this.stars.toString(),
              icon: const Icon(Icons.arrow_downward, color: Color.fromRGBO(0, 255, 41, 1.0)),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: MaterialColor(0xFF00FF41, { 900:Color.fromRGBO(0,255,41, 1) }), fontFamily: 'VT323', fontSize: 18),
              items: <Map<String, String>>[
                {"label": "No stars: Don't know/Didn't surf it", "value": "0"},
                {"label": "1 star: Not surfable/barely surfable", "value": "1"},
                {"label": "2 stars: Surfable, but not great", "value": "2"},
                {"label": "3 stars: Fun, worth surfing", "value": "3"},
                {"label": "4 stars: Great", "value": "4"},
                {"label": "5 stars: As good as this wave gets", "value": "5"}
              ].map<DropdownMenuItem<String>>((Map item) {
                return DropdownMenuItem<String>(
                  value: item["value"],
                  child: Text(item["label"]),
                );
              }).toList(),
            )
          )
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          child: Container(
            color: Colors.black,
            padding: new EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Date", style: TextStyle(color: GreenTerminalColors.greenTextColor, fontSize: 14)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text("${reportDateTime.toLocal()}".split(' ')[0], style: TextStyle(color: GreenTerminalColors.greenTextColor, fontSize: 18)),
                    SizedBox(width: 20.0,),
                    GestureDetector(
                      onTap: () {
                        _selectDate(context);
                      },
                      child: Text("> change date", style: TextStyle(color: GreenTerminalColors.greenTextColor, fontSize: 20, decoration: TextDecoration.underline))
                    ),
                  ],
                )
              ],
            )
          )
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          child: Container(
            color: Colors.black,
            padding: new EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Notes",
                labelStyle: TextStyle(color: GreenTerminalColors.greenTextColor, fontSize: 18),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: GreenTerminalColors.greenTextColor, width: 2.0)),
              ),
              onChanged: (text) {
                setState(() {
                  this.notes = text;
                });
              },
              cursorColor: GreenTerminalColors.greenTextColor,
              style: TextStyle(color: GreenTerminalColors.greenTextColor, fontSize: 18),
            )
          )
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
          child: GestureDetector(
            onTap: () {
              _onSaveReport();
            },
            child: Text("> Save Report", style: TextStyle(color: GreenTerminalColors.greenTextColor, fontSize: 28, decoration: TextDecoration.underline))
          )
        )
      ]
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    var currentDate = DateTime.now();
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: reportDateTime,
      firstDate: DateTime(2010, 1),
      lastDate: new DateTime(currentDate.year, currentDate.month + 1, currentDate.day));
    if (picked != null && picked != reportDateTime)
      setState(() {
        reportDateTime = picked;
      });
  }

  _onSaveReport() async {
    var uri = Uri.parse(this.createReportUrl);
    final response = await http.post(
      uri,
      headers: {"Authorization": "Bearer $token"},
      body: {"image_url": this.uploadedImageUrl, "cfs": this.cfs.toString()}
      );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if(jsonResponse["errors"] == null) {
        Navigator.pop(context);
      } else {
        setState(() {
          this.token = null;
          this.errorMessage = "Your login as expired. Please sign in again.";
        });
      }
    } else {
      throw Exception('Failed to create report');
    }
  }

  Column _loggedOutWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          child: Container(
            color: Colors.black,
            padding: new EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              onChanged: (text) {
                            setState(() {
                              this.email = text;
                            });
              },
              autofocus: true,
              cursorColor: GreenTerminalColors.greenTextColor,
              style: TextStyle(color: GreenTerminalColors.greenTextColor),
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(color: GreenTerminalColors.greenTextColor),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: GreenTerminalColors.greenTextColor, width: 2.0))
              )
            )
          )
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          child: GestureDetector(
            onTap: () {
              _onChooseExistingClicked(context);
            },
            child: Container(
              color: Colors.black,
              padding: new EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                onChanged: (text) {
                            setState(() {
                              this.password = text;
                            });
                },
                cursorColor: GreenTerminalColors.greenTextColor,
                style: TextStyle(color: GreenTerminalColors.greenTextColor),
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(color: GreenTerminalColors.greenTextColor),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: GreenTerminalColors.greenTextColor, width: 2.0))
                )
              )
            )
          )
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
          child: Text(this.errorMessage, style: TextStyle(color: GreenTerminalColors.greenTextColor, fontSize: 20))
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                errorMessage = "";
              });
              _onLogin(context);
            },
            child: Text("> Login", style: TextStyle(color: GreenTerminalColors.greenTextColor, fontSize: 20, decoration: TextDecoration.underline))
          )
        ),
      ],
    );
  }

  _onLogin(BuildContext context) async {
    var uri = Uri.parse(this.signInUrl);
    final response = await http.post(uri, body: {"email": this.email,"password": this.password});

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if(jsonResponse["errors"] == null) {
        Session session = Session.fromJson(jsonResponse);
        FlutterSession().set("token", session.token);
        FlutterSession().set("AWSAccessKeyID", session.AWSAccessKeyID);
        FlutterSession().set("AWSSecretAccessKey", session.AWSSecretAccessKey);
        setState(() {
          token = session.token;
          AWSAccessKeyID = session.AWSAccessKeyID;
          AWSSecretAccessKey = session.AWSSecretAccessKey;
        });
      } else {
        setState(() {
          errorMessage = jsonResponse["errors"];
        });
      }
    } else {
      throw Exception('Failed to login');
    }
  }

  Widget _choosePhoto(BuildContext context) {
    return buildSelectPhotoWidget(context);
  }

  _uploadImage(BuildContext context) async {
    var uuid = Uuid().v1();
    setState(() {
      this.uploadingImage = true;
    });

    AwsS3.uploadFile(
      accessKey: this.AWSAccessKeyID,
      secretKey: this.AWSSecretAccessKey,
      file: File(this.imageFile.path),
      bucket: "riversurfreport-prod",
      region: "us-east-1",
      destDir: "uploads/"+uuid
    ).then((value) => {
      setState(() {
        this.uploadingImage = false;
        this.uploadedImageUrl = value;
      })
    });
  }

  Column buildSelectPhotoWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 10.0),
          child: Text("Start by uploading a photo of the wave:", style: TextStyle(color: GreenTerminalColors.greenTextColor, fontSize: 20)),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 40.0),
          child: GestureDetector(
            onTap: () {
              _onChooseExistingClicked(context);
            },
            child: Text("> Choose an existing photo...", style: TextStyle(color: GreenTerminalColors.greenTextColor, fontSize: 20, decoration: TextDecoration.underline))
          )
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 40.0),
          child: GestureDetector(
            onTap: () {
              _onTakeNewClicked(context);
            },
            child: Text("> Take a new photo...", style: TextStyle(color: GreenTerminalColors.greenTextColor, fontSize: 20, decoration: TextDecoration.underline))
          )
        ),
      ],
    );
  }

  _onTakeNewClicked(context) async {
    Permission permission;

    permission = Permission.camera;

    PermissionStatus permissionStatus = await permission.status;

    if (permissionStatus == PermissionStatus.restricted) {
      _showOpenAppSettingsDialog(context);

      permissionStatus = await permission.status;

      if (permissionStatus != PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus == PermissionStatus.permanentlyDenied) {
      _showOpenAppSettingsDialog(context);

      permissionStatus = await permission.status;

      if (permissionStatus != PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus == PermissionStatus.undetermined) {
      permissionStatus = await permission.request();

      if (permissionStatus != PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus == PermissionStatus.denied) {
      if (Platform.isIOS) {
        _showOpenAppSettingsDialog(context);
      } else {
        permissionStatus = await permission.request();
      }

      if (permissionStatus != PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }
  }

  _onChooseExistingClicked(context) async {
    Permission permission;

    if (Platform.isIOS) {
      permission = Permission.photos;
    } else {
      permission = Permission.storage;
    }

    PermissionStatus permissionStatus = await permission.status;

    if (permissionStatus == PermissionStatus.restricted) {
      _showOpenAppSettingsDialog(context);

      permissionStatus = await permission.status;

      if (permissionStatus != PermissionStatus.granted) {
        return;
      }
    }

    if (permissionStatus == PermissionStatus.permanentlyDenied) {
      _showOpenAppSettingsDialog(context);

      permissionStatus = await permission.status;

      if (permissionStatus != PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus == PermissionStatus.undetermined) {
      permissionStatus = await permission.request();

      if (permissionStatus != PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus == PermissionStatus.denied) {
      if (Platform.isIOS) {
        _showOpenAppSettingsDialog(context);
      } else {
        permissionStatus = await permission.request();
      }

      if (permissionStatus != PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus == PermissionStatus.granted) {
      print('Permission granted');
//      File image = await ImagePicker.pickImage(
//        source: ImageSource.gallery,
//      );

      final tmpFile = await getImage(2);

      setState(() {
        imageFile = tmpFile;
        _uploadImage(context);
      });

//      if (image != null) {
//        String fileExtension = path.extension(image.path);
//
//        _galleryItems.add(
//          GalleryItem(
//            id: Uuid().v1(),
//            resource: image.path,
//            isSvg: fileExtension.toLowerCase() == ".svg",
//          ),
//        );
//
//        setState(() {
//          _photos.add(image);
//          _photosSources.add(PhotoSource.FILE);
//        });
//      }
    }
  }

  Future getImage(int type) async {
    PickedFile pickedImage = await ImagePicker().getImage(
      source: type == 1 ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 100);
    return pickedImage;
  }

  _showOpenAppSettingsDialog(context) {
    return CustomDialog.show(
      context,
      'Permission needed',
      'Photos permission is needed to select photos',
      'Open settings',
      openAppSettings,
    );
  }
}

class AddReportRoute extends StatefulWidget {
  String createReportUrl;
  String signInUrl;

  AddReportRoute(String createReportUrl, String signInUrl) {
    this.createReportUrl = createReportUrl;
    this.signInUrl = signInUrl;
  }

  @override
  AddReportRouteState createState() => AddReportRouteState(this.createReportUrl, this.signInUrl);
}

class GalleryItem {
  GalleryItem({this.id, this.resource, this.isSvg = false});

  final String id;
  String resource;
  final bool isSvg;
}