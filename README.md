# Clustering for Flutter Google Maps 

[![pub package](https://img.shields.io/pub/v/clustering_google_maps.svg)](https://pub.dartlang.org/packages/clustering_google_maps)

A Flutter package that recreate clustering technique in a [Google Maps](https://developers.google.com/maps/) widget.

<div style="text-align: center"><table><tr>
  <td style="text-align: center">
  <a href="https://github.com/giandifra/clustering_google_maps/blob/master/example.gif">
    <img src="https://github.com/giandifra/clustering_google_maps/blob/master/example.gif" width="200"/></a>
</td>
</tr></table></div>

## Developers Preview Status
The package recreate the CLUSTERING technique in a Google Maps. 
It's work with data recordered in a dababase SQLite. I use [sqflite](https://pub.dartlang.org/packages/sqflite) (DB TECHNIQUE)
It's work with a list of LatLngAndGeohash object. (MEMORY TECHNIQUE)

## Usage

To use this package, add `clustering_google_maps` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

For a better performance, at every zoom variation on the map, the package performs
a specific query on the SQLite database, but you can force update with updateMap() method.

## Getting Started

### DB TECHNIQUE
To work properly, you must have the data of the points saved in a SQLite database.
Latitude, longitude and the string of geohash. These three parameters are necessary for correct operation.
If you have not saved the [GEOHASH](https://pub.dartlang.org/packages/geohash), I suggest you install [GEOHASH](https://pub.dartlang.org/packages/geohash)
plugin and save the value of Geohash in the points table of db.

For this solution you must use the db constructor of ClusteringHelper:

```dart
ClusteringHelper.forDB(...);
```

### MEMORY TECHNIQUE

To work properly you must have a list of LatLngAndGeohash object. LatLngAndGeohash is a simple object with Location 
and Geohash property, the last is generated automatically; you need only location of the point.

For this solution you must use the MEMORY constructor of ClusteringHelper:

```dart
ClusteringHelper.forMemory(...);
```

### Aggregation Setup

Yuo can customize color, range count and zoom limit of aggregation.
See this class: [AggregationSetup](https://github.com/giandifra/clustering_google_maps/blob/master/lib/src/aggregation_setup.dart).

## Future Implementations

- ~~To further improve performance I am creating a way to perform sql queries only on the latlng bounding box displayed on the map.~~
- ~~I will insert custom marker with number of points.~~

## Quick Example for both solution

```dart
import 'package:example/app_db.dart';
import 'package:example/fake_point.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:clustering_google_maps/clustering_google_maps.dart';

class HomeScreen extends StatefulWidget {
  final List<LatLngAndGeohash> list;

  HomeScreen({Key key, this.list}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ClusteringHelper clusteringHelper;
  final CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(0.000000, 0.000000), zoom: 0.0);

  Set<Marker> markers = Set();

  void _onMapCreated(GoogleMapController mapController) async {
    print("onMapCreated");
    clusteringHelper.mapController = mapController;
    if (widget.list == null) {
      clusteringHelper.database = await AppDatabase.get().getDb();
    }
    clusteringHelper.updateMap();
  }

  updateMarkers(Set<Marker> markers) {
    setState(() {
      this.markers = markers;
    });
  }

  @override
  void initState() {
    if (widget.list != null) {
      initMemoryClustering();
    } else {
      initDatabaseClustering();
    }

    super.initState();
  }

  // For db solution
  initDatabaseClustering() {
    clusteringHelper = ClusteringHelper.forDB(
      dbGeohashColumn: FakePoint.dbGeohash,
      dbLatColumn: FakePoint.dbLat,
      dbLongColumn: FakePoint.dbLong,
      dbTable: FakePoint.tblFakePoints,
      updateMarkers: updateMarkers,
      aggregationSetup: AggregationSetup(),
    );
  }

  // For memory solution
  initMemoryClustering() {
    clusteringHelper = ClusteringHelper.forMemory(
      list: widget.list,
      updateMarkers: updateMarkers,
      aggregationSetup: AggregationSetup(markerSize: 150),
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
        initialCameraPosition: initialCameraPosition,
        markers: markers,
        onCameraMove: (newPosition) =>
            clusteringHelper.onCameraMove(newPosition, forceUpdate: false),
        onCameraIdle: clusteringHelper.onMapIdle,
      ),
      floatingActionButton: FloatingActionButton(
        child:
            widget.list == null ? Icon(Icons.content_cut) : Icon(Icons.update),
        onPressed: () {
          if (widget.list == null) {
            //Test WHERE CLAUSE
            clusteringHelper.whereClause = "WHERE ${FakePoint.dbLat} > 42.6";
          }
          //Force map update
          clusteringHelper.updateMap();
        },
      ),
    );
  }
}
```

See the `example` directory for a complete sample app.
