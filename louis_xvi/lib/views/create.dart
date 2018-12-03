import 'dart:math';
import 'package:flutter/material.dart';
import 'package:louis_xvi/models/bucket.dart';
import 'package:louis_xvi/models/generator.dart';

class CreatePage extends StatefulWidget {
  CreatePage({Key key}) : super(key: key);

  final String title = "New Bucket";

  @override
  _CreatePageState createState() {
    return _CreatePageState();
  }
}

class _CreatePageState extends State<CreatePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final websiteController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Random random = Random();

  String website = "";
  String username = "";
  String password = "";
  int length = 8;
  bool useAlphabet = true;
  bool useNumber = true;
  bool useSymbol = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      passwordController.text = generatePassword();
    });
  }

  @override
  void dispose() {
    websiteController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _saveBucket() async {
    final state = _formKey.currentState;
    state.save();

    Bucket bucket = new Bucket(
      websiteController.text,
      usernameController.text,
      passwordController.text,
      GeneratorConfig(length.toInt(), useAlphabet, useNumber, useSymbol),
    );

    await bucket.save();

    Navigator.pop(context, bucket);
  }

  void _updatePassword() {
    setState(() {
      passwordController.text = generatePassword();
    });
  }

  void _updateLength(double value) {
    setState(() {
      length = value.toInt();
      passwordController.text = generatePassword();
    });
  }

  void _toggleAlphabet(bool enabled) {
    setState(() {
      useAlphabet = enabled;
      passwordController.text = generatePassword();
    });
  }

  void _toggleNumber(bool enabled) {
    setState(() {
      useNumber = enabled;
      passwordController.text = generatePassword();
    });
  }

  void _toggleSymbol(bool enabled) {
    setState(() {
      useSymbol = enabled;
      passwordController.text = generatePassword();
    });
  }

  String generatePassword() {
    List<Generator> generators = List();
    if (useAlphabet) {
      generators.add(AlphabetGenerator());
    }
    if (useNumber) {
      generators.add(NumberGenerator());
    }
    if (useSymbol) {
      generators.add(SymbolGenerator());
    }

    ChoiceGenerator choice = ChoiceGenerator(generators);
    SequenceGenerator sequence = SequenceGenerator(choice, length.toInt());

    return sequence.generate(random);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(
              Icons.save,
              color: Colors.white,
            ),
            label: Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: _saveBucket,
          )
        ],
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  top: 10,
                  left: 10,
                  right: 10,
                ),
                child: TextFormField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.home),
                    labelText: 'Website',
                    hintText: 'Website',
                  ),
                  controller: websiteController,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 10,
                  left: 10,
                  right: 10,
                ),
                child: TextFormField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.account_circle),
                    labelText: 'Username',
                    hintText: 'Username',
                  ),
                  controller: usernameController,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 10,
                  left: 10,
                  right: 10,
                ),
                child: TextFormField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.lock),
                    labelText: 'Password',
                    hintText: 'Password',
                    suffixIcon: GestureDetector(
                      child: Icon(Icons.refresh),
                      onTap: _updatePassword,
                    ),
                  ),
                  controller: passwordController,
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.only(top: 30, left: 16, right: 16, bottom: 0),
                child: Text("Generator Config"),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 10,
                  left: 16,
                  right: 16,
                ),
                child: Row(
                  children: <Widget>[
                    Text("Length"),
                    Expanded(
                      child: Slider(
                        label: length.toString(),
                        value: length.toDouble(),
                        min: 4.0,
                        max: 64.0,
                        divisions: 60,
                        onChanged: _updateLength,
                      ),
                    ),
                  ],
                ),
              ),
              SwitchListTile(
                title: Text("Alphabet"),
                value: useAlphabet,
                onChanged: _toggleAlphabet,
              ),
              SwitchListTile(
                title: Text("Number"),
                value: useNumber,
                onChanged: _toggleNumber,
              ),
              SwitchListTile(
                title: Text("Symbol"),
                value: useSymbol,
                onChanged: _toggleSymbol,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
