import 'package:sqflite/sqflite.dart';
import 'package:louis_xvi/storage/storage.dart';

class Bucket {
  int id;
  String website;
  String username;
  String password;
  DateTime createDate;
  DateTime updateDate;

  Bucket(this.website, this.username, this.password) {
    this.createDate = DateTime.now();
    this.updateDate = DateTime.now();
  }

  Bucket.fromRow(Map row) {
    this.id = row['rowid'];
    this.website = row['website'];
    this.username = row['username'];
    this.password = row['password'];
    this.createDate = DateTime.parse(row['createDate']);
    this.updateDate = DateTime.parse(row['updateDate']);
  }

  static openDatabase(path) async {}

  static Future<List<Bucket>> load() async {
    Database database = await Storage.open();
    String sql = """
      SELECT rowid, website, username, password, createDate, updateDate
      FROM buckets
    """;
    List<Bucket> buckets = [];
    List<Map> rows = await database.rawQuery(sql);
    rows.forEach((Map row) {
      buckets.add(Bucket.fromRow(row));
    });
    Storage.close(database);

    return buckets;
  }

  void update() async {}

  void save() async {
    Database database = await Storage.open();
    String sql = """
      INSERT INTO buckets(website, username, password)
      VALUES (?, ?, ?)
      """;
    id = await database.rawInsert(sql, [website, username, password]);

    await Storage.close(database);
  }
}
