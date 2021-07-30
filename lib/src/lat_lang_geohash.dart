import 'package:dart_geohash/dart_geohash.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'
    show LatLng, Marker;

class MarkerWrapper {
  final Marker _marker;
  late String _geohash;
  String get geohash => _geohash;

  LatLng get location => _marker.position;
  Marker get marker => _marker;

  MarkerWrapper(this._marker) {
    final geohaser = GeoHasher();
    _geohash = geohaser.encode(
      location.longitude,
      location.latitude,
    );
  }

  getId() {
    return _marker.markerId.value;
  }
}
