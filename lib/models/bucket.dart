import 'package:uuid/uuid.dart';

class Bucket {
  Uuid id;
  String password;
  DateTime createDate;

  Bucket({this.id, this.password, this.createDate});
}
