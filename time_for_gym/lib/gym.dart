// import 'dart:html';
// import 'dart:ui';

import 'package:flutter/material.dart';
// import 'package:google_maps_webservice/places.dart';
import 'package:time_for_gym/exercise.dart';

class Gym implements Comparable<Gym> {
  Gym({
    required this.name,
    required this.placeId,
    required this.formattedAddress,
    required this.photos,
    required this.openNow,
    required this.googleMapsRating,
    required this.machinesAvailable,
    required this.resourcesAvailable,
    required this.url,
  });

  @override
  String toString() {
    return name;
  }

  // Returns null if no openNow data from Google Maps
  bool? isOpenNow() {
    return openNow;
  }

  @override
  // Sort from high rating to low rating
  int compareTo(Gym other) {
    if (googleMapsRating == null) {
      if (other.googleMapsRating == null) {
        return 0; // Both ratings are null, consider them equal
      } else {
        return 1; // Null rating is considered smaller than non-null rating
      }
    } else {
      if (other.googleMapsRating == null) {
        return -1; // Non-null rating is considered larger than null rating
      } else {
        return other.googleMapsRating!.compareTo(googleMapsRating!);
      }
    }
  }

  // Update name - openNow if any Google Maps data was changed
  void updateGoogleMapsData(
      String name,
      String formattedAddress,
      // List<Widget> photos,
      bool? openNow,
      double? googleMapsRating,
      String url) {
    if (this.name != name) {
      this.name = name;
    }
    if (this.formattedAddress != formattedAddress) {
      this.formattedAddress = formattedAddress;
    }
    // Keep photos the same to reduce api requests
    // if (this.photos.length != photos.length) {
    //   this.photos = photos;
    // } else {
    //   for (Widget photo in photos) {

    //   }
    // }

    // if (this.photos != photos) {
    //   this.photos = photos;
    // }
    if (this.openNow != openNow) {
      this.openNow = openNow;
    }
    if (this.googleMapsRating != googleMapsRating) {
      this.googleMapsRating = googleMapsRating;
    }
    if (this.url != url) {
      this.url = url;
    }
  }

  bool canSupportExercise(Exercise element) {
    for (String resource in element.resourcesRequired ?? []) {
      if (resource == 'None' ||
          resource == 'Bodyweight' ||
          resource == 'Dumbbells') {
        return true;
      }
      if (resource == 'Machine') {
        // Check if gym has the machine
        if (machinesAvailable.isEmpty) {
          // Assume true if no machines initialized
          return true;
        }
        if (!machinesAvailable.contains(element)) {
          // If gym doesn't have machine, return false
          return false;
        }
      } else if (resourcesAvailable[resource] == null ||
          resourcesAvailable[resource]! < 1) {
        if (resourcesAvailable.isEmpty) {
          // Assume true if no resources at all initialized
          return true;
        }
        if (resourcesAvailable[resource] != null &&
            resourcesAvailable[resource]! < 1) {
          // Resource is initialized to 0
          return false;
        }
        // If null for just that specific resource, continue
      }
    }
    return true;
  }

  String name;
  String placeId;
  String formattedAddress;
  List<Widget> photos;
  bool? openNow;
  double? googleMapsRating;
  List<Exercise> machinesAvailable;
  Map<String, int> resourcesAvailable;
  String url;
}

class GymData {
  String name;
  String placeId;
  String formattedAddress;
  // List<String> photosAsBase64;
  // bool? openNow;
  double? googleMapsRating;
  List<String> machinesAvailable;
  Map<String, int> resourcesAvailable;
  String url;

  GymData(
      this.name,
      this.placeId,
      this.formattedAddress,
      // this.photosAsBase64,
      // this.openNow,
      this.googleMapsRating,
      this.machinesAvailable,
      this.resourcesAvailable,
      this.url);

  Map<String, dynamic> toJson() => {
        'name': name,
        'placeId': placeId,
        'formattedAddress': formattedAddress,
        // 'photosAsBase64': photosAsBase64,
        // 'openNow': openNow,
        'googleMapsRating': googleMapsRating,
        'machinesAvailable': machinesAvailable,
        'resourcesAvailable': resourcesAvailable,
        'url': url,
      };
}
