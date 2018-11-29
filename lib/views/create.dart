import 'package:flutter/material.dart';

class CreatePage extends StatefulWidget {
  CreatePage({Key key}) : super(key: key);

  final String title = "New Bucket";

  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  void _navigateToCreatePage() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePage,
        tooltip: 'Create',
        child: Icon(Icons.add),
      ),
    );
  }
}
