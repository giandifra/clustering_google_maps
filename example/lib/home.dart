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

  Set<Marker> markers = Set();

  void _onMapCreated(GoogleMapController mapController) async {
    print("onMapCreated");
    clusteringHelper.database = await AppDatabase.get().getDb();
    clusteringHelper.updateMap();
  }

  updateMarkers(Set<Marker> markers) {
    setState(() {
      this.markers = markers;
    });
  }

  @override
  void initState() {
    initClustering();
    super.initState();
  }

  initClustering() {
    clusteringHelper = ClusteringHelper.forDB(
      dbGeohashColumn: FakePoint.dbGeohash,
      dbLatColumn: FakePoint.dbLat,
      dbLongColumn: FakePoint.dbLong,
      dbTable: FakePoint.tblFakePoints,
      updateMarkers: updateMarkers,
    );
  }

  @override
  Widget build(BuildContext context) {
    print("build");
    return Scaffold(
      appBar: AppBar(
        title: Text("Clustering Example"),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: initialCameraPosition,
        markers: markers,
        onCameraMove: clusteringHelper.onCameraMove,
        onCameraIdle: clusteringHelper.onMapIdle,
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.content_cut),
          onPressed: () {
            clusteringHelper.whereClause = "WHERE ${FakePoint.dbLat} > 42.6";
            clusteringHelper.updateMap();
          }),
    );
  }
}
