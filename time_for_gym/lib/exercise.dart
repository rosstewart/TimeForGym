// import 'package:flutter/material.dart';

import 'package:time_for_gym/main.dart';

class Exercise implements Comparable<Exercise> {
  Exercise({
    this.name = "",
    this.description = "",
    required this.musclesWorked,
    required this.musclesWorkedActivation,
    this.videoLink = "",
    this.identifier = "",
    this.waitMultiplier = -1,
    this.mainMuscleGroup = "",
    this.imageUrl = "",
    this.starRating = 0,
    this.userRating,
    this.resourcesRequired,
    this.machineAltName,
    this.userOneRepMax,
    this.isAccessoryMovement,
    required this.splitWeightAndReps,
    required this.splitWeightPerSet,
    required this.splitRepsPerSet,
    required this.userOneRepMaxHistory,
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

  final String name,
      description,
      videoLink,
      mainMuscleGroup,
      imageUrl,
      identifier;
  final List<String> musclesWorked;
  final List<int> musclesWorkedActivation;
  final double waitMultiplier;
  final double starRating;
  double? userRating;
  int? userOneRepMax;
  final List<String>? resourcesRequired;
  bool? isAccessoryMovement = true;
  final String? machineAltName;
  // Split top set weight and reps
  List<int> splitWeightAndReps = [];
  // Split weights for each set (including top set)
  List<int> splitWeightPerSet = [];
  // Split reps for each set (including top set)
  List<int> splitRepsPerSet = [];
  Map<int, int> userOneRepMaxHistory = {};

  @override
  int compareTo(Exercise other) {
    return other.starRating
        .compareTo(starRating); // Sort from highest to lowest rating
  }

  // Returns true on success, initializes splitWeightAndReps
  List<List<int>>? initializeSplitWeightAndRepsFrom1RM(int numSets) {
    if (userOneRepMax == null || isAccessoryMovement == null) {
      return null;
    }
    // Middle of 8-12 or 6-8
    int reps = isAccessoryMovement! ? 10 : 7;
    int weight = calculateRepsToWeight(reps, userOneRepMax!);
    splitWeightAndReps = [weight, reps];

    splitWeightPerSet = [weight];
    splitRepsPerSet = [reps];

    // if (splitWeightPerSet.isEmpty) {
    //   splitWeightPerSet = [weight];
    // } else {
    //   splitWeightPerSet[0] = weight;
    // }
    // if (splitRepsPerSet.isEmpty) {
    //   splitRepsPerSet = [reps];
    // } else {
    //   splitRepsPerSet[0] = reps;
    // }

    // Temporarily, for compound movements, 92% of topset for second set, 88% for third set
    if (isAccessoryMovement == true) {
      for (int i = 1; i < numSets; i++) {
        splitWeightPerSet.add(weight);
        splitRepsPerSet.add(reps);
      }
    } else {
      for (int i = 1; i < numSets; i++) {
        if (i == 1) {
          splitWeightPerSet.add((.92 * weight).toInt());
          if (reps > 6) {
            splitRepsPerSet.add(8);
          } else if (reps > 3) {
            splitRepsPerSet.add(reps + 2);
          } else {
            splitRepsPerSet.add(6);
          }
        } else {
          splitWeightPerSet.add((.88 * weight).toInt());
          splitRepsPerSet.add(splitRepsPerSet[1] + 2);
        }
      }
    }

    return [splitWeightPerSet, splitRepsPerSet];
  }

  List<List<int>>? initializeSetsFromTopSet(int numSets) {
    // Temporarily, for compound movements, 92% of topset for second set, 88% for third set
    if (splitWeightAndReps.isEmpty) {
      initializeSplitWeightAndRepsFrom1RM(numSets);
      return [splitWeightPerSet, splitRepsPerSet];
    }

    int weight = splitWeightAndReps[0];
    int reps = splitWeightAndReps[1];

    splitWeightPerSet = [weight];
    splitRepsPerSet = [reps];

    if (isAccessoryMovement == true) {
      for (int i = 1; i < numSets; i++) {
        splitWeightPerSet.add(weight);
        splitRepsPerSet.add(reps);
      }
    } else {
      for (int i = 1; i < numSets; i++) {
        if (i == 1) {
          splitWeightPerSet.add((.92 * weight).toInt());
          if (reps > 6) {
            splitRepsPerSet.add(8);
          } else if (reps > 3) {
            splitRepsPerSet.add(reps + 2);
          } else {
            splitRepsPerSet.add(6);
          }
        } else {
          splitWeightPerSet.add((.88 * weight).toInt());
          splitRepsPerSet.add(splitRepsPerSet[1] + 2);
        }
      }
    }

    return [splitWeightPerSet, splitRepsPerSet];
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
  String username, exerciseName, mainMuscleGroup;
  double? numStars;
  int? oneRepMax;
  List<int> splitWeightAndReps = [];
  List<int> splitWeightPerSet = [];
  List<int> splitRepsPerSet = [];
  Map<int, int> userOneRepMaxHistory = {};

  ExercisePopularityData(this.username, this.exerciseName, this.mainMuscleGroup,
      this.numStars, this.oneRepMax, this.splitWeightAndReps, this.splitWeightPerSet, this.splitRepsPerSet, this.userOneRepMaxHistory);

  Map<String, dynamic> toJson() => {
        'username': username,
        'exerciseName': exerciseName,
        'mainMuscleGroup': mainMuscleGroup,
        'numStars': numStars,
        'oneRepMax': oneRepMax,
        if (splitWeightAndReps.isNotEmpty) 'splitWeight': splitWeightAndReps[0],
        if (splitWeightAndReps.length > 1) 'splitReps': splitWeightAndReps[1],
        'splitWeightPerSet': splitWeightPerSet,
        'splitRepsPerSet': splitRepsPerSet,
        'userOneRepMaxHistory': userOneRepMaxHistory,
      };
}
