import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:louis_xvi/models/bucket.dart';
import 'create.dart';
import 'details.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  final String title = "Louis XVI";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Bucket> buckets = [];

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  void _loadData() async {
    List<Bucket> buckets = await Bucket.load();
    setState(() {
      this.buckets.addAll(buckets);
    });
  }

  void _copyPassword(Bucket bucket) {
    Clipboard.setData(new ClipboardData(text: bucket.password));
  }

  void _navigateToCreatePage() async {
    Bucket bucket = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePage(),
      ),
    );

    if (bucket != null) {
      setState(() {
        buckets.add(bucket);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: buckets.length,
          itemBuilder: (context, index) {
            Bucket bucket = buckets[index];
            return ListTile(
              title: Text(bucket.website),
              subtitle: Text(bucket.username),
              trailing: GestureDetector(
                onTap: () {
                  _copyPassword(bucket);
                  final snackBar = SnackBar(
                    content: Text('Copied to clipboard!'),
                    action: SnackBarAction(
                      label: 'Dismiss',
                      onPressed: () {
                        // Some code to undo the change!
                      },
                    ),
                  );
                  Scaffold.of(context).showSnackBar(snackBar);
                },
                child: Icon(Icons.content_copy),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsPage(
                          bucket: bucket,
                        ),
                  ),
                );
              },
            );
          },
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
