import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:io';

import 'package:time_for_gym/main.dart';
import 'package:time_for_gym/exercise.dart';
// import 'package:time_for_gym/muscle_groups_page.dart';

class ExercisesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Listening to MyAppState

    var exercises = appState.muscleGroups[appState.currentMuscleGroup];

    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    return ListView(
      children: [
        Back(appState: appState, index: 1),

        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "${appState.currentMuscleGroup} Exercises",
                textAlign: TextAlign.center,
                style: titleStyle,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            if (exercises != null)
              for (Exercise exercise in exercises)
                ExerciseSelectorButton(exercise: exercise),
            // BigButton(text: muscleGroupName, index: 0),4
          ],
        ),
        // ),
      ],
    );
  }
}
