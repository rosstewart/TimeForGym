import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:io';

import 'package:time_for_gym/main.dart';
import 'package:time_for_gym/exercise.dart';
import 'package:time_for_gym/split.dart';
// import 'package:time_for_gym/muscle_groups_page.dart';

class SplitDayPage extends StatelessWidget {
  int dayIndex;
  List<String> daysOfWeek = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  SplitDayPage(this.dayIndex);

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Listening to MyAppState

    List<TrainingDay> trainingDays = appState.currentSplit.trainingDays;

    var exercises = appState.muscleGroups[appState.currentMuscleGroup];

    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    return ListView(
      children: [
        Back(appState: appState, index: 6),

        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                daysOfWeek[dayIndex],
                textAlign: TextAlign.center,
                style: titleStyle,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            if (appState.currentSplit.trainingDays[dayIndex] != null)
              for (int i = 0;
                  i <
                      appState.currentSplit.trainingDays[dayIndex].muscleGroups
                          .length;
                  i++)
                SplitMuscleGroupCard(
                  muscleGroup: appState
                      .currentSplit.trainingDays[dayIndex].muscleGroups[i],
                  splitDayCardIndex: i,
                ),
            // BigButton(text: muscleGroupName, index: 0),4
          ],
        ),
        // ),
      ],
    );
  }
}

class SplitMuscleGroupCard extends StatefulWidget {
  SplitMuscleGroupCard({
    super.key,
    required this.muscleGroup,
    required this.splitDayCardIndex,
  });

  final String muscleGroup;
  final int splitDayCardIndex;

  @override
  State<SplitMuscleGroupCard> createState() => _SplitMuscleGroupCardState();
}

class _SplitMuscleGroupCardState extends State<SplitMuscleGroupCard> {
  int exerciseIndex = 0;

  void changeExercise(var appState, bool next) {
    exerciseIndex = appState.splitDayExerciseIndices[appState.currentDayIndex]
        [widget.splitDayCardIndex];
    if (next) {
      if (exerciseIndex >=
          appState.muscleGroups[widget.muscleGroup].length - 1) {
        // if will be out of bounds
        return;
      }
      setState(() {
        exerciseIndex++;
      });
    } else {
      // previous
      if (exerciseIndex == 0) {
        // if will be out of bounds
        return;
      }
      setState(() {
        exerciseIndex--;
      });
    }

    // Set the "default" exercise to view in that muscle group of the split
    appState.splitDayExerciseIndices[appState.currentDayIndex]
        [widget.splitDayCardIndex] = exerciseIndex;
    appState.saveSplitDayExerciseIndicesData();
  }

  void toExercise(var appState, Exercise exercise) {
    appState.changePageToExercise(exercise);
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    final theme = Theme.of(context);
    final headingStyle = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.secondary,
      fontWeight: FontWeight.bold,
    );
    final textStyle = theme.textTheme.titleMedium!.copyWith(
      color: theme.colorScheme.secondary,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () {
                    changeExercise(appState, false);
                  },
                  icon: Icon(Icons.navigate_before)),
              SizedBox(
                width: 300,
                child: Card(
                  color: theme.colorScheme.surface,
                  elevation: 10, // Shadow
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      children: [
                        Text(widget.muscleGroup,
                            style: headingStyle, textAlign: TextAlign.center),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                            // exercise index
                            appState
                                .muscleGroups[widget.muscleGroup]![
                                    appState.splitDayExerciseIndices[
                                            appState.currentDayIndex]
                                        [widget.splitDayCardIndex]]
                                .name,
                            style: textStyle,
                            textAlign: TextAlign.center),
                        SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            toExercise(
                                appState,
                                appState.muscleGroups[widget.muscleGroup]![
                                    exerciseIndex]);
                          },
                          child: Text("View Exercise"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {
                    changeExercise(appState, true);
                  },
                  icon: Icon(Icons.navigate_next)),
            ],
          ),
          SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}
