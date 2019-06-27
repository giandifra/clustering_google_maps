import 'package:flutter/material.dart';

class AggregationSetup {
  /// List of integern number, they are the limit of aggregation range
  final List<int> maxAggregationItems;

  /// List of MaterialColor, they are the color of the marker matching aggregation range
  final List<MaterialColor> colors;

  /// List of double, they are the limit of zoom when change the aggregation level
  final List<double> maxZoomLimits;

  final int markerSize;

  AggregationSetup({
    this.maxAggregationItems = const [10, 25, 50, 100, 500, 1000],
    this.colors = const [
      Colors.grey,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.red,
      Colors.pink
    ],
    this.maxZoomLimits = const [
      3.0,
      5.0,
      7.5,
      10.5,
      13.0,
      13.5,
      14.5,
    ],
    this.markerSize = 150,
  })  : assert(maxAggregationItems.length == 6),
        assert(colors.length == 7),
        assert(maxZoomLimits.length == 7),
        assert(markerSize > 0);
}
