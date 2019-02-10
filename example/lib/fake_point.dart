import 'package:geohash/geohash.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FakePoint {
  static final tblFakePoints = "fakePoints";
  static final dbId = "id";
  static final dbLat = "latitude";
  static final dbLong = "longitude";
  static final dbGeohash = "geohash";

  LatLng location;
  String secret;
  int id;
  String geohash;

  FakePoint({this.location, this.id}) {
    this.geohash =
        Geohash.encode(this.location.latitude, this.location.longitude);
  }

  FakePoint.fromMap(Map<String, dynamic> map)
      : id = map[dbId],
        location = LatLng(map[dbLat], map[dbLong]) {
    this.geohash =
        Geohash.encode(this.location.latitude, this.location.longitude);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[dbId] = this.id;
    data[dbLat] = this.location.latitude;
    data[dbLat] = this.location.longitude;
    return data;
  }
}
