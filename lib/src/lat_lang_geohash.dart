import 'dart:math';

import 'package:dart_geohash/dart_geohash.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

class LatLngAndGeohash {
  final LatLng location;
  late String geohash;

  LatLngAndGeohash(this.location) {
    final geohasher = GeoHasher();
    geohash = geohasher.encode(
      location.longitude,
      location.latitude,
    );
  }

  LatLngAndGeohash.fromMap(Map<String, dynamic> map)
      : location = LatLng(map['lat'], map['long']) {
    final geohasher = GeoHasher();
    this.geohash = geohasher.encode(
      this.location.longitude,
      this.location.latitude,
    );
  }

  getId() {
    return location.latitude.toString() +
        "_" +
        location.longitude.toString() +
        "_${Random().nextInt(10000)}";
  }
}
