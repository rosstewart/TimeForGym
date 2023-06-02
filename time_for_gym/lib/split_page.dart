import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:io';

import 'package:time_for_gym/main.dart';
import 'package:time_for_gym/split.dart';
// import 'package:time_for_gym/exercise.dart';
// import 'package:time_for_gym/muscle_groups_page.dart';

class SplitPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Listening to MyAppState

    // var exercises = appState.muscleGroups[appState.currentMuscleGroup];

    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    return ListView(
      children: [
        BackFromSplitPage(appState: appState, index: 0),

        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "Custom Workout Split",
                textAlign: TextAlign.center,
                style: titleStyle,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Card(
                color: theme.colorScheme.surface,
                elevation: 10, // Shadow
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        if (appState.makeNewSplit == true)
                          GymGoalAndDayOfWeekSelector(),
                        if (appState.makeNewSplit == false) SplitCard(),
                      ],
                    )),
              ),
            ),
          ],
        ),
        // ),
      ],
    );
  }
}

class GymGoalAndDayOfWeekSelector extends StatefulWidget {
  @override
  _GymGoalAndDayOfWeekSelectorState createState() =>
      _GymGoalAndDayOfWeekSelectorState();
}

class _GymGoalAndDayOfWeekSelectorState
    extends State<GymGoalAndDayOfWeekSelector> {
  String? selectedGymGoalOption;

  List<String> gymGoalOptions = [
    'Build Muscle',
    'Build Strength',
    'Cardio Focused'
  ];

  List<String> selectedDayOfWeekOptions = [];

  List<String> dayOfWeekOptions = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  void submitSplitOnPressed(var appState) {
    // Since selectedDayOfWeekOptions is unsorted:
    String trainingDaysInput = "";
    for (String dayOfWeek in dayOfWeekOptions) {
      if (selectedDayOfWeekOptions.contains(dayOfWeek)) {
        trainingDaysInput += "t"; // train
      } else {
        trainingDaysInput += "r"; // rest
      }
    }
    // Set at 60 training minutes per session temporarily
    // No focused muscle groups temporarily
    if (selectedGymGoalOption != null) {
      appState
          .setSplit(Split(selectedGymGoalOption!, trainingDaysInput, 60, []));
    }

    for (int i = 0; i < appState.currentSplit.trainingDays.length; i++) {
      // First split or previous rest day
      if (appState.splitDayExerciseIndices[i].isEmpty) {
        for (int j = 0;
            j < appState.currentSplit.trainingDays[i].muscleGroups.length;
            j++) {
          appState.splitDayExerciseIndices[i]
              .add(0); // Initialize current exercise in split to index 0
          // String muscleGroup = appState.currentSplit.trainingDays[i].muscleGroups[j];
        }
      } else {
        // set all to 0
        for (int j = 0;
            j < appState.currentSplit.trainingDays[i].muscleGroups.length;
            j++) {
          if (j >= appState.splitDayExerciseIndices[i].length){ // New split day goes over more muscle groups than previous split day
            appState.splitDayExerciseIndices[i].add(0);
          }
          appState.splitDayExerciseIndices[i][j] =
              0; // Initialize current exercise in split to index 0
        }
      }
    }

    appState.storeSplitInSharedPreferences();
    appState.saveSplitDayExerciseIndicesData(); // Initialize as 0s to be saved
  }

  void restorePreviousSplit(var appState) {
    appState.setMakeNewSplit(false);
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Listening to MyAppState

    final theme = Theme.of(context);
    final headingStyle = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.secondary,
      fontWeight: FontWeight.bold,
    );
    final textStyle = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.secondary,
    );

    return Column(
      children: [
        if (appState.currentSplit != null)
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                      onPressed: () {
                        restorePreviousSplit(appState);
                      },
                      icon: Icon(Icons.restore),
                      label: Text("Restore Previous Split"))
                ],
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        Text(
          "Select Gym Goal:",
          style: headingStyle,
        ),
        SizedBox(height: 20),
        Column(
          children: gymGoalOptions.map((gymGoalOption) {
            return RadioListTile<String>(
              title: Text(gymGoalOption),
              value: gymGoalOption,
              groupValue: selectedGymGoalOption,
              onChanged: (value) {
                setState(() {
                  selectedGymGoalOption = value;
                });
              },
            );
          }).toList(),
        ),
        SizedBox(
          height: 30,
        ),
        Text(
          "Select training days:",
          style: headingStyle,
        ),
        SizedBox(height: 20),
        Column(
          children: dayOfWeekOptions.map((dayOfWeekOption) {
            return CheckboxListTile(
              title: Text(
                dayOfWeekOption,
                style: textStyle,
              ),
              value: selectedDayOfWeekOptions.contains(dayOfWeekOption),
              onChanged: (value) {
                setState(() {
                  if (value!) {
                    selectedDayOfWeekOptions.add(dayOfWeekOption);
                  } else {
                    selectedDayOfWeekOptions.remove(dayOfWeekOption);
                  }
                });
              },
            );
          }).toList(),
        ),
        SizedBox(
          height: 20,
        ),
        ElevatedButton(
            onPressed: () {
              submitSplitOnPressed(appState);
            },
            child: Text("Generate Split"))
      ],
    );
  }
}

class SplitCard extends StatelessWidget {
  final List<String> daysOfWeek = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  void viewDayOfWeek(var appState, int dayIndex) {
    appState.currentDayIndex = dayIndex;
    appState.changePage(7);
  }

  void regenerateSplit(var appState) {
    appState.setMakeNewSplit(true);
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final headingStyle = theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.secondary,
      fontWeight: FontWeight.bold,
    );
    final textStyle = theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.secondary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
                onPressed: () {
                  regenerateSplit(appState);
                },
                icon: Icon(Icons.autorenew),
                label: Text("Make a New Split"))
          ],
        ),
        SizedBox(
          height: 20,
        ),
        for (int i = 0; i < 7; i++)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 400,
              height: 70,
              child: ElevatedButton(
                onPressed: () {
                  viewDayOfWeek(appState, i);
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${daysOfWeek[i]}:  ',
                        style: headingStyle,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        appState.currentSplit.trainingDays[i].toString(),
                        style: textStyle,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
