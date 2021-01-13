import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/styles/green_terminal_colors.dart';
import 'package:river_surf_report_client/com/riversurfreport/androidclient/widgets/custom_dialog.dart';

class AddReportRouteState extends State<AddReportRoute> {
  String createReportUrl;
  PickedFile imageFile;

  AddReportRouteState(String createReportUrl) {
    this.createReportUrl = createReportUrl;
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if(imageFile == null) {
      body = buildSelectPhotoWidget(context);
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Image.file(File(imageFile.path))
          ),
          Container(
            child: Text(imageFile.path, style: TextStyle(color: GreenTerminalColors.greenTextColor, fontSize: 20))
          )
        ]
      );
    }


    return Scaffold(
      appBar: AppBar(
        title: Text("Add Surf Report")
      ),
      body: body
    );
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
            child: Text("> Choose an existing photo...", style: TextStyle(color: GreenTerminalColors.greenTextColor, fontSize: 20))
          )
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 40.0),
          child: GestureDetector(
            onTap: () {
              _onTakeNewClicked(context);
            },
            child: Text("> Take a new photo...", style: TextStyle(color: GreenTerminalColors.greenTextColor, fontSize: 20))
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
      imageQuality: 50);
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

  AddReportRoute(String createReportUrl) {
    this.createReportUrl = createReportUrl;
  }

  @override
  AddReportRouteState createState() => AddReportRouteState(this.createReportUrl);
}

class GalleryItem {
  GalleryItem({this.id, this.resource, this.isSvg = false});

  final String id;
  String resource;
  final bool isSvg;
}