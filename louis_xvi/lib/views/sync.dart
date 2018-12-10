import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:camera/camera.dart';
import '../models/syncagent.dart';

class SyncPage extends StatefulWidget {
  SyncPage({Key key}) : super(key: key);

  final String title = "Sync Bucket";

  @override
  _SyncPageState createState() {
    return _SyncPageState();
  }
}

class _SyncPageState extends State<SyncPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  SyncAgent _agent;
  List<CameraDescription> _cameras = [];
  CameraController _cameraController;
  TextEditingController urlController = TextEditingController();
  TabController _tabController;
  List<SyncRequest> requests = [];

  final List<Widget> tabs = [
    Tab(icon: Icon(Icons.code)),
    Tab(icon: Icon(Icons.photo_camera)),
    Tab(icon: Icon(Icons.text_fields)),
  ];

  @override
  void initState() {
    super.initState();

    _agent = SyncAgent(_updateRequests);
    _tabController = TabController(vsync: this, length: tabs.length);
  }

  @override
  void dispose() {
    _agent?.dispose();
    _tabController?.dispose();
    _cameraController?.dispose();

    super.dispose();
  }

  Future _setup() async {
    await _startAgent();
    await _initCameras();
  }

  Future _startAgent() async {
    return await _agent.start();
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

  Future _updateRequests(SyncRequest request) async {
    setState(() {
      requests.add(request);
    });
  }

  void _showNotifications() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            SyncRequest request = requests[index];

            return ListTile(
              contentPadding: EdgeInsets.all(10),
              title: Text('Request from ${request.url}'),
              trailing: FlatButton.icon(
                label: Text('Accpet'),
                icon: Icon(Icons.check),
                onPressed: () async {
                  await _agent.respond(request);

                  final snackBar = SnackBar(
                    content: Text('Response send!'),
                    action: SnackBarAction(
                      label: 'Dismiss',
                      onPressed: () {
                        // Some code to undo the change!
                      },
                    ),
                  );
                  _scaffoldKey.currentState.showSnackBar(snackBar);
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs,
        ),
      ),
      body: FutureBuilder(
        future: _setup(),
        builder: (context, snapshot) {
          return TabBarView(
            controller: _tabController,
            children: <Widget>[
              Column(
                children: <Widget>[
                  QrImage(
                    data: _agent.url(),
                  ),
                  Text(_agent.url()),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: _cameras.length > 0
                    ? AspectRatio(
                        aspectRatio: _cameraController.value.aspectRatio,
                        child: CameraPreview(_cameraController),
                      )
                    : Text("No camera found"),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                          icon: Icon(Icons.home),
                          labelText: 'URL adderss',
                          hintText: 'URL address',
                        ),
                        controller: urlController,
                        validator: (String value) {
                          if (value.isEmpty) {
                            return "Input URL address";
                          }
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: RaisedButton(
                          child: Text('Send Request'),
                          onPressed: () async {
                            FormState state = _formKey.currentState;
                            if (state.validate()) {
                              state.save();
                              await _agent.request(urlController.text);
                              final snackBar = SnackBar(
                                content: Text('Request send!'),
                                action: SnackBarAction(
                                  label: 'Dismiss',
                                  onPressed: () {
                                    // Some code to undo the change!
                                  },
                                ),
                              );
                              Scaffold.of(context).showSnackBar(snackBar);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNotifications,
        tooltip: 'Notifications',
        child: Icon(requests.length == 0
            ? Icons.notifications_none
            : Icons.notifications),
      ),
    );
  }
}
