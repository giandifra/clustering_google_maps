import 'package:google_maps_flutter/google_maps_flutter.dart';

class AggregatedPoints {
  final LatLng location;
  final int count;

  AggregatedPoints(this.location, this.count);

  AggregatedPoints.fromMap(
      Map<String, dynamic> map, String dbLatColumn, String dbLongColumn)
      : count = map['n_marker'],
        this.location = LatLng(map['lat'], map['long']);
}
