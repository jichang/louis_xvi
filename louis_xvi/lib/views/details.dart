import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:louis_xvi/models/bucket.dart';
import 'package:louis_xvi/models/generator.dart';

enum Mode {
  View,
  Edit,
}

class DetailsPage extends StatefulWidget {
  DetailsPage({Key key, this.bucket}) : super(key: key);

  final String title = "Bucket Details";
  final Bucket bucket;

  @override
  _DetailsPageState createState() {
    return _DetailsPageState(bucket);
  }
}

class ConstantFocusNode extends FocusNode {
  bool hasFocusFlag;
  ConstantFocusNode(this.hasFocusFlag);

  @override
  bool get hasFocus => hasFocusFlag;
}

class _DetailsPageState extends State<DetailsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final websiteController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  Mode mode = Mode.View;

  Random random = Random();

  final Bucket bucket;

  int length = 8;
  bool useAlphabet = true;
  bool useNumber = true;
  bool useSymbol = false;

  _DetailsPageState(this.bucket);

  @override
  void initState() {
    super.initState();

    setState(() {
      websiteController.text = bucket.website;
      usernameController.text = bucket.username;
      passwordController.text = bucket.password;

      length = bucket.generator.length;
      useAlphabet = bucket.generator.useAlphabet;
      useNumber = bucket.generator.useNumber;
      useSymbol = bucket.generator.useSymbol;
    });
  }

  @override
  void dispose() {
    websiteController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _startEdit() {
    setState(() {
      mode = Mode.Edit;
    });
  }

  void _saveBucket() async {
    final state = _formKey.currentState;
    state.save();

    await bucket.update(
      websiteController.text,
      usernameController.text,
      passwordController.text,
      GeneratorConfig(length, useAlphabet, useNumber, useSymbol),
    );

    Navigator.pop(context, bucket);
  }

  void _copyPassword() {
    Clipboard.setData(new ClipboardData(text: bucket.password));
    final snackBar = SnackBar(
      content: Text('Copied to clipboard!'),
      action: SnackBarAction(
        label: 'Dismiss',
        onPressed: () {},
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void _updatePassword() {
    setState(() {
      passwordController.text = generatePassword();
    });
  }

  bool isEditMode() {
    return mode == Mode.Edit;
  }

  void _updateLength(double value) {
    if (isEditMode()) {
      setState(() {
        length = value.toInt();
        passwordController.text = generatePassword();
      });
    }
  }

  void _toggleAlphabet(bool enabled) {
    if (isEditMode()) {
      setState(() {
        useAlphabet = enabled;
        passwordController.text = generatePassword();
      });
    }
  }

  void _toggleNumber(bool enabled) {
    if (isEditMode()) {
      setState(() {
        useNumber = enabled;
        passwordController.text = generatePassword();
      });
    }
  }

  void _toggleSymbol(bool enabled) {
    if (isEditMode()) {
      setState(() {
        useSymbol = enabled;
        passwordController.text = generatePassword();
      });
    }
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
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(
              isEditMode() ? Icons.save : Icons.edit,
              color: Colors.white,
            ),
            label: Text(
              isEditMode() ? 'Save' : 'Edit',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: isEditMode() ? _saveBucket : _startEdit,
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
                  focusNode: ConstantFocusNode(isEditMode()),
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
                  focusNode: ConstantFocusNode(isEditMode()),
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
                      child: Icon(
                          isEditMode() ? Icons.refresh : Icons.content_copy),
                      onTap: isEditMode() ? _updatePassword : _copyPassword,
                    ),
                  ),
                  controller: passwordController,
                  focusNode: ConstantFocusNode(isEditMode()),
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
                        label: length.toInt().toString(),
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
