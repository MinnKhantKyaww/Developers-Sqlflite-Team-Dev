import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlflite_app/model/developer.dart';

class DeveloperRepo {
  Future<Database> _database() async {
    final Future<Database> database =
        openDatabase(join(await getDatabasesPath(), "dev_database.db"),
            onCreate: (db, version) {
      return db.execute(
          "CREATE TABLE developer(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER, heading TEXT)");
    }, version: 1);
    return database;
  }

  Future<Developer> insert(Developer dev) async {
    final Database db = await _database();
    final id = await db.insert("developer", dev.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return findById(id);
  }

  Future<void> update(Developer dev) async {
    final Database db = await _database();
    await db.update("developer", dev.toMap(),
        where: "id = ?",
        whereArgs: [dev.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Developer> findById(int id) async {
    final Database db = await _database();
    final maps = await db.query(
      "developer",
      where: "id = ?",
      whereArgs: [id],
      limit: 1,
    );

    final map = maps.first;
    if (map != null) {
      return Developer(
          id: map['id'],
          name: map['name'],
          heading: map['heading'],
          age: map['age']);
    }
    return null;
  }

  Future<List<Developer>> findAll({String name, String heading}) async {
    final Database db = await _database();

    List<Map<String, dynamic>> maps;

    var where = "";
    var whereArgs = [];

    if(name != null && name.isNotEmpty) {
      where = "name LIKE ?";
      whereArgs.add("$name%");
    }

    if(heading != null && heading.isNotEmpty) {
      where = "$where ${where.isNotEmpty ? "AND" : ""} heading = ?";
      whereArgs.add("$heading");
    }
    
    print(where);

    if (where == null || where.isEmpty) {
      maps = await db.query("developer");
    } else {
      maps = await db.query(
        "developer",
        where: where,
        whereArgs: whereArgs
      );
    }
    return List.generate(maps.length, (index) {
      return Developer(
        id: maps[index]['id'],
        name: maps[index]['name'],
        age: maps[index]['age'],
        heading: maps[index]['heading'],
      );
    });
  }

  Future<void> delete(int id) async {
    final Database db = await _database();
    await db.delete(
      "developer",
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
