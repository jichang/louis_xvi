import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:camera/camera.dart';
import '../models/syncagent.dart';

class SyncPage extends StatefulWidget {
  SyncPage({Key key}) : super(key: key);

  final String title = "New Bucket";

  @override
  _SyncPageState createState() {
    return _SyncPageState();
  }
}

class _SyncPageState extends State<SyncPage>
    with SingleTickerProviderStateMixin {
  SyncAgent _agent;
  List<CameraDescription> _cameras = [];
  CameraController _cameraController;
  TabController _tabController;

  final List<Widget> tabs = [
    Tab(icon: Icon(Icons.file_upload)),
    Tab(icon: Icon(Icons.file_download)),
  ];

  Future _startAgent() async {
    return await _agent.start();
  }

  Future _initCameras() async {
    _cameras = await availableCameras();
    _cameraController =
        new CameraController(_cameras[0], ResolutionPreset.medium);
    return _cameraController.initialize();
  }

  @override
  void initState() {
    super.initState();

    _agent = SyncAgent();
    _tabController = TabController(vsync: this, length: tabs.length);
  }

  @override
  void dispose() {
    _agent?.dispose();
    _tabController?.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          FutureBuilder(
            future: _startAgent(),
            builder: (context, snapshot) {
              return QrImage(
                data: "hello, world",
                size: 100,
              );
            },
          ),
          FutureBuilder(
            future: _initCameras(),
            builder: (context, snapshot) {
              if (_cameraController != null &&
                  _cameraController.value != null) {
                return AspectRatio(
                  aspectRatio: _cameraController.value.aspectRatio,
                  child: CameraPreview(_cameraController),
                );
              } else {
                return Text("No camera found");
              }
            },
          )
        ],
      ),
    );
  }
}
