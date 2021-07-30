import 'dart:typed_data';
import 'dart:async';
import 'dart:ui' as ui;

import 'aggregated_points.dart';
import 'aggregation_setup.dart';
import 'lat_lang_geohash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

typedef void AggregatedCallback(LatLng center, List<Marker> markers);

class ClusteringHelper {
  ClusteringHelper.forMemory({
    this.aggregatedCallback,
    @required this.updateMarkers,
    this.maxZoomForAggregatePoints = 13.5,
    @required this.aggregationSetup,
  }) : assert(aggregationSetup != null);

  //After this value the map show the single points without aggregation
  final double maxZoomForAggregatePoints;

  //Custom bitmap: string of assets position
  final AggregationSetup aggregationSetup;

  // Callback for tapping the aggregated Marker
  final AggregatedCallback aggregatedCallback;

  //Where clause for query db
  String whereClause;

  GoogleMapController mapController;

  //Variable for save the last zoom
  double _currentZoom = 0.0;

  //Function called when the map must show single point without aggregation
  // if null the class use the default function
  Function showSinglePoint;

  //Function for update Markers on Google Map
  Function updateMarkers;

  //List of points for memory clustering
  List<MarkerWrapper> get list => _sortedList;
  List<MarkerWrapper> _sortedList;

  // Prev level, a.k.a for caching
  int prevLevel;

  // caching
  List<AggregatedPoints> resultAggregated;
  Set<Marker> resultMarkers;

  //Call during the editing of CameraPosition
  //If you want updateMap during the zoom in/out set forceUpdate to true
  //this is NOT RECCOMENDED
  onCameraMove(CameraPosition position, {forceUpdate = false}) {
    _currentZoom = position.zoom;
    if (forceUpdate) {
      updateMap();
    }
  }

  //Call when user stop to move or zoom the map
  Future<void> onMapIdle() async {
    updateMap();
  }

  updateMap() {
    if (_currentZoom < maxZoomForAggregatePoints) {
      updateAggregatedPoints(zoom: _currentZoom);
    } else {
      if (showSinglePoint != null) {
        showSinglePoint();
      } else {
        updatePoints(_currentZoom);
      }
    }
  }

  // Used for update list
  // NOT RECCOMENDED for good performance (SQL IS BETTER)
  updateData(List<Marker> newList) {
    _sortedList = newList.map((e) => MarkerWrapper(e)).toList();
    _sortedList.sort((a, b) => a.geohash.compareTo(b.geohash)); // in-place sort
    prevLevel = 0;
    resultAggregated = null;
    updateMap();
  }

  int _zoom2Level(double zoom) {
    int level;
    if (zoom <= aggregationSetup.maxZoomLimits[0]) {
      level = 1;
    } else if (zoom < aggregationSetup.maxZoomLimits[1]) {
      level = 2;
    } else if (zoom < aggregationSetup.maxZoomLimits[2]) {
      level = 3;
    } else if (zoom < aggregationSetup.maxZoomLimits[3]) {
      level = 4;
    } else if (zoom < aggregationSetup.maxZoomLimits[4]) {
      level = 5;
    } else if (zoom < aggregationSetup.maxZoomLimits[5]) {
      level = 6;
    } else if (zoom < aggregationSetup.maxZoomLimits[6]) {
      level = 7;
    } else {
      level = 8;
    }
    return level;
  }

  Future<List<AggregatedPoints>> getAggregatedPoints(double zoom) async {
    int level = _zoom2Level(zoom);
    if (prevLevel == level && resultAggregated != null) return resultAggregated;
    assert(() {
      print("loading aggregation");
      return true;
    }());

    try {
      _updateResultAtLevel(level);
      return resultAggregated;
    } catch (e) {
      assert(() {
        print(e.toString());
        return true;
      }());
      return List.empty();
    }
  }

  final List<AggregatedPoints> aggList = [];

  _updateResultAtLevel(int level) {
    final List<AggregatedPoints> R = [];
    final L = _sortedList;
    if (L.length == 0) return;

    var prefix = L[0].geohash.substring(0, level);
    var A = [L[0]];

    for (var i = 1; i < L.length; i++) {
      if (L[i].geohash.substring(0, level) == prefix) {
        A.add(L[i]);
      } else {
        R.add(AggregatedPoints(A));
        A = [L[i]];
        prefix = L[i].geohash.substring(0, level);
      }
    }
    R.add(AggregatedPoints(A));
    resultAggregated = R;
    prevLevel = level;
  }

  Future<void> updateAggregatedPoints({double zoom = 0.0}) async {
    final level = _zoom2Level(zoom);
    if (prevLevel == level && resultMarkers != null)
      return; // Nothing to do here
    List<AggregatedPoints> aggregation = await getAggregatedPoints(zoom);
    final Set<Marker> markers = {};
    for (var i = 0; i < aggregation.length; i++) {
      final a = aggregation[i];

      BitmapDescriptor bitmapDescriptor;

      if (a.count == 1) {
        markers.add(a.points[0].marker);
        continue;
      }
      // >1
      final Uint8List markerIcon =
          await getBytesFromCanvas(a.count.toString(), getColor(a.count));
      bitmapDescriptor = BitmapDescriptor.fromBytes(markerIcon);
      final MarkerId markerId = MarkerId(a.getId());

      final marker = Marker(
        markerId: markerId,
        position: a.location,
        infoWindow: InfoWindow(title: a.count.toString()),
        icon: bitmapDescriptor,
        onTap: () {
          if (aggregatedCallback != null)
            aggregatedCallback(
                a.location, a.points.map((e) => e.marker).toList());
        },
      );

      markers.add(marker);
    }
    resultMarkers = markers;
    updateMarkers(resultMarkers);
  }

  updatePoints(double zoom) async {
    try {
      final Set<Marker> markers = list.map((p) => p.marker).toSet();
      updateMarkers(markers);
    } catch (ex) {
      assert(() {
        print(ex.toString());
        return true;
      }());
    }
  }

  Future<Uint8List> getBytesFromCanvas(String text, MaterialColor color) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()..color = color[400];
    final Paint paint2 = Paint()..color = color[300];
    final Paint paint3 = Paint()..color = color[100];
    final int size = aggregationSetup.markerSize;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint3);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.4, paint2);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 3.3, paint1);
    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: text,
      style: TextStyle(
          fontSize: size / 4, color: Colors.black, fontWeight: FontWeight.bold),
    );
    painter.layout();
    painter.paint(
      canvas,
      Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
    );

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data.buffer.asUint8List();
  }

  MaterialColor getColor(int count) {
    if (count < aggregationSetup.maxAggregationItems[0]) {
      // + 2
      return aggregationSetup.colors[0];
    } else if (count < aggregationSetup.maxAggregationItems[1]) {
      // + 10
      return aggregationSetup.colors[1];
    } else if (count < aggregationSetup.maxAggregationItems[2]) {
      // + 25
      return aggregationSetup.colors[2];
    } else if (count < aggregationSetup.maxAggregationItems[3]) {
      // + 50
      return aggregationSetup.colors[3];
    } else if (count < aggregationSetup.maxAggregationItems[4]) {
      // + 100
      return aggregationSetup.colors[4];
    } else if (count < aggregationSetup.maxAggregationItems[5]) {
      // +500
      return aggregationSetup.colors[5];
    } else {
      // + 1k
      return aggregationSetup.colors[6];
    }
  }
}
