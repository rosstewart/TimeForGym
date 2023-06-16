// import 'package:time_for_gym/exercise.dart';
// import 'dart:convert';

// class ExerciseIndex {
//   ExerciseIndex({
//     this.exercise,
//     this.index = 0,
//   });

//   @override
//   String toString() {
//     return '$index: $exercise';
//   }

//   factory ExerciseIndex.fromJson(Map<String, dynamic> json) {
//     return ExerciseIndex(
//       index: json['index'] ?? 0,
//       exercise: json['exercise'] != null
//           ? Exercise.fromJson(json['exercise'])
//           : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'index': index,
//       'exercise': exercise != null ? exercise!.toJson() : null,
//     };
//   }

//   int index;
//   Exercise? exercise;
// }
