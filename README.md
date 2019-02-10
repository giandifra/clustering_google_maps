# Clustering for Flutter Google Maps 

A Flutter package that recreate clustering technique in a [Google Maps](https://developers.google.com/maps/) widget.

## Developers Preview Status
The package recreate the CLUSTERING technique in a Google Maps. 
It's work with data recordered in a dababase SQLite. I use [sqflite](https://pub.dartlang.org/packages/sqflite)

## Usage

To use this package, add `clustering_google_maps` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

For a better performance, at every zoom variation on the map, the package performs
a specific query on the SQLite database. This solution is better than loading all
points in memory (in a list) and then aggregating points on the map. 

## Getting Started

For the package to work properly, you must have the data of the points saved in a SQLite database.
Latitude, longitude and the string of geohash. These three parameters are necessary for correct operation.
If you have not saved the [GEOHASH](https://pub.dartlang.org/packages/geohash), I suggest you install [GEOHASH](https://pub.dartlang.org/packages/geohash)
plugin and save the value of Geohash in the points table of db.

### Future Implementations

- To further improve performance I am creating a way to perform sql queries only on the latlng bounding box displayed on the map. 
- I will insert custom marker with number of points. But for now [Google Maps](https://developers.google.com/maps/) widget does not allow
  custom widget from dart but only static Bitmap

### Quick Example

```dart
import 'package:example/app_db.dart';
import 'package:example/fake_point.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:clustering_google_maps/clustering_google_maps.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  final CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(42.825932, 13.715370), zoom: 0.0);

  void _onMapCreated(GoogleMapController mapController) async {
    final Database database = await AppDatabase.get().getDb();
    final ClusteringHelper clusteringHelper = ClusteringHelper.forDB(
      database: database,
      mapController: mapController,
      dbGeohashColumn: FakePoint.dbGeohash,
      dbLatColumn: FakePoint.dbLat,
      dbLongColumn: FakePoint.dbLong,
      dbTable: FakePoint.tblFakePoints,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Clustering Example"),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        trackCameraPosition: true,
        initialCameraPosition: initialCameraPosition,
      ),
    );
  }
}
```

See the `example` directory for a complete sample app.