# Clustering for Flutter Google Maps 

[![pub package](https://img.shields.io/pub/v/clustering_google_maps.svg)](https://pub.dartlang.org/packages/clustering_google_maps)

A Flutter package that recreate clustering technique in a [Google Maps](https://developers.google.com/maps/) widget.

<div style="text-align: center"><table><tr>
  <td style="text-align: center">
  <a href="https://github.com/giandifra/clustering_google_maps/blob/master/example.gif">
    <img src="https://github.com/giandifra/clustering_google_maps/blob/master/example.gif" width="200"/></a>
</td>
</tr></table></div>

## Developers Preview Status
The package recreate the CLUSTERING technique in a Google Maps. 
~~It's work with data recordered in a dababase SQLite. I use [sqflite](https://pub.dartlang.org/packages/sqflite) (DB TECHNIQUE)~~
It's work with a list of LatLngAndGeohash object. (MEMORY TECHNIQUE)

## Usage

To use this package, add `clustering_google_maps` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

# Use my fork
```
clustering_google_maps:
  git:
    url: https://github.com/juancki/clustering_google_maps.git
```
For a better performance,~~at every zoom variation on the map, the package performs
a specific query on the SQLite database~~, but you can force update with updateMap() method.

## Getting Started

### ~~DB TECHNIQUE~~

### MEMORY TECHNIQUE

To work properly you must have a list of ~~LatLngAndGeohash~~ MarkerWrapper objects. 

For this solution you must use the MEMORY constructor of ClusteringHelper:

```dart
ClusteringHelper.forMemory(...);
```

### Aggregation Setup

Yuo can customize color, range count and zoom limit of aggregation.
See this class: [AggregationSetup](https://github.com/giandifra/clustering_google_maps/blob/master/lib/src/aggregation_setup.dart).

