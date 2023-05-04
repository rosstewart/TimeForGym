import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:io';

import 'package:time_for_gym/main.dart';
import 'package:time_for_gym/exercise.dart';
// import 'package:time_for_gym/muscle_groups_page.dart';

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Listening to MyAppState

    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    return ListView(
      children: [
        Back(appState: appState, index: 0),

        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "Favorite Exercises",
                style: titleStyle,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            if (appState.favoriteExercises.isEmpty)
              Card(
                color: theme.colorScheme.surface,
                elevation: 10, // Shadow
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "You have no favorite exercises",
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ),
            for (Exercise exercise in appState.favoriteExercises)
              // ExerciseSelectorButton(exerciseName: exercise.name, fromFavorites: true,),
              FavoriteExerciseSelectorButton(exercise: exercise),
          ],
        ),
        // ),
      ],
    );
  }
}
