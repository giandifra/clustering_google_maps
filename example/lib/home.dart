import 'package:clustering_google_maps/clustering_google_maps.dart'
    show AggregationSetup, ClusteringHelper, LatLngAndGeohash, MarkerWrapper;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'fake_point.dart';

class HomeScreen extends StatefulWidget {
  final List<Marker> list;

  HomeScreen({Key? key, required this.list}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ClusteringHelper clusteringHelper;
  final CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(0.000000, 0.000000), zoom: 0.0);

  Set<Marker> markers = Set();

  void _onMapCreated(GoogleMapController mapController) async {
    print("onMapCreated");
    clusteringHelper.mapController = mapController;
    // if (widget.list == null) {
    //   clusteringHelper.database = await AppDatabase.get().getDb();
    // }
    clusteringHelper.updateData(widget.list);
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
    // clusteringHelper = ClusteringHelper.forDB(
    //   dbGeohashColumn: FakePoint.dbGeohash,
    //   dbLatColumn: FakePoint.dbLat,
    //   dbLongColumn: FakePoint.dbLong,
    //   dbTable: FakePoint.tblFakePoints,
    //   updateMarkers: updateMarkers,
    //   aggregationSetup: AggregationSetup(),
    // );
  }

  // For memory solution
  initMemoryClustering() {
    clusteringHelper = ClusteringHelper.forMemory(
      // list: widget.list!,
      updateMarkers: updateMarkers,
      aggregationSetup: AggregationSetup(markerSize: 150),
      aggregatedCallback: (LatLng center, List<Marker> markers) {
        print(center);
        print(markers.length);
      },
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
