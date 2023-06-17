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

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Listening to MyAppState

    var exercises = appState.muscleGroups[appState.currentMuscleGroup];

    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.headlineSmall!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    List<Exercise> filteredExercises = [];
    if (exercises != null) {
      filteredExercises = exercises.where((exercise) {
        if (selectedFilterOption == 'Dumbbell-Only') {
          if (exercise.resourcesRequired != null) {
            return exercise.resourcesRequired!.contains('Dumbbells');
          }
        } else if (selectedFilterOption == 'No Equipment') {
          if (exercise.resourcesRequired != null) {
            return exercise.resourcesRequired!.contains('None');
          }
        } else if (selectedFilterOption == 'Machine-Only') {
          if (exercise.resourcesRequired != null) {
            return exercise.resourcesRequired!.contains('Machine');
          }
        }
        return true; // Return true to include all exercises by default
      }).toList();
    }

    return SwipeBack(
        appState: appState,
        index: 8,
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
                            style:
                                TextStyle(color: theme.colorScheme.onBackground),
                          ),
                          icon: Icon(
                            Icons.cancel,
                            color: theme.colorScheme.onBackground,
                          ),
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
                            style:
                                TextStyle(color: theme.colorScheme.onBackground),
                          ),
                        ),
                      );
                    }
                  }).toList(),
                  SizedBox(
                    width: 5, // Buffer space from left
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
