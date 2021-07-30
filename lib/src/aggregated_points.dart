import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'lat_lang_geohash.dart';

class AggregatedPoints {
  LatLng _location;
  final List<MarkerWrapper> points;
  String bitmabAssetName;


  LatLng get location => _location;
  int get count => points.length;

  AggregatedPoints(this.points) {
    double latitude = 0;
    double longitude = 0;
    points.forEach((l) {
      latitude += l.location.latitude;
      longitude += l.location.longitude;
    });
    _location = LatLng(latitude/count, longitude/count);
    this.bitmabAssetName = getBitmapDescriptorAsset();
  }

  String getBitmapDescriptorAsset() {
    String bitmapAsset;
    if (count < 10) {
      // + 2
      bitmapAsset = "assets/images/m1.png";
    } else if (count < 25) {
      // + 10
      bitmapAsset = "assets/images/m2.png";
    } else if (count < 50) {
      // + 25
      bitmapAsset = "assets/images/m3.png";
    } else if (count < 100) {
      // + 50
      bitmapAsset = "assets/images/m4.png";
    } else if (count < 500) {
      // + 100
      bitmapAsset = "assets/images/m5.png";
    } else if (count < 1000) {
      // +500
      bitmapAsset = "assets/images/m6.png";
    } else {
      // + 1k
      bitmapAsset = "assets/images/m7.png";
    }
    return bitmapAsset;
  }

  getId() {
    return location.latitude.toString() +
        "_" +
        location.longitude.toString() +
        "_$count";
  }
}
