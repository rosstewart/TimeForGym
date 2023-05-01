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
    var appState = context.watch<MyAppState>(); // Listening to MyAppState



    int backIndex;

    List<Exercise> exercises = appState.muscleGroups[appState.currentMuscleGroup]!;
    Exercise exercise = Exercise(name: "", description: "", musclesWorked: "", videoLink: "", waitMultiplier: -1);

    if (appState.fromFavorites){
      backIndex = 2;
      // exercises = appState.favoriteExercises;
    } else{
      backIndex = 4;
    }

    if (exercises == null) {
      print("ERROR - List of exercises is null");
      return Placeholder();
    }
    
    try {
        exercise =
        exercises.firstWhere((e) => e.name == appState.currentExercise);
    }
    catch (exception){
      // Have to find the exercise again
      outerLoop: for (String muscleGroup in appState.muscleGroups.keys){
        var exercisesByMuscleGroup = appState.muscleGroups[muscleGroup];
        // print(muscleGroup);
        if (exercisesByMuscleGroup == null){
          print("ERROR - Muscle group is null");
          return Placeholder();
        }
        for (Exercise e in exercisesByMuscleGroup){
          if (e.name == appState.currentExercise){
            exercise = e; // Found exercise
            break outerLoop;
          }
        }
      }
    }

    if (exercise.waitMultiplier == -1) {
      print("ERROR - Exercise is null");
      return Placeholder();
    }

    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    IconData icon;
    if (appState.favoriteExercises.contains(exercise)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    
    if (appState.fromFavorites){
      backIndex = 2;
    } 

    return Column(
      children: [
        SizedBox(
          height: 50,
        ),
        Back(appState: appState, index: backIndex),

        Column(
          children: [
            //

            Padding(
              padding: const EdgeInsets.all(20),
              // child: Text("${wordPair.first} ${wordPair.second}", style: style),
              child: Text(
                exercise.name,
                style: titleStyle,
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ExerciseCard(
                    description: exercise.description,
                    musclesWorked: exercise.musclesWorked,
                    expectedWaitTime:
                        (WAIT_MULTIPLIER_TO_MINUTES * exercise.waitMultiplier)
                            .toStringAsFixed(0), // Remove decimal place
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
                        icon: Icon(icon),
                        label: Text('Favorite exercise'),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          launchUrl(Uri.parse(exercise.videoLink));
                        },
                        child: Text('Tutorial video'),
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
          ],
        ),
        // ),
      ],
    );
  }
}
