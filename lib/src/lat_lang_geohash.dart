import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng, Marker;
import 'package:geohash/geohash.dart';

class MarkerWrapper {
  final Marker _marker;
  String _geohash;
  String get geohash => _geohash;

  LatLng get location => _marker.position;
  Marker get marker => _marker;

  MarkerWrapper(this._marker) {
    _geohash = Geohash.encode(location.latitude, location.longitude);
  }

  getId() {
    return _marker.markerId.value;
  }
}
