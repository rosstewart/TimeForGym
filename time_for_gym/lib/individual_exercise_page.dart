import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:io';

import 'package:time_for_gym/main.dart';
import 'package:time_for_gym/exercise.dart';

const WAIT_MULTIPLIER_TO_MINUTES = 10;

class IndividualExercisePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<MyAppState>(context); // Listening to MyAppState

    int backIndex;

    // List<Exercise> exercises = appState.muscleGroups[appState.currentMuscleGroup]!;
    // Exercise exercise = Exercise(name: "", description: "", musclesWorked: "", videoLink: "", waitMultiplier: -1, mainMuscleGroup: "");
    Exercise exercise = appState.currentExercise;

    // Below - DEPRECATED: Search of exercises

    // if (exercises == null) {
    //   print("ERROR - List of exercises is null");
    //   return Placeholder();
    // }

    // try {
    //     exercise =
    //     exercises.firstWhere((e) => e.name == appState.currentExercise.name);
    // }
    // catch (exception){
    //   // Have to find the exercise again
    //   String muscleGroup = appState.currentExercise.getMainMuscleGroup();
    //   appState.currentMuscleGroup = muscleGroup;
    //   var exercisesByMuscleGroup = appState.muscleGroups[muscleGroup];
    //   if (exercisesByMuscleGroup == null){
    //     print("ERROR - Muscle group is null");
    //     return Placeholder();
    //   }
    //   for (Exercise e in exercisesByMuscleGroup){
    //       if (e.name == appState.currentExercise.name){

    //         exercise = e; // Found exercise
    //       break;
    //     }
    //   }

    // Below: Deprecated slower method for finding exercise

    // outerLoop: for (String muscleGroup in appState.muscleGroups.keys){
    //   var exercisesByMuscleGroup = appState.muscleGroups[muscleGroup];
    //   // print(muscleGroup);
    //   if (exercisesByMuscleGroup == null){
    //     print("ERROR - Muscle group is null");
    //     return Placeholder();
    //   }
    //   for (Exercise e in exercisesByMuscleGroup){
    //     if (e.name == appState.currentExercise){
    //       exercise = e; // Found exercise
    //       break outerLoop;
    //     }
    //   }
    // }
    // }

    if (exercise.waitMultiplier == -1) {
      print("ERROR - Exercise is null");
      return Placeholder();
    }

    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    // IconData icon
    // if (appState.favoriteExercises.contains(exercise)) {
    //   icon = Icons.favorite;
    // } else {
    //   bool foundFavorite = false;
    //   for (Exercise favoriteExercise in appState.favoriteExercises) {
    //     if (exercise.compareTo(favoriteExercise) == 0) {
    //       // If duplicate exercise is already in favorites
    //       foundFavorite = true;
    //       break;
    //     }
    //   }
    //   if (!foundFavorite) {
    //     icon = Icons.favorite_border;
    //   } else{
    //     icon = Icons.favorite;
    //   }
    // }
    IconData icon = Icons.abc;
    bool foundFavorite = false;
    for (Exercise favoriteExercise in appState.favoriteExercises) {
      if (exercise.compareTo(favoriteExercise) == 0) {
        // If duplicate exercise is already in favorites
        icon = Icons.favorite;
        foundFavorite = true;
        break;
      }
    }
    if (!foundFavorite) {
      icon = Icons.favorite_border;
    }

    backIndex = 4;

    if (appState.fromFavorites) {
      backIndex = 2;
    } else if (appState.fromSplitDayPage) {
      backIndex = 7;
    } else if (appState.fromSearchPage) {
      backIndex = 8;
    }

    return Scaffold(
      appBar: AppBar(
        leading: Back(appState: appState, index: backIndex),
        leadingWidth: 70,
        title: Text(
          exercise.name,
          style: titleStyle,
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: ListView(
        children: [
          // Back(appState: appState, index: backIndex),

          // Column(
          //   children: [
          //

          // Padding(
          //   padding: const EdgeInsets.all(20),
          //   // child: Text("${wordPair.first} ${wordPair.second}", style: style),
          //   child: Text(
          //     exercise.name,
          //     style: titleStyle,
          //     textAlign: TextAlign.center,
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 10, 50, 20),
            child: ImageContainer(exercise: exercise),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ExerciseCard(
                  exercise: exercise,
                  // name: exercise.name,
                  // description: exercise.description,
                  // mainMuscleGroup: exercise.mainMuscleGroup,
                  // musclesWorked: exercise.musclesWorked,
                  expectedWaitTime: (WAIT_MULTIPLIER_TO_MINUTES *
                          exercise.waitMultiplier *
                          ((appState.gymCount as int).toDouble() /
                              appState.maxCapacity.toDouble()))
                      .toStringAsFixed(0),
                ), // Remove decimal place
                // imageUrl: exercise.imageUrl,
                // averageRating: exercise.starRating,
                // userRating: exercise.userRating),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: ButtonStyle(
                          backgroundColor:
                              resolveColor(theme.colorScheme.primaryContainer),
                          surfaceTintColor:
                              resolveColor(theme.colorScheme.primaryContainer)),
                      onPressed: () {
                        appState.toggleFavorite(exercise);
                      },
                      icon: Icon(icon, color: theme.colorScheme.primary),
                      label: Text('Favorite exercise',
                          style:
                              TextStyle(color: theme.colorScheme.onBackground)),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              resolveColor(theme.colorScheme.primaryContainer),
                          surfaceTintColor:
                              resolveColor(theme.colorScheme.primaryContainer)),
                      onPressed: () {
                        launchUrl(Uri.parse(exercise.videoLink));
                      },
                      child: Text('Tutorial video',
                          style:
                              TextStyle(color: theme.colorScheme.onBackground)),
                    ),
                  ],
                )
              ],
            ),
          ),

          //

          // Text(exercise.name),
          // Text(exercise.description),
          // Text(exercise.musclesWorked),
          // Text(exercise.videoLink),
          // Text(exercise.waitMultiplier.toString()),
          // if (exercise != null)
          // ExerciseSelectorButton(exerciseName: exercise.name),
          // BigButton(text: muscleGroupName, index: 0),4
          //   ],
          // ),
          // ),
        ],
      ),
    );
  }
}

// class StarRatingButton extends StatefulWidget {
//   final Function(double) onRatingSelected;

//   const StarRatingButton({required this.onRatingSelected});

//   @override
//   _StarRatingButtonState createState() => _StarRatingButtonState();
// }

// class _StarRatingButtonState extends State<StarRatingButton> {
//   double _selectedRating = 0.0;

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     return GestureDetector(
//       onHorizontalDragUpdate: (details) {
//         _updateRatingFromDrag(details.localPosition);
//       },
//       onHorizontalDragEnd: (_) {
//         widget.onRatingSelected(_selectedRating);
//       },
//       onTapUp: (details) {
//         final tapPosition = details.localPosition;
//         _updateRatingFromTap(tapPosition);
//         widget.onRatingSelected(_selectedRating);
//       },
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: List.generate(5, (index) {
//           final starValue = (index + 1) * 0.5;
//           return GestureDetector(
//             onTap: () {
//               setState(() {
//                 _selectedRating = starValue;
//               });
//               widget.onRatingSelected(_selectedRating);
//             },
//             child: _selectedRating >= starValue ? Icon(Icons.star, color: theme.colorScheme.primary,) : Icon(Icons.star_border, color: theme.colorScheme.primary,),
//           );
//         }),
//       ),
//     );
//   }

//   void _updateRatingFromDrag(Offset position) {
//     final box = context.findRenderObject() as RenderBox?;
//     if (box != null) {
//       final dx = position.dx.clamp(0.0, box.size.width);
//       final totalWidth = box.size.width;
//       final ratingPercentage = dx / totalWidth;
//       setState(() {
//         _selectedRating = ratingPercentage * 5.0;
//       });
//     }
//   }

//   void _updateRatingFromTap(Offset position) {
//     final box = context.findRenderObject() as RenderBox?;
//     if (box != null) {
//       final dx = position.dx.clamp(0.0, box.size.width);
//       final totalWidth = box.size.width;
//       final ratingPercentage = dx / totalWidth;
//       setState(() {
//         _selectedRating = ratingPercentage * 5.0;
//       });
//     }
//   }
// }
