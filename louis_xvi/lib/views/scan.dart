import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class ScanPage extends StatefulWidget {
  ScanPage({Key key}) : super(key: key);

  final String title = "Scan QR code";

  @override
  _ScanPageState createState() {
    return _ScanPageState();
  }
}

class _ScanPageState extends State<ScanPage>
    with SingleTickerProviderStateMixin {
  List<CameraDescription> _cameras = [];
  CameraController _cameraController;

  @override
  void dispose() {
    _cameraController?.dispose();

    super.dispose();
  }

  Future _initCameras() async {
    if (_cameraController == null) {
      _cameras = await availableCameras();
      if (_cameras.length > 0) {
        _cameraController =
            new CameraController(_cameras[0], ResolutionPreset.medium);
        return _cameraController.initialize();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: _initCameras(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Container();
          }

          return Padding(
            padding: EdgeInsets.all(10),
            child: _cameras.length > 0
                ? AspectRatio(
                    aspectRatio: _cameraController.value.aspectRatio,
                    child: CameraPreview(_cameraController),
                  )
                : Text("No camera found"),
          );
        },
      ),
    );
  }
}
