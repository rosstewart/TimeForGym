import 'package:flutter/material.dart';

class Exercise implements Comparable<Exercise> {
  const Exercise({
    this.name = "",
    this.description = "",
    this.musclesWorked = "",
    this.videoLink = "",
    this.waitMultiplier = -1,
    this.mainMuscleGroup = "",
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

  final String name, description, musclesWorked, videoLink, mainMuscleGroup;
  final double waitMultiplier;

  @override
  int compareTo(Exercise other) {
    return name.compareTo(other.name); // Sort alphabetically
  }
}
