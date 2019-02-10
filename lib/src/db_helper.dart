import 'package:clustering_google_maps/src/aggregated_points.dart';
import 'package:clustering_google_maps/src/lat_lang_geohash.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {

  static Future<List<AggregatedPoints>> getAggregatedPoints(
      Database database,
      String dbTable,
      String dbLatColumn,
      String dbLongColumn,
      String dbGeohashColumn,
      int level) async {
    print("--------- START QUERY AGGREGATION");
    try {
      var result = await database.rawQuery(
          'SELECT COUNT(*) as n_marker, AVG($dbLatColumn) as lat,  AVG($dbLongColumn) as long '
              'FROM $dbTable GROUP BY substr($dbGeohashColumn,1,$level);');

      List<AggregatedPoints> aggregatedPoints = new List();

      for (Map<String, dynamic> item in result) {
        print(item);
        var p = new AggregatedPoints.fromMap(item, dbLatColumn, dbLongColumn);
        aggregatedPoints.add(p);
      }
      print("--------- COMPLETE QUERY AGGREGATION");
      return aggregatedPoints;
    } catch (e) {
      print(e.toString());
      print("--------- COMPLETE QUERY AGGREGATION WITH ERROR");
      return List<AggregatedPoints>();
    }
  }

  static Future<List<LatLngAndGeohash>> getPoints(
      Database database,
      String dbTable,
      String dbLatColumn,
      String dbLongColumn,) async {

    try {
      var result = await database.rawQuery('SELECT $dbLatColumn as lat, $dbLongColumn as long '
          'FROM $dbTable;');
      List<LatLngAndGeohash> points = new List();
      for (Map<String, dynamic> item in result) {
        var p = new LatLngAndGeohash.fromMap(item);
        points.add(p);
      }
      print("--------- COMPLETE QUERY");
      return points;
    } catch (e) {
      print(e.toString());
      return List<LatLngAndGeohash>();
    }
  }

}