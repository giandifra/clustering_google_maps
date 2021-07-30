import 'package:dart_geohash/dart_geohash.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

class FakePoint {
  static final tblFakePoints = "fakePoints";
  static final dbId = "id";
  static final dbLat = "latitude";
  static final dbLong = "longitude";
  static final dbGeohash = "geohash";

  LatLng? location;
  int? id;
  String? geohash;

  FakePoint({this.location, this.id}) {
    final geohasher = GeoHasher();
    this.geohash =
        geohasher.encode(this.location!.longitude, this.location!.latitude);
  }

  FakePoint.fromMap(Map<String, dynamic> map)
      : id = map[dbId],
        location = LatLng(map[dbLat], map[dbLong]) {
    final geohasher = GeoHasher();
    this.geohash =
        geohasher.encode(this.location!.longitude, this.location!.latitude);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[dbId] = this.id;
    data[dbLat] = this.location!.latitude;
    data[dbLat] = this.location!.longitude;
    return data;
  }
}
