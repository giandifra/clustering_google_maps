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

  ClusteringHelper clusteringHelper;
  final CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(0.000000, 0.000000), zoom: 0.0);

  void _onMapCreated(GoogleMapController mapController) async {
    final Database database = await AppDatabase.get().getDb();
    clusteringHelper = ClusteringHelper.forDB(
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