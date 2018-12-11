import 'package:sqflite/sqflite.dart';
import 'package:louis_xvi/storage/storage.dart';
import 'dart:convert';

class GeneratorConfig {
  int length = 8;
  bool useAlphabet = false;
  bool useNumber = false;
  bool useSymbol = false;

  GeneratorConfig(
    this.length,
    this.useAlphabet,
    this.useNumber,
    this.useSymbol,
  );

  GeneratorConfig.fromJson(Map<String, dynamic> json) {
    length = json['length'];
    useAlphabet = json['useAlphabet'];
    useNumber = json['useNumber'];
    useSymbol = json['useSymbol'];
  }

  Map<String, dynamic> toJson() => {
        'length': length,
        'useAlphabet': useAlphabet,
        'useNumber': useNumber,
        'useSymbol': useSymbol,
      };
}

class Bucket {
  int id;
  String website;
  String username;
  String password;
  GeneratorConfig generator;
  DateTime createDate;
  DateTime updateDate;

  Bucket(this.website, this.username, this.password, this.generator) {
    this.createDate = DateTime.now();
    this.updateDate = DateTime.now();
  }

  Bucket.fromRow(Map row) {
    this.id = row['rowid'];
    this.website = row['website'];
    this.username = row['username'];
    this.password = row['password'];
    Map<String, dynamic> generator = json.decode(row['generator']);
    this.generator = GeneratorConfig.fromJson(generator);
    this.createDate = DateTime.parse(row['createDate']);
    this.updateDate = DateTime.parse(row['updateDate']);
  }

  Bucket.fromJson(Map row) {
    this.id = row['rowid'];
    this.website = row['website'];
    this.username = row['username'];
    this.password = row['password'];
    this.generator = GeneratorConfig.fromJson(row['generator']);
    this.createDate = DateTime.parse(row['createDate']);
    this.updateDate = DateTime.parse(row['updateDate']);
  }

  Future update(
    String website,
    String username,
    String password,
    GeneratorConfig generator,
  ) async {
    this.website = website;
    this.username = username;
    this.password = password;
    this.generator = generator;

    Database database = await Storage.open();
    String sql = """
      UPDATE buckets
      SET website = ?, username = ?, password = ?, generator = ?
      WHERE rowid = ?
      """;
    await database.rawUpdate(
      sql,
      [
        website,
        username,
        password,
        json.encode(generator),
        id,
      ],
    );

    return await Storage.close(database);
  }

  Future save() async {
    Database database = await Storage.open();
    String sql = """
      INSERT INTO buckets(website, username, password, generator)
      VALUES (?, ?, ?, ?)
      """;
    id = await database
        .rawInsert(sql, [website, username, password, json.encode(generator)]);

    await Storage.close(database);
  }

  static Future<List<Bucket>> load() async {
    Database database = await Storage.open();
    String sql = """
      SELECT rowid, website, username, password, generator, createDate, updateDate
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

  Map<String, dynamic> toJson() => {
        'website': website,
        'username': username,
        'password': password,
        'generator': generator.toJson(),
        'createDate': createDate.toString(),
        'updateDate': updateDate.toString(),
      };
}
