// import 'package:flutter/material.dart';

import 'package:time_for_gym/main.dart';

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
    this.userOneRepMax,
    this.isAccessoryMovement,
    required this.splitWeightAndReps,
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
  int? userOneRepMax;
  final List<String>? resourcesRequired;
  bool? isAccessoryMovement = true;
  List<int> splitWeightAndReps = [];

  @override
  int compareTo(Exercise other) {
    return other.starRating.compareTo(starRating); // Sort from highest to lowest rating
  }

  // Returns true on success, initializes splitWeightAndReps
  List<int>? initializeSplitWeightAndRepsFrom1RM() {
    if (userOneRepMax == null || isAccessoryMovement == null) {
      return null;
    }
    // Middle of 8-12 or 6-8
    int reps = isAccessoryMovement! ? 10 : 7;
    int weight = calculateRepsToWeight(reps, userOneRepMax!);
    splitWeightAndReps = [weight,reps];
    return splitWeightAndReps;
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
  double? numStars;
  int? oneRepMax;
  List<int> splitWeightAndReps = [];

  ExercisePopularityData(this.userID, this.exerciseName, this.mainMuscleGroup, this.numStars, this.oneRepMax, this.splitWeightAndReps);

  Map<String, dynamic> toJson() => {
        'userID': userID,
        'exerciseName': exerciseName,
        'mainMuscleGroup': mainMuscleGroup,
        'numStars': numStars,
        'oneRepMax': oneRepMax,
        'splitWeight': splitWeightAndReps[0],
        'splitReps': splitWeightAndReps[1],
      };
}