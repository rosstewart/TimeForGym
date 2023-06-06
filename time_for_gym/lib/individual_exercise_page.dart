import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:typed_data';


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

    if (appState.fromFavorites) {
      backIndex = 2;
      // exercises = appState.favoriteExercises;
    } else {
      backIndex = 4;
    }

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
      body:  ListView(
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
            ImageContainer(exercise: exercise),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ExerciseCard(
                    name: exercise.name,
                    description: exercise.description,
                    musclesWorked: exercise.musclesWorked,
                    expectedWaitTime: (WAIT_MULTIPLIER_TO_MINUTES *
                            exercise.waitMultiplier *
                            ((appState.gymCount as int).toDouble() /
                                appState.maxCapacity.toDouble()))
                        .toStringAsFixed(0), // Remove decimal place
                    imageUrl: exercise.imageUrl,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          appState.toggleFavorite(exercise);
                        },
                        style: ButtonStyle(backgroundColor: resolveColor(theme.colorScheme.onPrimary)),
                        icon: Icon(icon, color: appState.onBackground),
                        label: Text('Favorite exercise', style: TextStyle(color: appState.onBackground)),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          launchUrl(Uri.parse(exercise.videoLink));
                        },
                        style: ButtonStyle(backgroundColor: resolveColor(theme.colorScheme.onPrimary)),
                        child: Text('Tutorial video', style: TextStyle(color: appState.onBackground)),
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
    ),);
  }

  
}


