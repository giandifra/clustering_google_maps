import 'dart:async';
import 'dart:io';
import 'package:example/fake_point.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';

class AppDatabase {
  static final AppDatabase _appDatabase = new AppDatabase._internal();

  AppDatabase._internal();

  Database _database;

  static AppDatabase get() {
    return _appDatabase;
  }

  final _lock = new Lock();

  Future<Database> getDb() async {
    if (_database == null) {
      await _lock.synchronized(() async {
        // Check again once entering the synchronized block
        if (_database == null) {
          await _init();
        }
      });
    }
    return _database;
  }

  Future _init() async {
    print("AppDatabase: init database");
    // Get a location using path_provider
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "clustering.db");
    _database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await _createFakePointsTable(db);
    }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
      await db.execute("DROP TABLE ${FakePoint.tblFakePoints}");
      await _createFakePointsTable(db);
    });
  }

  Future _createFakePointsTable(Database db) {
    return db.execute("CREATE TABLE ${FakePoint.tblFakePoints} ("
        "${FakePoint.dbId} INTEGER PRIMARY KEY AUTOINCREMENT,"
        "${FakePoint.dbGeohash} TEXT,"
        "${FakePoint.dbLat} LONG,"
        "${FakePoint.dbLong} LONG);");
  }

  Future<void> closeDatabase() async {
    if (_database != null && _database.isOpen) {
      await _database.close();
      _database = null;
      print("database closed");
    }
  }
}
