import 'package:uuid/uuid.dart';

class Bucket {
  int id;
  String website;
  String username;
  String password;
  DateTime createDate;
  DateTime updateDate;

  Bucket({this.website, this.username, this.password, this.createDate}) {
    this.createDate = DateTime.now();
    this.updateDate = DateTime.now();
  }
}
