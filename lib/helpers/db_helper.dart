import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

class DBHelper {
  static Future<sql.Database> database() async {
    final dbPath = await sql.getDatabasesPath();

    return sql.openDatabase(path.join(dbPath, 'results.db'),
        onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE exam_results(id TEXT PRIMARY KEY, name TEXT, marks TEXT, image TEXT)');
    }, version: 1);
  }

  static Future<void> insert(String table, Map<String, dynamic> data) async {
    final db = await DBHelper.database();
    db.insert(table, data, conflictAlgorithm: sql.ConflictAlgorithm.replace,);
  }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await DBHelper.database();
    return db.query(table)  ; 
  }

  static Future<void> delete(String table, String name) async {
    final db = await DBHelper.database();
    db.delete(table, where: 'name = $name',  );
  }
}
