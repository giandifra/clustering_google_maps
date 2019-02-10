library clustering_google_maps;

import 'package:clustering_google_maps/src/aggregated_points.dart';
import 'package:clustering_google_maps/src/db_helper.dart';
import 'package:clustering_google_maps/src/lat_lang_geohash.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';

class ClusteringHelper {

//  ClusteringHelper(this.dbTable, this.dbLatColumn, this.dbLongColumn, this.dbGeohashColumn, {
//    this.bitmapAssetPathForSingleMarker,
//    this.mapController,
//    this.database,
//    this.list = const [],
//    this.rangeZoomUpdate = 0.5,
//    this.showSinglePoint,
//  })  : assert(!rangeZoomUpdate.isNegative),
//        assert(list != null) {
//    if (list == null) {
//      list = List();
//    }
//    if (rangeZoomUpdate < 0.0) {
//      rangeZoomUpdate = 0.5;
//    }
//  }

  ClusteringHelper.forDB({
    @required this.mapController,
    @required this.database,
    @required this.dbTable,
    @required this.dbLatColumn,
    @required this.dbLongColumn,
    @required this.dbGeohashColumn,
    this.maxZoomForAggregatePoints = 13.5,
    this.bitmapAssetPathForSingleMarker,
    this.rangeZoomUpdate = 0.5,
  })  : assert(!rangeZoomUpdate.isNegative),
        assert(mapController != null),
        assert(database != null),
        assert(dbTable != null),
        assert(dbGeohashColumn != null),
        assert(dbLongColumn != null),
        assert(dbLatColumn != null) {
    this.mapController.addListener(_onMapChanged);
    updateAggregatedPoints();
    _onMapChanged(forceUpdate: true);
  }

  //Controller for a single GoogleMap instance running on the host platform.
  final GoogleMapController mapController;

  //After this value the map show the single points without aggregation
  final double maxZoomForAggregatePoints;

  //Database where we performed the queries
  final Database database;

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

  // Difference between old e new zoom for update the aggregated points on the map
  //
  // For example:
  //
  // rangeZoomUpdate = 1.0
  // if the map have zoom = 5.0
  // the user do a zoom in until at 6.0
  // the difference is 6.0 - 5.0 = 1.0 , so the aggregated points are refreshed
  //
  // if the map have zoom = 5.0
  // the user do a zoom in until at 5.5
  // the difference is 6.0 - 5.5 = 0.5 , so the aggregated points are NOT refreshed
  final double rangeZoomUpdate;

  //Variable for save the last zoom
  double _previousZoom = 0.0;

  //Function called when the map must show single point without aggregation
  // if null the class use the default function
  Function showSinglePoint;

  List<LatLngAndGeohash> list;

  Future<void> _onMapChanged({bool forceUpdate = false}) async {
    if (!mapController.isCameraMoving) {
      final zoom = mapController.cameraPosition.zoom;
      print("previuos zoom: " + _previousZoom.toString());
      print("actual zoom: " + zoom.toString());
      if ((_previousZoom != zoom &&
              (_previousZoom - zoom).abs() > rangeZoomUpdate.abs()) ||
          forceUpdate) {
        print("force update : " + forceUpdate.toString());
        _previousZoom = zoom;
        print("previous zoom: " + _previousZoom.toString());
        await mapController.clearMarkers();
        if (zoom < maxZoomForAggregatePoints) {
          updateAggregatedPoints(zoom: zoom);
        } else {
          if (showSinglePoint != null) {
            showSinglePoint();
          } else {
            updatePoints(zoom);
          }
        }
      }
    }
  }


  // Used for update list
  // NOT RECCOMENDED for good performance (SQL IS BETTER)
  updateData(List<LatLngAndGeohash> newList) {
    list = newList;
    _onMapChanged(forceUpdate: true);
  }

  Future<List<AggregatedPoints>> getAggregatedPoints(double zoom) async {
    print("loading aggregation");
    int level = 5;

    if (zoom <= 3) {
      level = 1;
    } else if (zoom < 5) {
      level = 2;
    } else if (zoom < 7) {
      level = 3;
    } else if (zoom < 10) {
      level = 4;
    } else if (zoom < 11) {
      level = 5;
    } else if (zoom < 13) {
      level = 6;
    } else if (zoom < 13.5) {
      level = 7;
    } else if (zoom < 14.5) {
      level = 8;
    }

    try {
      List<AggregatedPoints> aggregatedPoints;

      if (database != null) {
        aggregatedPoints = await DBHelper.getAggregatedPoints(database, dbTable,
            dbLatColumn, dbLongColumn, dbGeohashColumn, level);
      } else {
        //aggregatedPoints = _retrieveAggregatedPoints(list, [], level);
      }

      print(
          "reading complete aggregation pooints : ${aggregatedPoints.length}");
      return aggregatedPoints;
    } catch (e) {
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

  updateAggregatedPoints({double zoom = 0.0}) async {
    List<AggregatedPoints> aggregation = await getAggregatedPoints(zoom);
    print("aggregation lenght: " + aggregation.length.toString());

    aggregation.forEach((a) {
      BitmapDescriptor bitmapDescriptor;
      if (a.count == 1) {
        if (bitmapAssetPathForSingleMarker != null) {
          bitmapDescriptor =
              BitmapDescriptor.fromAsset(bitmapAssetPathForSingleMarker);
        } else {
          bitmapDescriptor = BitmapDescriptor.defaultMarker;
        }
      } else if (a.count < 20) {
        bitmapDescriptor = BitmapDescriptor.fromAsset("assets/images/m1.png",
            package: "clustering_google_maps");
      } else if (a.count < 100) {
        bitmapDescriptor = BitmapDescriptor.fromAsset("assets/images/m2.png",
            package: "clustering_google_maps");
      } else if (a.count < 1000) {
        bitmapDescriptor = BitmapDescriptor.fromAsset("assets/images/m3.png",
            package: "clustering_google_maps");
      } else {
        bitmapDescriptor = BitmapDescriptor.fromAsset("assets/images/m4.png",
            package: "clustering_google_maps");
      }

      mapController.addMarker(MarkerOptions(
        position: a.location,
        icon: bitmapDescriptor,
      ));
    });
  }


  updatePoints(double zoom) async {
    print("update single points");
    if(database != null){
      final l = await DBHelper.getPoints(database, dbTable, dbLatColumn, dbLongColumn);
      l.forEach((p) {
        mapController.addMarker(MarkerOptions(
          position: p.location,
          icon: bitmapAssetPathForSingleMarker != null
              ? BitmapDescriptor.fromAsset(bitmapAssetPathForSingleMarker)
              : BitmapDescriptor.defaultMarker,
        ));
      });
    }else{
//      list.forEach((p) {
//        mapController.addMarker(MarkerOptions(
//          position: p.location,
//          icon: bitmapAssetPathForSingleMarker != null
//              ? BitmapDescriptor.fromAsset(bitmapAssetPathForSingleMarker)
//              : BitmapDescriptor.defaultMarker,
//        ));
//      });
    }
  }
}
