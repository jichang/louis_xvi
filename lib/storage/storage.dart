import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class Storage {
  static String dbFile = "louis.db";

  static void migrate(Database db, int version) async {
    await db.execute(
      """
      CREATE TABLE IF NOT EXISTS buckets(
        website TEXT NOT NULL,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        createDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updateDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        status INT NOT NULL DEFAULT 0
      )
    """,
    );
  }

  static Future<Database> open() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, dbFile);
    Database db =
        await openDatabase(path, version: 1, onCreate: Storage.migrate);
    return db;
  }

  static Future<dynamic> close(Database database) async {
    return await database.close();
  }
}
