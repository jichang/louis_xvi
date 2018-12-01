import 'package:flutter/material.dart';
import '../models//bucket.dart';
import 'create.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  final String title = "Louis XVI";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Bucket> buckets = [];

  void _navigateToCreatePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: buckets.length,
        itemBuilder: (context, index) {
          Bucket bucket = buckets[index];
          return ListTile(
            title: Text(bucket.username),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePage,
        tooltip: 'Create',
        child: Icon(Icons.add),
      ),
    );
  }
}
