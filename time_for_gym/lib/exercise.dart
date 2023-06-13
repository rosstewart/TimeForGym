// import 'package:flutter/material.dart';

class Exercise implements Comparable<Exercise> {
  Exercise({
    this.name = "",
    this.description = "",
    this.musclesWorked = "",
    this.videoLink = "",
    this.waitMultiplier = -1,
    this.mainMuscleGroup = "",
    this.imageUrl = "",
    this.starRating = 0,
    this.userRating,
    this.resourcesRequired,
  });

  @override
  String toString() {
    return name;
  }

  String getMainMuscleGroup() {
    return mainMuscleGroup;
  }

  String getExerciseData() {
    return "$name|$description|$musclesWorked|$videoLink|$mainMuscleGroup";
  }

  final String name, description, musclesWorked, videoLink, mainMuscleGroup, imageUrl;
  final double waitMultiplier;
  final double starRating;
  double? userRating;
  final List<String>? resourcesRequired;

  @override
  int compareTo(Exercise other) {
    return other.starRating.compareTo(starRating); // Sort from highest to lowest rating
  }

  // factory Exercise.fromJson(Map<String, dynamic> json) {
  //   return Exercise(
  //     name: json['name'] ?? "",
  //     description: json['description'] ?? "",
  //     musclesWorked: json['musclesWorked'] ?? "",
  //     videoLink: json['videoLink'] ?? "",
  //     waitMultiplier: json['waitMultiplier'] ?? -1,
  //     mainMuscleGroup: json['mainMuscleGroup'] ?? "",
  //     imageUrl: json['imageUrl'] ?? "",
  //     starRating: json['rating0to10'] ?? 0,
  //   );
  // }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'name': name,
  //     'description': description,
  //     'musclesWorked': musclesWorked,
  //     'videoLink': videoLink,
  //     'waitMultiplier': waitMultiplier,
  //     'mainMuscleGroup': mainMuscleGroup,
  //     'imageUrl': imageUrl,
  //     'rating0to10': starRating,
  //   };
  // }
}


class ExercisePopularityData {
  String userID, exerciseName, mainMuscleGroup;
  double numStars;

  ExercisePopularityData(this.userID, this.exerciseName, this.mainMuscleGroup, this.numStars);

  Map<String, dynamic> toJson() => {
        'userID': userID,
        'exerciseName': exerciseName,
        'mainMuscleGroup': mainMuscleGroup,
        'numStars': numStars,
      };
}