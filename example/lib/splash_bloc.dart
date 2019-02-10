import 'dart:convert';
import 'package:example/app_db.dart';
import 'package:example/fake_point.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sqflite/sqflite.dart';

class SplashBloc {
  Future<void> addFakePointsToDB(context) async {
    print("STAR GET FAKE WOM");
    try {
      final fakeData = await DefaultAssetBundle.of(context)
          .loadString('assets/map_point.json');
      List<dynamic> newData = json.decode(fakeData.toString());
      for (int i = 0; i < newData.length; i++) {
        final point = newData[i];
        final f = FakePoint(
          location: LatLng(point["LATITUDE"], point["LONGITUDE"]),
          id: i,
        );
        await saveFakePointToDB(f);
      }
      print("EXTRACT COMPLETE");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> saveFakePointToDB(FakePoint fakePoint) async {
    var db = await AppDatabase.get().getDb();
    try {
      await db.transaction((Transaction txn) async {
        int id = await txn.rawInsert('INSERT INTO '
            '${FakePoint.tblFakePoints}(${FakePoint.dbGeohash},${FakePoint.dbLat},${FakePoint.dbLong})'
            ' VALUES("${fakePoint.geohash}",${fakePoint.location.latitude},${fakePoint.location.longitude})');
      });
    } catch (e) {
      print("erorr = " + e.toString());
      throw Exception(e);
    }
  }
}
