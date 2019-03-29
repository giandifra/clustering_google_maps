library clustering_google_maps;

import 'dart:async';
import 'package:clustering_google_maps/src/aggregated_points.dart';
import 'package:clustering_google_maps/src/db_helper.dart';
import 'package:clustering_google_maps/src/lat_lang_geohash.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';

class ClusteringHelper {
  ClusteringHelper.forDB({
    @required this.dbTable,
    @required this.dbLatColumn,
    @required this.dbLongColumn,
    @required this.dbGeohashColumn,
    @required this.updateMarkers,
    this.database,
    this.maxZoomForAggregatePoints = 13.5,
    this.bitmapAssetPathForSingleMarker,
    this.whereClause = "",
  })  : assert(dbTable != null),
        assert(dbGeohashColumn != null),
        assert(dbLongColumn != null),
        assert(dbLatColumn != null);

  //After this value the map show the single points without aggregation
  final double maxZoomForAggregatePoints;

  //Database where we performed the queries
  Database database;

  //Name of table of the databasa SQLite where are stored the latitude, longitude and geoahash value
  final String dbTable;

  //Name of column where is stored the latitude
  final String dbLatColumn;

  //Name of column where is stored the longitude
  final String dbLongColumn;

  //Name of column where is stored the geohash value
  final String dbGeohashColumn;

  //Custom bitmap: string of assets position
  final String bitmapAssetPathForSingleMarker;

  //Where clause for query db
  String whereClause;

  //Variable for save the last zoom
  double _previousZoom = 0.0;

  //Function called when the map must show single point without aggregation
  // if null the class use the default function
  Function showSinglePoint;

  //Function for update Markers on Google Map
  Function updateMarkers;

  List<LatLngAndGeohash> list;

  onCameraMove(CameraPosition position) {
    final zoom = position.zoom;
    _previousZoom = zoom;
  }

  Future<void> onMapIdle() async {
    updateMap();
  }

  updateMap() {
    if (_previousZoom < maxZoomForAggregatePoints) {
      updateAggregatedPoints(zoom: _previousZoom);
    } else {
      if (showSinglePoint != null) {
        showSinglePoint();
      } else {
        updatePoints(_previousZoom);
      }
    }
  }

  // Used for update list
  // NOT RECCOMENDED for good performance (SQL IS BETTER)
  updateData(List<LatLngAndGeohash> newList) {
    list = newList;
    updateMap();
  }

  Future<List<AggregatedPoints>> getAggregatedPoints(double zoom) async {
    print("loading aggregation");
    int level = 5;

    if (zoom <= 3) {
      level = 1;
    } else if (zoom < 5) {
      level = 2;
    } else if (zoom < 7.5) {
      level = 3;
    } else if (zoom < 10.5) {
      level = 4;
    } else if (zoom < 13) {
      level = 5;
    } else if (zoom < 13.5) {
      level = 6;
    } else if (zoom < 14.5) {
      level = 7;
    }

    try {
      final List<AggregatedPoints> aggregatedPoints =
          await DBHelper.getAggregatedPoints(
              database: database,
              dbTable: dbTable,
              dbLatColumn: dbLatColumn,
              dbLongColumn: dbLongColumn,
              dbGeohashColumn: dbGeohashColumn,
              level: level,
              whereClause: whereClause);
      return aggregatedPoints;
    } catch (e) {
      print(e.toString());
      return List<AggregatedPoints>();
    }
  }

  final List<AggregatedPoints> aggList = [];

  // NOT RECCOMENDED for good performance (SQLite IS BETTER)
  List<AggregatedPoints> _retrieveAggregatedPoints(
      List<LatLngAndGeohash> inputList,
      List<AggregatedPoints> resultList,
      int level) {
    print("input list lenght: " + inputList.length.toString());

    if (inputList.isEmpty) {
      return resultList;
    }
    final List<LatLngAndGeohash> newInputList = List.from(inputList);
    List<LatLngAndGeohash> tmp;
    final t = newInputList[0].geohash.substring(0, level);
    tmp =
        newInputList.where((p) => p.geohash.substring(0, level) == t).toList();
    newInputList.removeWhere((p) => p.geohash.substring(0, level) == t);
    double latitude = 0;
    double longitude = 0;
    tmp.forEach((l) {
      latitude += l.location.latitude;
      longitude += l.location.longitude;
    });
    final count = tmp.length;
    final a =
        AggregatedPoints(LatLng(latitude / count, longitude / count), count);
    resultList.add(a);
    return _retrieveAggregatedPoints(newInputList, resultList, level);
  }

  Future<void> updateAggregatedPoints({double zoom = 0.0}) async {
    List<AggregatedPoints> aggregation = await getAggregatedPoints(zoom);
    print("aggregation lenght: " + aggregation.length.toString());

    final markers = aggregation.map((a) {
      BitmapDescriptor bitmapDescriptor;
      if (a.count == 1) {
        if (bitmapAssetPathForSingleMarker != null) {
          bitmapDescriptor =
              BitmapDescriptor.fromAsset(bitmapAssetPathForSingleMarker);
        } else {
          bitmapDescriptor = BitmapDescriptor.defaultMarker;
        }
      } else {
        // >1
        bitmapDescriptor = BitmapDescriptor.fromAsset(a.bitmabAssetName,
            package: "clustering_google_maps");
      }
      final String markerIdVal = a.location.latitude.toString() + "_${a.count}";
      final MarkerId markerId = MarkerId(markerIdVal);

      return Marker(
        markerId: markerId,
        position: a.location,
        infoWindow: InfoWindow(title: a.count.toString()),
        icon: bitmapDescriptor,
        onTap: () {
          print("tap marker");
        },
      );
    }).toSet();
    updateMarkers(markers);
  }

  updatePoints(double zoom) async {
    print("update single points");
    try {
      final listOfPoints = await DBHelper.getPoints(
          database: database,
          dbTable: dbTable,
          dbLatColumn: dbLatColumn,
          dbLongColumn: dbLongColumn,
          whereClause: whereClause);
      final markers = listOfPoints.map((p) {
        final String markerIdVal = p.location.latitude.toString() +
            "_" +
            p.location.longitude.toString();
        final MarkerId markerId = MarkerId(markerIdVal);
        return Marker(
          markerId: markerId,
          position: p.location,
          infoWindow: InfoWindow(
              title:
                  "${p.location.latitude.toStringAsFixed(2)},${p.location.longitude.toStringAsFixed(2)}"),
          icon: bitmapAssetPathForSingleMarker != null
              ? BitmapDescriptor.fromAsset(bitmapAssetPathForSingleMarker)
              : BitmapDescriptor.defaultMarker,
        );
      }).toSet();
      updateMarkers(markers);
    } catch (ex) {
      print(ex.toString());
    }
  }
}
