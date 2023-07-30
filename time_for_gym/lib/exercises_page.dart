import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import 'dart:io';

import 'package:time_for_gym/main.dart';
import 'package:time_for_gym/exercise.dart';
// import 'package:time_for_gym/muscle_groups_page.dart';

class ExercisesPage extends StatefulWidget {
  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  List<String> filterOptions = [
    'Dumbbell-Only',
    'No Equipment',
    'Machine-Only'
  ];
  String selectedFilterOption = 'None';

  Map<String, List<String>> subMuscleGroups = {
    'Chest': ['Upper Chest', 'Mid Chest', 'Lower Chest'],
    'Back': ['Lats', 'Upper Back', 'Mid Back', 'Lower Back'],
    'Triceps': ['Long Head', 'Lateral Head', 'Medial Head'],
    'Biceps': ['Long Head', 'Short Head', 'Brachialis', 'Forearms'],
    'Abs': ['Upper Abs', 'Lower Abs'],
    'Glutes': ['Glute Medius', 'Hip Adductors'],
  };

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Listening to MyAppState

    var exercises = appState.muscleGroups[appState.currentMuscleGroup];
    while (filterOptions.length > 3 &&
        filterOptions[0] !=
            (subMuscleGroups[appState.currentMuscleGroup] ?? [''])[0]) {
      filterOptions.removeAt(0);
    }
    if (filterOptions.length == 3 &&
        subMuscleGroups[appState.currentMuscleGroup] != null) {
      filterOptions.insertAll(0, subMuscleGroups[appState.currentMuscleGroup]!);
    }

    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    List<Exercise> filteredExercises = [];
    if (exercises != null) {
      if (selectedFilterOption == 'Dumbbell-Only') {
        filteredExercises = exercises.where((exercise) {
          if (exercise.resourcesRequired != null) {
            return exercise.resourcesRequired!.contains('Dumbbells');
          }
          return true;
        }).toList();
      } else if (selectedFilterOption == 'No Equipment') {
        filteredExercises = exercises.where((exercise) {
          if (exercise.resourcesRequired != null) {
            return exercise.resourcesRequired!.contains('None') ||
                exercise.resourcesRequired!.contains('Pull-Up Bar') ||
                exercise.resourcesRequired!.contains('Parallel Bars');
          }
          return true;
        }).toList();
      } else if (selectedFilterOption == 'Machine-Only') {
        filteredExercises = exercises.where((exercise) {
          if (exercise.resourcesRequired != null) {
            return exercise.resourcesRequired!.contains('Machine');
          }
          return true;
        }).toList();
      } else if (selectedFilterOption == 'Forearms') {
        filteredExercises = exercises.where((exercise) {
          return exercise.musclesWorked.contains('Forearms') ||
              exercise.musclesWorked.contains('Brachioradialis');
        }).toList();
      } else if (selectedFilterOption == 'None') {
        filteredExercises = exercises;
      } else {
        // selectedFilterOption is a regular sub muscle group
        int index;
        String subMuscleGroup = selectedFilterOption;
        if (appState.currentMuscleGroup == 'Biceps' &&
            subMuscleGroup != 'Brachialis') {
          subMuscleGroup = 'Bicep $subMuscleGroup';
        } else if (appState.currentMuscleGroup == 'Triceps') {
          subMuscleGroup = 'Tricep $subMuscleGroup';
        }
        filteredExercises = exercises.where((exercise) {
          index = exercise.musclesWorked.indexOf(subMuscleGroup);
          if (index == -1) {
            return false;
          }
          // If high activation, class it in the sub muscle group
          return exercise.musclesWorkedActivation[index] == 3;
        }).toList();
      }
    }

    return SwipeBack(
      appState: appState,
      index: 8,
      swipe: true,
      child: Scaffold(
        appBar: AppBar(
          leading: Back(appState: appState, index: 8),
          leadingWidth: 70,
          title: Text(
            "${appState.currentMuscleGroup} Exercises",
            style: titleStyle,
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
        ),
        body: ListView(
          children: [
            SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: 5, // Buffer space from left
                  ),
                  ...filterOptions.map((option) {
                    final labelStyle = theme.textTheme.labelSmall!
                        .copyWith(color: theme.colorScheme.onBackground);
                    bool isSelected = option == selectedFilterOption;
                    if (isSelected) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              if (!isSelected) {
                                selectedFilterOption = option;
                              } else {
                                selectedFilterOption = 'None';
                              }
                            });
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  resolveColor(theme.colorScheme.primary),
                              surfaceTintColor:
                                  resolveColor(theme.colorScheme.primary)),
                          label: Text(
                            option,
                            style: labelStyle,
                          ),
                          icon: Icon(Icons.cancel,
                              color: theme.colorScheme.onBackground, size: 16),
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedFilterOption = option;
                            });
                          },
                          style: ButtonStyle(
                              backgroundColor: resolveColor(
                                  theme.colorScheme.primaryContainer),
                              surfaceTintColor: resolveColor(
                                  theme.colorScheme.primaryContainer)),
                          child: Text(
                            option,
                            style: labelStyle,
                          ),
                        ),
                      );
                    }
                  }).toList(),
                  SizedBox(
                    width: 5, // Buffer space from right
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            for (Exercise exercise in filteredExercises)
              ExerciseSelectorButton(exercise: exercise),
          ],
        ),
      ),
      // ),
    );
  }
}

class ExerciseSelectorButton extends StatelessWidget {
  const ExerciseSelectorButton({
    super.key,
    required this.exercise,
    // required this.index,
  });

  final Exercise exercise;
  // final int index;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    void togglePressed() {
      // Coming from individual muscle group page
      appState.fromSearchPage = false;
      // appState.fromFavorites = false;
      appState.fromSplitDayPage = false;
      appState.changePageToExercise(exercise);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      child: TextButton(
        onPressed: togglePressed,
        child: Row(children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: theme.colorScheme.onBackground),
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: ImageContainer(exercise: exercise),
            ),
          ),
          SizedBox(width: 25),
          SizedBox(
            width: 260,
            child: Text(
              exercise.name,
              style: style,
              maxLines: 2,
            ),
          ),
        ]),
      ),
    );
  }
}
